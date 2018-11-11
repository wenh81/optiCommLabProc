function Signal = SignalGenerator()

%-------------------------------------------------------
% signal properties
%-------------------------------------------------------
Signal.M = 4; % QAM modulation order
Signal.Rs = 2.5e9; % Symbol rate in Hz
Signal.nsymb = 2^15 - 1; % Tentative number of symbols - The actual number of symbols will be calculated later
Signal.pulse.roll_off = 0.1; % Roll-off of the pulses  0.1 0.9
Signal.pulse.nsymb = 512; % Length of the pulse-shaping filters, in symbols
Signal.pulse.shape = 'Raised Cosine'; %  'Square Root Raised Cosine';%Type of pulse-shaping filters. 
Signal.Ssc = 10e9; % Sub-carrier spacing, in Hz
Signal.Nsc = 2; % Number of sub-carriers 2
Signal.awgRs = 40e9; % Sample rate of the AWGs in Hz



%-------------------------------------------------------
% compute the required number of symbols
%-------------------------------------------------------
% the number of symbols in the random sequence must be adjusted to have
% the subcarrier spacing as an integer multiple of the frequency spacing

% number of samples per symbol for the baseband signals - Should be integer
Signal.pulse.sps = Signal.awgRs / Signal.Rs;

% normalized sub-carrier frequencies (normalized to the AWG rate)
Signal.freq_scs = ( ( 0:( Signal.Nsc - 1 ) ) - ( Signal.Nsc - 1 ) / 2 ) * Signal.Ssc / Signal.awgRs / 1;


% Look for a suitable number of symbols
nsymbtest = repmat( 2^8:2^18, Signal.Nsc, 1 );
% sci = repmat( Signal.freq_scs(:), 1, length( nsymbtest ) ) * Signal.pulse.sps .* nsymbtest * Signal.Nsc;
sci = repmat( Signal.freq_scs(:), 1, length( nsymbtest ) ) * Signal.pulse.sps .* nsymbtest;
xtest = sum( abs( rem( sci, 1 ) ), 1 );
nsymb_integer = nsymbtest( 1, xtest == 0 );
if ~isempty( nsymb_integer )
	[ ~, minpos ] = min( abs( nsymb_integer - Signal.nsymb ) );
	fprintf( 'Changing number of symbols from %d to %d\n', Signal.nsymb, nsymb_integer( minpos ) );
	Signal.nsymb = nsymb_integer( minpos );
else
	warning( 'Could not find a suitable integer number of symbols' )
end;

% Maximum modulation frequency required from the AWG
Signal.CutOffFreq = Signal.Rs * ( 1 + Signal.pulse.roll_off ) + Signal.awgRs * max( Signal.freq_scs )

%-------------------------------------------------------
% generate signals
%-------------------------------------------------------
% binary sequences
Signal.seq = uint8( randi( [ 0, 1 ], Signal.Nsc, Signal.nsymb * log2( Signal.M ) ) );
% modulator object
Signal.hmodem = modem.qammod( 'M', Signal.M, 'SymbolOrder', 'gray', 'InputType', 'bit' );
% pulse shaping filter
Signal.pulse.filter = fdesign.pulseshaping( Signal.pulse.sps, Signal.pulse.shape, ...
	'Nsym,beta', Signal.pulse.nsymb, Signal.pulse.roll_off );
% filter impulse response
aux = design( Signal.pulse.filter );
hf = [ aux.Numerator, zeros( 1, ( Signal.nsymb - Signal.pulse.nsymb ) * Signal.pulse.sps - 1 ) ];
hf = circshift( hf, [ 0, -Signal.pulse.sps * Signal.pulse.nsymb / 2 ] );
% normalized time
% t_n = 0:( 1 / Signal.pulse.sps ):( ( length( hf ) - 1 ) / Signal.pulse.sps );
t_n = 0:( length( hf ) - 1 );
% cycle through sub-carriers
Signal.mseq = zeros( Signal.Nsc, Signal.nsymb );
fshift_sig = zeros( Signal.Nsc, length( hf ) );
for n = 1:Signal.Nsc
	% modulated sequences
	Signal.mseq( n, : ) = single( Signal.hmodem.modulate( double( Signal.seq( n, : ).' ) ).' );
	% upsample sequences
	useq = upsample( Signal.mseq( n, : ), Signal.pulse.sps );
	% generate signal
	sig = ifft( fft( useq ) .* fft( hf ) );
	% frequency shift
	fshift_sig( n, : ) = sig .* exp( -1i * 2 * pi * Signal.freq_scs( n ) * t_n );
end;
% composite signal
Signal.composite_signal = sum( fshift_sig, 1 );

figure(1)
f = Signal.awgRs * linspace( -0.5, 0.5, size( sig, 2 ) ) / 1e9;
plot( f, fftshift(10*log10(abs(fft(sig(1,:)))))); hold on;
plot( f, fftshift(10*log10(abs(fft(Signal.composite_signal))))); hold off;
grid on;
axis( [ Signal.awgRs / 2e9 * [ -1, 1 ], -70, 40 ] )







