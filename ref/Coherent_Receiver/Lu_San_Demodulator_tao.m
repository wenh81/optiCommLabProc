function [ ber, rseq] = Lu_San_Demodulator_tao( rsig, Signal, modulation )
	% Get a QPSK constellation
	modem4QAM = modem.qammod( 4 );
	const = modem4QAM.Constellation / sqrt( mean( abs( modem4QAM.Constellation ).^2 ) );
	
	if strcmp(modulation, '16_QAM')
		% Get an association table between 16qam and qpsk
		x = repmat( const, 1, 4 );
		y = reshape( ones( 4, 1 ) * const, 1, 16 );
		const = x + y / 2;
		const = const / sqrt( mean( abs( const ).^2 ) );
	elseif  strcmp(modulation, 'QPSK')
		x = repmat( const, 1, 1 );
	end
	
	% Produce a idealized reference signal
	ref = repmat( const.', 1, size( rsig, 2 ) );
	symbdist = abs( ref - repmat( rsig, length( const), 1 ) );
	[ dmin, constpos ] = min( symbdist );
	
	if strcmp(modulation, '16_QAM')
		rsig = [ x( constpos ); y( constpos ) ];
		mseq = [ real( Signal.mseq( 1, : ) ); imag( Signal.mseq( 1, : ) ); ...
			real( Signal.mseq( 2, : ) ); imag( Signal.mseq( 2, : ) ) ];
		rsig_aligned = alignsignals_tao( rsig, mseq,modulation );
		demodem = modem.qamdemod( Signal.hmodem );
		rseq = [ ...
			demodem.demodulate( rsig_aligned( 1, : ).' ), ...
			demodem.demodulate( rsig_aligned( 2, : ).' ) ].';
		
		bers( 1 ) = countErrors( double( Signal.seq( 1, : ) ), rseq( 1, : ) );
		bers( 2 ) = countErrors( double( Signal.seq( 2, : ) ), rseq( 2, : ) );
		ber = mean( bers );
	elseif strcmp(modulation, 'QPSK')
		rsig = x(constpos);
		mseq = [ real( Signal.mseq( 1, : ) ); imag( Signal.mseq( 1, : ) ); ...
			real( Signal.mseq( 2, : ) ); imag( Signal.mseq( 2, : ) ) ];
		% try the first signal
		rsig_aligned_1 = alignsignals_tao( rsig, mseq( 1:2, : ), modulation );
		demodem = modem.qamdemod( Signal.hmodem );
		rseq_1 = demodem.demodulate( rsig_aligned_1.' ).';
		ber(1) = countErrors( double( Signal.seq( 1, :    ) ), rseq_1 );
		% try the second signal
		rsig_aligned_2 = alignsignals_tao( rsig, mseq( 3:4, : ), modulation );
		rseq_2 = demodem.demodulate( rsig_aligned_2.' ).';
		ber(2) = countErrors( double( Signal.seq( 2, :    ) ), rseq_2 );
		% select the best
		[ ber, minpos ] = min( ber );
		if minpos == 1
			rseq = rseq_1;
		else
			rseq = rseq_2;
		end;
	end
end


