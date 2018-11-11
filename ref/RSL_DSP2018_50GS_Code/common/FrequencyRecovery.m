function [ out, fMax ] = FrequencyRecovery( in, sps, nsamp )
if nargin < 3
	nsamp = size( in, 2 );
else
	nsamp = min( nsamp, size( in, 2 ) );
end
ssamp = floor( nsamp / 2 );
% 4th power signal
% s4 = in( :, 1:sps:end ).^4; length( s4 )
s4 = in( :, ( end - nsamp + 1 ):sps:end ).^4;

% Fourier transform
S4 = sum( abs( fft( s4, [], 2 ) ).^2, 1 );
% Position of maximum frequency
[ ~, fMaxPos ] = max( S4 );
fMaxPos = fMaxPos - 1; % To match the c version
% Normalized carrier frequency
if fMaxPos < ( ssamp / 2 + 1 )
	fMax = fMaxPos / ( 8 * ssamp );
else
	fMax = ( fMaxPos - ssamp ) / ( 8 * ssamp );
end

f = 0:( size( in, 2 ) - 1 );
shiftAngle = exp( -1i * f * 2 * pi * fMax );
out = in .* repmat( shiftAngle, size( in, 1 ), 1 );




return

%% Old Version
Debug = 0;
MF = 4;
for pol = 1:size( in, 1 )
    rsig = in( pol, : );
    if Debug
        f0 = linspace( -sps / 2, sps / 2, length( rsig ) );
        h = figure;
        plot( f0, fftshift( abs( fft( rsig ) ) ) ), hold on;
        grid on;
    end;
    
    % Isolate main samples
    rs = rsig( 1:sps:end );
    r4 = ( rs - mean( rs ) ).^MF; r4 = r4 - mean( r4 );
    R4 = fftshift( fft( r4 ) );
    f = linspace( -0.5, 0.5, length( rs ) );
    
    if Debug
        figure
        plot( f, abs( R4 ) );
    end;
    
    [ ~, fPosMax ] = max( abs( R4 ) );
    fMax = f( fPosMax ) / MF;
    
    dt = 1 / sps;
    t = 0:dt:( ( length( rsig ) - 1 ) * dt );
    rsig = rsig .* exp( -1i * 2 * pi * fMax * t );
    
    if Debug
        figure( h )
        plot( f0, fftshift( abs( fft( rsig ) ) ), 'r' );
        legend( 'Original', 'Corrected' );
    end;
    out( pol, : ) = rsig;
end;
