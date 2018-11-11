function [trParms] = trTED(sigIn,trParms)
% Description:
%     timing error detector
% 
% EXAMPLE:
%     [sigOut] = trTED(sigIn,trParms)
%     
% INPUT:
%     sigIn        - Input signal
%     trParms      - Input TR parameters
%     
% OUTPUT:
%     trParms      - Input TR parameters
%     
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180927    H.B. Zhang    Create this script
% V1.1       20180929    H.B. Zhang    Add slicer for TED
% Ref:
%     http://www.eecg.toronto.edu/~tcc/thesis-musa-final.pdf
% 

sigIn                  = sigIn(:);
dataLen                = length(sigIn);

% parameters
mode                   = trParms.mode;  % {'MM','Gardner','Godard'}
sps                    = trParms.sps;   % sps = dsp.sps
modFormat              = trParms.modFormat; 
% Rs                     = trParms.Rs;
% sampleRate             = trParms.sampleRate;

% TED
switch lower(mode)
    case {'mm'} % working by 1sps, and use real part only
        tedSigIn       = reSample(real(sigIn),sps,1); % sigIn(1:sps:end); % downsaple to 1sps
        slcTedSigInTmp = slicer(tedSigIn,modFormat); % sign(tedSigIn);
        slcTedSigIn    = real(slcTedSigInTmp);
        tedTmp         = circshift(slcTedSigIn,1).*tedSigIn - slcTedSigIn.*circshift(tedSigIn,1);
        tedTmp2        = tedTmp(2:end-1);
        ted            = mean(tedTmp2);
    case {'godard'}
        tedSigIn       = reSample(sigIn,sps,2);
        fdSig          = fft(tedSigIn);
        halfLen        = floor(length(fdSig)/2);
        diffFdSig      = fdSig(1:halfLen) .* conj(fdSig(end-halfLen+1:end));
        ted            = imag(mean(diffFdSig));
    case {'gardner'}
        error('Error(in trTED.m): un-supported mode');
    otherwise
        error('Error(in trTED.m): un-supported mode');
end

trParms.ted            = [trParms.ted; ted];

end