function [ rsig_aligned, mseq_extended ] = alignsignals_tao( rsig, mseq,modulation )
	
	nsymb = size( mseq, 2 );
	
	% mseq = double( Signal.mseq );
	nrep = ceil( size( rsig, 2 ) / nsymb );
	mseq = double( repmat( mseq, 1, nrep ) );
	
   if strcmp(modulation, '16_QAM')   
	% Extend received sequence
	rsigx = [ ...
		real( rsig( 1, : ) );...
		imag( rsig( 1, : ) ); ...
		real( rsig( 2, : ) ); ...
		imag( rsig( 2, : ) ) ];
    M = 4;
   else strcmp(modulation, 'QPSK')
       	rsigx = [ ...
		real( rsig( 1, : ) );...
		imag( rsig( 1, : ) )];
    M = 2;
   end
	
	% Align each component of the received sequence
	cursources = [];
	counter = 1;
	for comp = 1:M
		% Find the nearest source
		curmax = 0;
		curpos = 0;
		cursign = 0;
		for source = 1:M
			xc = xcorr( rsigx( source, : ), mseq( comp, : ) );
			[ maxxc, maxpos ] = max( abs( xc ) );
			if maxxc > curmax
				curmax = maxxc;
				curpos = maxpos;
				cursign = sign( xc( maxpos ) );
				cursource = source;
			end;
			
% 			figure( 10 );
% 			subplot( 4, 4, counter );
% 			plot( xc ); counter = counter + 1;
		end
		curpos = curpos - ( length( xc ) - 1 ) / 2;
		while curpos <= 0
			curpos = curpos + nsymb;
		end;
		
		% Found the best source for the first mseq, align it
		if ~isempty( find( cursource == cursources ) )
			warning( 'Error recovering signal - Could not match with the original sequences.' );
			mseq_extended = [];
			rsig_aligned = [];
			Signal.BER = 2;
			return;
		end;
		cursources = [ cursources cursource ];
		rsig_aligned0{ comp } = cursign * rsigx( cursource, curpos:end );
		
		% Memorize minimum length
		lens( comp ) = length( rsig_aligned0{ comp } );
	end
	
	% Save minimum length
	minlen = min( lens );
	
	
	% Reconstruct complex signal
    if strcmp(modulation, '16_QAM')   
	rsig_aligned = [ ...
		complex( rsig_aligned0{1}(1:minlen), rsig_aligned0{2}(1:minlen) ); ...
		complex( rsig_aligned0{3}(1:minlen), rsig_aligned0{4}(1:minlen) ) ];
    else strcmp(modulation, 'QPSK')
	rsig_aligned = [ ...
		complex( rsig_aligned0{1}(1:minlen), rsig_aligned0{2}(1:minlen) )]; 
    end
    
	mseq_extended = repmat( mseq, 1, nrep );
	mseq_extended = mseq_extended( :, 1:size( rsig_aligned, 2 ) );
	
	