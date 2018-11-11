function out = Orthonormalization( in, sps )
for m = 1:size( in, 1 )
	I = real( in( m, : ) ) - mean( real( in( m, : ) ) );
	Q = imag( in( m, : ) ) - mean( imag( in( m, : ) ) );
	
	PI = mean( I.^2 );
	PQ = mean( Q.^2 );
	ro = mean( I .* Q );
	out( m, : ) = I / sqrt( PI ) + 1i * ( Q - ro * I / PI ) / sqrt( PQ );
	out( m, : ) = out( m, : ) - mean( out( m, 1:sps:end ) );
	out( m, : ) = out( m, : ) / sqrt( mean( abs( out( m, 1:sps:end ) ).^2 ) );
end
return