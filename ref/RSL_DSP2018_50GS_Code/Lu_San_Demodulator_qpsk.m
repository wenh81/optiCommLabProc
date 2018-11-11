function [ ber, rseq, bers ] = Lu_San_Demodulator_qpsk( rsig, Signal )
% 	% Get a QPSK constellation
% 	modem4QAM = modem.qammod( 4 );
% 	const = modem4QAM.Constellation / sqrt( mean( abs( modem4QAM.Constellation ).^2 ) );
% 	
% 	
% 	% Get an association table between 16qam and qpsk
% 	x = repmat( const, 1, 4 );
% 	y = reshape( ones( 4, 1 ) * const, 1, 16 );
% 	const16 = x + y / 2;
% 	const16 = const16 / sqrt( mean( abs( const16 ).^2 ) );
% 	
% % 	figure(2);
% % 	plot( rsig, '.' );
% % 	hold on;
% % 	plot( const16, 'ro' );
% % 	hold off;
% 	
% 	% Produce a idealized reference signal
% 	ref = repmat( const16.', 1, size( rsig, 2 ) );
% 	symbdist = abs( ref - repmat( rsig, length( const16 ), 1 ) );
% 	[ dmin, constpos ] = min( symbdist );
% 	
% 	% Produce 2 QPSK sequences from the reference 16QAM signal
% 	rsig = [ x( constpos ); y( constpos ) ];
	
	% Align signals with original modulated sequences
% 	mseq = [ real( Signal.mseq( 1, : ) ); imag( Signal.mseq( 1, : ) ); ...
% 		real( Signal.mseq( 2, : ) ); imag( Signal.mseq( 2, : ) ) ];
% 	rsig_aligned = alignsignals( rsig, mseq );
    
    mseq = [ real( Signal.mseq( 1, : ) ); imag( Signal.mseq( 1, : ) ) ];
	rsig_aligned = alignsignals( rsig, mseq );
	
	
	% Demodulate signals
	demodem = modem.qamdemod( Signal.hmodem );
	rseq = [demodem.demodulate( rsig_aligned( 1, : ).' )].';
	
	bers = countErrors( double( Signal.seq( 1, : ) ), rseq( 1, : ) );
	%bers( 2 ) = countErrors( double( Signal.seq( 2, : ) ), rseq( 2, : ) );
	
	% ber = mean( bers );
	
	
	