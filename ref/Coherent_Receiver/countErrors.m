function [ curBER, curError, curBits, errorPos, outSeq ] = countErrors( sbin, rbin, showGraph )
if nargin == 2
	showGraph = 0;
end
tbin = [];
if size( sbin, 2 ) < size( rbin, 2 )
	% Extend original sequence
	for n = 1:ceil( size( rbin, 2 ) / size( sbin, 2 ) )
		tbin = [ tbin sbin ];
	end;
else
	tbin = sbin;
end;


% Cycle streams
curError = 0;
errorPos = zeros( 1, size( rbin, 2 ) );
for n = 1:size( rbin, 1 )
	% Synchronize sequences
	x = xcorr( tbin( 1, : )-mean( tbin( 1, : ) ), rbin( n, : )- mean( rbin( 1, : ) ) );
	if( showGraph )
		ofigure( 'Correlations' );
		subplot( size( rbin, 1 ), 1, n ), plot(x,'.-'), title( [ 'Corr ' n ] );
	end;
	
	
	[ maxx, pos ] = max( abs( x ) );
	xinv = sign( x( pos ) );
	pos = pos - ( length( x ) - 1 ) / 2 - 1;
	
	if xinv > 0
		tsbin = circshift( tbin, [ 0, -pos ] );
		outSeq = rbin;
	else
		tsbin = 1 - circshift( tbin, [ 0, -pos ] );
		outSeq = 1 - rbin;
	end;
	tsbin = tsbin( 1:length( rbin( 1, : ) ) );
	
	% Compare synchronized sequences
	% xxc = sum( ( tsbin - 0.5 ) .* ( rbin( n, : ) - 0.5 ) );
	
	
	
	aux = abs( tsbin - rbin(n,:) );
	errorPos = errorPos + aux;
	
	curError = curError + sum( aux );
	curBER = aux / length(rbin);
	
	if( showGraph )
		ofigure( 'Sequences' );
		m=(1:min(length(tsbin), 50000));
		subplot( size( rbin, 1 ), 1, n ), plot(m,tsbin(m),'b.-',m,rbin(n,m)+1.2,'r.-');
		legend('Tx', 'Rx' );
	end;
end;
curBits = numel( rbin );
curBER = curError / curBits;

if( showGraph )
	ofigure( 'Error Positions' );
	plot( errorPos, 'o' );
	title( 'Error Positions' );
end;

