function [ out, eps ] = TimingRecovery( rsig, params, aux )
%==========================================================================
% Retro compatibility
%==========================================================================
if nargin == 3
    [ out, eps ] = oldTimingRecovery( rsig, params, aux );
	fprintf('USED OLD TIMING RECOVERY!!\n')
    return;
end;

%==========================================================================
% Switch over timing recovery method
%==========================================================================
Npol = size( rsig, 1 );
eps = zeros( 1, Npol );
switch params.method
    case 'MMAprefilter'
        
        % Pre filter signal
        Npre = 16*1024;
        hf_pref = [ (-1).^(1:Npre), zeros( 1, size( rsig, 2 ) - Npre ) ];
        Hf_pref = repmat( fft( hf_pref ), 2, 1 );
        
        f = fftshift( linspace( -1, 1, size( rsig, 2 ) ) );
        Hf_pref = repmat( Fgauss( 4, 0.5, f ), Npol, 1 );
        
        rsigf = ifft( fft( rsig, [], 2 ) .* Hf_pref, [], 2 );
        
        startPos = 1;
        for pol = 1:Npol
            r = rsigf(pol, : );
            
            % Block length
            L = 2*1024;
            
            pos0 = ( startPos:( startPos + ( 2 * L + 1 )  - 1 ) );
            % Compute estimator
            pos = 1 + pos0;
            aux = abs( r( pos ) ).^0.77 .* exp( -1i * pos * pi ) + ...
                real( r( pos ) .* conj( r( pos - 1 ) ) ) .* ...
                exp( - 1i * ( pos - 0.5 ) * pi );
            eps( pol ) = angle( sum( aux ) ) / ( 2 * pi );
        end;
    case 'MMA'
        startPos = 1;
        for pol = 1:Npol
            r = rsig(pol, : );
            
            % Block length
            L = 2*1024;
            
            pos0 = ( startPos:( startPos + ( 2 * L + 1 )  - 1 ) );
            % Compute estimator
            pos = 1 + pos0;
            aux = abs( r( pos ) ).^0.77 .* exp( -1i * pos * pi ) + ...
                real( r( pos ) .* conj( r( pos - 1 ) ) ) .* ...
                exp( - 1i * ( pos - 0.5 ) * pi );
            eps( pol ) = angle( sum( aux ) ) / ( 2 * pi );
        end;
    case 'Lee'
        for pol = 1:Npol
            r = rsig(pol, : );
            
            % Block length
            L = 2048;
            if isfield( params, 'L' )
                L = params.L;
            end;
            
            pos0 = ( 1:min( ( 2 * L ), floor( ( size( r, 2 ) - 1 ) / 2 ) * 2 ) );
            % Compute estimator
            pos = 1 + pos0;
            x = abs( r( pos ) ).^2 .* exp( -1i * pos * pi ) + ...
                real( r( pos ) .* conj( r( pos - 1 ) ) ) .* exp( - 1i * ( pos - 0.5 ) * pi );
            eps( pol ) = angle( sum( x ) ) / ( 2 * pi );
            
        end;
        
        
    case 'Leeprefilter'
        f = fftshift( linspace( -1, 1, size( rsig, 2 ) ) );
        Hf_pref = repmat( Fgauss( 4, 0.5, f ), 2, 1 );
        
        rsigf = ifft( fft( rsig, [], 2 ) .* Hf_pref, [], 2 );
        
        for pol = 1:Npol
            r = rsigf(pol, : );
            
            % Block length
            L = 2048;
            if isfield( params, 'L' )
                L = params.L;
            end;
            
            pos0 = ( 1:min( ( 2 * L ), floor( ( size( r, 2 ) - 1 ) / 2 ) * 2 ) );
            % Compute estimator
            pos = 1 + pos0;
            x = abs( r( pos ) ).^2 .* exp( -1i * pos * pi ) + ...
                real( r( pos ) .* conj( r( pos - 1 ) ) ) .* exp( - 1i * ( pos - 0.5 ) * pi );
            eps( pol ) = angle( sum( x ) ) / ( 2 * pi );
            
        end;
    otherwise
        error( [ 'Timing recovery: Unknown method "' method '"' ] );
end;


%==========================================================================
% Apply phase shift to signal
%==========================================================================
f = fftshift( linspace( -params.sps / 2, ...
    params.sps / 2, size( rsig, 2 ) ) ); f = f - f(1);
out = zeros( size( rsig ) );
for pol = 1:Npol
    out( pol, : ) = ifft( fft( rsig(pol, : ) ) .* exp( -1i * 2 * pi * f * eps( pol ) ) );
end;
out = out( :, 2:end );
% out = CheckTiming( out, params.sps );








function [ out, eps ] = oldTimingRecovery( in, sps, params )
% Default output
out = zeros( size( in ) );
eps = 0;
% Default method
method = 'MagnitudeSquare';
if nargin == 3
    if isstruct( params )
        if isfield( params, 'method' )
            method = params.method;
        end;
    else
        method = params;
    end;
else
    params = struct();
end;

% Number of polarizations
Npol = size( in, 1 );

% Method
switch method
    case 'MagnitudeSquare'
        % From:
        % Wang, "16QAM Symbol timing recovery in the upstream transmission
        % of a DOCSIS standard, " PTL, Vo. 49, No. 2, June 2003
        
        for pol = 1:Npol
            
            L = 2^12;
            if isfield( params, 'L' )
                L = params.L;
            end;
            
            % Compute X1
            x1 = abs( in( pol, 1:L ) ).^2;
            X1 = fft( x1 );
            
            % Compute k - relevant sample
            k = L / sps;
            
            % Compute epsilon
            eps = - 1 / ( 2 * pi ) * angle( X1( k ) );
            
            % Normalized frequency
            f = fftshift( sps * linspace( -0.5, 0.5, size( in, 2 ) ) );
            f = f - f( 1 );
            
            % Retime signal
            out( pol, : ) = ifft( fft( in( pol, : ) ) .* ...
                exp( -1i * 2 * pi * f * eps ) );
        end;
        
        
    case 'DelayMultiplication'
        % From:
        % Wang, "16QAM Symbol timing recovery in the upstream transmission
        % of a DOCSIS standard, " PTL, Vo. 49, No. 2, June 2003
        
        for pol = 1:Npol
            L = 2^11;
            if isfield( params, 'L' )
                L = params.L;
            end;
            
            % Compute X2
            x2 = in( pol, ( sps + ( 1:L ) ) ) .* ...
                conj( in( pol, 1:L ) );
            X2 = fft( x2 );
            
            % Compute k - relevant sample
            k = L / sps;
            
            % Compute epsilon
            eps = - 1 / ( 2 * pi ) * ( angle( X2( k ) ) - pi );
            
            % Normalized frequency
            f = fftshift( sps * linspace( -0.5, 0.5, size( in, 2 ) ) );
            f = f - f( 1 );
            
            % Retime signal
            out( pol, : ) = ifft( fft( in( pol, : ) ) .* ...
                exp( -1i * 2 * pi * f * eps ) );
        end;
        
        
    case 'Lee'
        for pol = 1:Npol
            r = in(pol, : );
            
            if ~isfield( params, 'eps' )
                % Block length
                L = 2048;
                if isfield( params, 'L' )
                    L = params.L;
                end;
                
                pos0 = ( 1:min( ( 2 * L ), floor( ( size( r, 2 ) - 1 ) / 2 ) * 2 ) );
                % Compute estimator
                pos = 1 + pos0;
                x = abs( r( pos ) ).^2 .* exp( -1i * pos * pi ) + ...
                    real( r( pos ) .* conj( r( pos - 1 ) ) ) .* exp( - 1i * ( pos - 0.5 ) * pi );
                t( pol ) = angle( sum( x ) ) / ( 2 * pi );
            else
                t( pol ) = eps( pol );
            end;
        end;
        f = fftshift( linspace( -sps / 2, sps / 2, length( r ) ) ); f = f - f(1);
        for pol = 1:Npol
            out( pol, : ) = ifft( fft( in(pol, : ) ) .* exp( -1i * 2 * pi * f * t( pol ) ) );
        end;
        
    case 'MMA'
        for pol = 1:Npol
            r = in(pol, : );
            
            % Block length
            L = 2*1024;
            
            pos0 = ( 1:( 2 * L + 1 ) );
            % Compute estimator
            pos = 1 + pos0;
            x = abs( r( pos ) ).^0.77 .* exp( -1i * pos * pi ) + ...
                real( r( pos ) .* conj( r( pos - 1 ) ) ) .* exp( - 1i * ( pos - 0.5 ) * pi );
            t( pol ) = angle( sum( x ) ) / ( 2 * pi );
        end;
        f = fftshift( linspace( -sps / 2, sps / 2, length( r ) ) ); f = f - f(1);
        for pol = 1:Npol
            out( pol, : ) = ifft( fft( in(pol, : ) ) .* exp( -1i * 2 * pi * f * t( pol ) ) );
        end;
       
    case 'MMAAvg'
        r = in;
        % Block length
        L = 2*1024;
        pos0 = ( 1:( 2 * L + 1 ) );
        % Compute estimator
        pos = 1 + pos0;
        x = sum( abs( r( pos ) ).^0.5, 1 ) .* exp( -1i * pos * pi ) + ...
            real( sum( r( :, pos ) .* conj( r( :, pos - 1 ) ) ) ) .* exp( - 1i * ( pos - 0.5 ) * pi );
        t = angle( sum( x ) ) / ( 2 * pi );
        f = fftshift( linspace( -sps / 2, sps / 2, length( r ) ) ); f = f - f(1);
        for pol = 1:Npol
            out( pol, : ) = ifft( fft( in(pol, : ) ) .* exp( -1i * 2 * pi * f * t ) );
        end;
        
        eps = t;
        
    case 'LeeSH'
        pol = 1;
        r = in(pol, : );
        
        % Block length
        L = 2048;
        
        pos0 = ( 1:( 2 * L ) );
        % Compute estimator
        pos = 1 + pos0;
        x = abs( r( pos ) ).^2 .* exp( -1i * pos * pi ) + ...
            real( r( pos ) .* conj( r( pos - 1 ) ) ) .* exp( - 1i * ( pos - 0.5 ) * pi );
        t( pol ) = angle( sum( x ) ) / ( 2 * pi );
        f = fftshift( linspace( -sps / 2, sps / 2, length( r ) ) ); f = f - f(1);
        for pol = 1:Npol
            out( pol, : ) = ifft( fft( in(pol, : ) ) .* exp( -1i * 2 * pi * f * mean( t ) ) );
        end;
        
    
    case 'MMASH'
        pol = 1;
        r = in(pol, : );
        
        % Block length
        L = 512;
        
        pos0 = ( 1:( 2 * L ) );
        % Compute estimator
        pos = 1 + pos0;
        x = abs( r( pos ) ).^0.5 .* exp( -1i * pos * pi ) + ...
            real( r( pos ) .* conj( r( pos - 1 ) ) ) .* exp( - 1i * ( pos - 0.5 ) * pi );
        t( pol ) = angle( sum( x ) ) / ( 2 * pi );
        f = fftshift( linspace( -sps / 2, sps / 2, length( r ) ) ); f = f - f(1);
        for pol = 1:Npol
            out( pol, : ) = ifft( fft( in(pol, : ) ) .* exp( -1i * 2 * pi * f * mean( t ) ) );
        end;
        
    case 'Correlation'
        for pol = 1:Npol
            rsig = in( pol, : );
            msig = upsample( params.mseq, sps );
            xc = xcorr( rsig, msig );
            [ ~, posMax ] = max( abs( xc ) );
            posMax = posMax - ( ( length( xc ) - 1 ) / 2 );
            
            rsig = circshift( rsig, [ 0 -posMax ] );
            rsig = rsig( 1:length( msig ) );
            x = real( rsig ) .* conj( real( msig ) );
            X = fft( x );
            k = length( x ) / sps;
            eps = - 1 / ( 2 * pi ) * angle( X( k ) );
            
            % Normalized frequency
            f = fftshift( sps * linspace( -0.5, 0.5, size( in, 2 ) ) );
            f = f - f( 1 );
            
            % Retime signal
            out( pol, : ) = ifft( fft( in( pol, : ) ) .* ...
                exp( -1i * 2 * pi * f * eps ) );
        end;
        
    otherwise
        error( [ 'Timing recovery: Unknown method "' method '"' ] );
end;

out = CheckTiming( out, sps );

return





%%% SUPPORT FUNCTIONS %%%


function out = CheckTiming( in, sps )
npol = size( in, 1 );

outLens = zeros( 1, npol );
for pol = 1:npol
    errorMag = zeros( 1, sps );
    for n = 1:sps
        errorMag( n ) = sum( abs( in( pol, n:sps:end ) ).^2 );
    end;
    [ ~, bestPos ] = max( errorMag );
    temp{ pol } = in( pol, bestPos:end );
    outLens( pol ) = length( temp{ pol } );
end;
minLen = min( outLens );

out = zeros( npol, minLen );
for pol = 1:npol
    out( pol, : ) = temp{ pol }(1:minLen );
end;



function H = Fgauss(r, f3dB, f)
H=exp(log(sqrt(0.5))*(f/(f3dB)).^(2*r));
return


