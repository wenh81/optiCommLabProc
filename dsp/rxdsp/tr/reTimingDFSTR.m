function sigOut = reTimingDFSTR(sigIn,reTimingDFSTRParms)
% Description:
%     Timing recovery using digital filter with square timing recovery
%     altorithm.
%     It is one of feed-forward TR algorithms. Clock information comes from
%     the spectral phase of received signal with square law, which also
%     will introduce nonlinear distortion and much more wide signal
%     bandwith, so that 4sps at least is necessary in DFSTR TR algorithm.
% 
% EXAMPLE:
%     sigOut = reTimingDFSTR(sigIn,reTimingDFSTRParms)
% 
%     
% Input
%     sigIn              - input signal with 2sps
%     reTimingDFSTRParms - DFSTR parameters
%     
% Output
%     sigOut             - output timing recoveryed signal with 2sps
% 
% Copyright, 2018 (C), H.B. Zhang, <hongbo.zhang83@gmail.com>
% 
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180926    H.B. Zhang    Create this script
% 
% Ref:
%     1. Oerder M, Meyr H. Digital filter and square timing recovery[J]. 
%        IEEE Transactions on communications, 1988, 36(5): 605-612.
%     2. é¸év?. çÇë¨ëää±??ån?íÜêîéöêMçÜ?óùéZñ@å§ãÜ[D]. ñkãû??ëÂäw, 2015.

sigIn                  = sigIn(:);

% Parameters
symbolRate             = reTimingDFSTRParms.symbolRate;
numPerBlk              = reTimingDFSTRParms.numPerBlk;      % 1024
numAveDFSTR            = reTimingDFSTRParms.numAveDFSTR;    % 512
interpAlgorithm        = reTimingDFSTRParms.interpAlgorithm;% {'interp1','interpft'}
interpMethod           = reTimingDFSTRParms.interpMethod;   % {'cubic','linear','spline','pchip','nearest','v5cubic'}
sps                    = reTimingDFSTRParms.sps;

% 4sps at least is necessary for interp
interpSps              = 4;
dataLen                = length(sigIn);
Ts                     = 1/symbolRate;
tPerInsps               = [0:1:(dataLen-1)].' * Ts/sps;
tPer4sps               = [0:1:(interpSps/sps)*dataLen-1].' * Ts/interpSps;

% interp to get 4sps signal
switch lower(interpAlgorithm)
    case {'interp1'}
        sig4sps        = interp1(tPerInsps,sigIn,tPer4sps,interpMethod);
    case {'interpft'}
        sig4sps        = interpft(sigIn,dataLen*(interpSps/sps));
    otherwise
        error('Error(in retimingDFSTR.m): un-supported interp algorithm');
end

% generate block timing estimator
% determine estimate of delay
numBlk                 = fix(length(sig4sps) / numPerBlk);

% calc power
sigSeq                 = abs(sig4sps).^2;
sigSum                 = zeros(numBlk, 1);

% integrator
for iNumBlk = 1:numBlk
    sumTmp  = 0;
    for iNumPerBlk = 1:numPerBlk-1
        sumTmp = sumTmp + sigSeq( (iNumBlk-1)*numPerBlk + iNumPerBlk+1 ) * exp(-1i*2*pi*iNumPerBlk/4);
    end
    sigSum(iNumBlk) = sumTmp;
end

% smooth signal
filtSigSum             = filter(ones(numAveDFSTR,1)/numAveDFSTR, 1, sigSum);
tauSigSeq              = -1/2/pi * unwrap(angle(filtSigSum));

% calc values of time delay
rSig                   = sum( exp(1i*2*pi*tauSigSeq) );
tauSig_s               = Ts/2/pi * atan2(imag(rSig), real(rSig));
tauSig_m               = Ts * mean(tauSigSeq);

% choose tau value
tauSig                 = tauSig_m;

% interp samples using estimated delays
timeSig                = tPer4sps + tauSig;
sig4spsTR              = interp1(tPer4sps, sig4sps, timeSig, interpMethod);

% down sample to 2sps
sig2spsTR              = downsample(sig4spsTR, sps, 0);

sigOut                 = sig2spsTR;
% check delay after retiming


end