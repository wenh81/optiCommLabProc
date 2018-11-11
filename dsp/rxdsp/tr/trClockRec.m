function [sigOut,trParms] = trClockRec(sigIn,trParms)
% Description:
%     Timing clock recovery
%
% EXAMPLE:
%     [sigOut,trParms] = trClockRec(sigIn,trParms)
%
% Parameters
%     trParms.bypass         - by pass signal
%     trParms.sps            = dsp.sps;
%     trParms.modFormat      = dsp.modFormat;
%     trParms.Rs             = Signal.Rs;
%     trParms.sampleRate     = Scope.scoperate;
%     trParms.trPPM          = 0;
%     trParms.mode           = 'MM';
%     trParms.lenBlk         = 200;
%     trParms.bufferLen      = 3*trParms.lenBlk;
%     trParms.buffer         = zeros(trParms.bufferLen,1);
%     trParms.ted            = [];
%     m                      = 1;
%     f3dB                   = 2e6;  % Hz, bandwidth of TR loop
%     Kted                   = Scope.scoperate;
%     Knco                   = 1/trParms.lenBlk;
%     Kp                     = 2*pi*f3dB/Kted/Knco;
%     Ki                     = (2*pi*f3dB)^2/Kted/Knco/(m*Scope.scoperate);
%     trParms.kp             = Kp;
%     trParms.ki             = Ki;
%     trParms.fbrt1st        = 0;
%     trParms.fbrt2st        = 0;
%     trParms.fbrtDly        = 0;
%     trParms.clkBufShift    = 0;
%     trParms.digitalT       = 0;
%     trParms.interpMethod   = 'PCHIP';   % {'cubic','linear','spline','pchip','nearest','v5cubic'}
%     % TR lock indicator parameters
%     lckParms.lenBuffer     = 2000;
%     lckParms.lckTh         = 0.01;
%     lckParms.lckCntTh      = 1000;
%     lckParms.isLocked      = 0;
%     lckParms.lckBuffer     = zeros(lckParms.lenBuffer,1);
%     lckParms.aveBufferLast = 0;
%     lckParms.lckCnt        = 0;
%     lckParms.lckCounter    = 0;
%     lckParms.lckBlkIdx     = 0;
%     lckParms.aveDiffMat    = [];
%     trParms.lckParms       = lckParms;
%
% INPUT:
%     sigIn        - Input signal
%     trParms      - Input TR parameters
%
% OUTPUT:
%     sigOut       - clock recoveryed signal
%     trParms      - Input TR parameters
%
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180927    H.B. Zhang    Create this script
%
% Ref:
%

% parameters
bypass                 = trParms.bypass;
bufferLen              = trParms.bufferLen;
buffer                 = trParms.buffer;
lenBlk                 = trParms.lenBlk;
kp                     = trParms.kp;
ki                     = trParms.ki;
fbrt2st                = trParms.fbrt2st;
clkBufShift            = trParms.clkBufShift;
digitalT               = trParms.digitalT;
interpMethod           = trParms.interpMethod;
lckParms               = trParms.lckParms;

% calc parameters
dataLen                = length(sigIn);
numBlk                 = fix(dataLen/lenBlk);
sigIn                  = sigIn(end-numBlk*lenBlk+1:end);
sigInMat               = reshape(sigIn, lenBlk, numBlk);
sigOutMat              = sigInMat*0;

% pre-allocation
fbrt1stMat             = zeros(numBlk,1);
fbrt2stMat             = zeros(numBlk,1);
fbrtTmpMat             = zeros(numBlk,1);
clkBufShiftMat         = zeros(numBlk,1);
digitalTMat            = zeros(numBlk,1);

%
sigInTR                = sigInMat(:,1);
buffer                 = fifoBuffer(buffer,sigInTR); % for interp

% by pass or not
if (bypass == 1)
    sigOut             = sigIn;
    trParms.fbrt1stMat     = fbrt1stMat;
    trParms.fbrt2stMat     = fbrt2stMat;
    trParms.trPPM          = fbrt2stMat*1e6;
    trParms.fbrtTmpMat     = fbrtTmpMat;
    trParms.clkBufShiftMat = clkBufShiftMat;
    trParms.digitalTMat    = digitalTMat;
    trParms.lckParms       = lckParms;
    fprintf('- TR is bypassed ...\n\n');
    return;
end

for iBlk = 1:numBlk
    % integer samples shift
    if clkBufShift < 0
        idxBufShift    = [bufferLen+((clkBufShift+1):0) 1:(bufferLen+clkBufShift)];
    else
        idxBufShift    = [((clkBufShift+1):bufferLen) 1:clkBufShift];
    end
    reTimingBuffer     = buffer;
    reTimingBuffer     = reTimingBuffer(idxBufShift);
    
    % fractional interp
    tOrig              = [1:1:bufferLen].';
    tDly               = tOrig + digitalT*2;
    sigOutTmp          = interp1(tOrig,reTimingBuffer,tDly,interpMethod,'extrap');
    sigOutTmp2         = sigOutTmp((1:lenBlk)+lenBlk);
    sigOutMat(:,iBlk)  = sigOutTmp2(:);
    
    sigInTRTmp         = sigInMat(:,iBlk);
    buffer             = fifoBuffer(buffer,sigInTR); % for interp
    sigInTR           = sigInTRTmp;
    
    % timing error detection
    trParms            = trTED(sigOutMat(:,iBlk),trParms);
    
    % loop filter
    fbrt1st            = kp*trParms.ted(end);
    fbrt2st            = fbrt2st + ki*trParms.ted(end);
    fbrtTmp            = fbrt1st + fbrt2st;
    
    % save for debug
    fbrt1stMat(iBlk)   = fbrt1st;
    fbrt2stMat(iBlk)   = fbrt2st/lenBlk;  % offset point per sample
    fbrtTmpMat(iBlk)   = fbrtTmp;
    
    % time delay
    digitalT           = digitalT + fbrtTmp;
    
    % interp for clock recovery
    if (digitalT) <= -0.6
        clkBufShift    = clkBufShift - 1;
        digitalT       = digitalT + 0.5;
    elseif (digitalT) >= 0.1
        clkBufShift    = clkBufShift + 1;
        digitalT       = digitalT - 0.5;
    else
        % do nothing
    end
    
    % save for debug
    clkBufShiftMat(iBlk) = clkBufShift;
    digitalTMat(iBlk)  = digitalT;
    
    fbrt2stPpm         = fbrt2st/lenBlk*1e6;
    lckParms           = lockIndicator(fbrt2stPpm,lckParms);
    sigBlkOutIdx       = lckParms.lckBlkIdx;
end
sigOutTmp              = sigOutMat(:);

if (lckParms.isLocked == 1)
    sigOut             = sigOutTmp(sigBlkOutIdx*lenBlk+1:end);
    
    fprintf('%s%d\n','- TR block length: ',lenBlk);
    fprintf('%s%d\n','- TR locked at TR input block: #',lckParms.lckBlkIdx);
    fprintf('%s%d\n\n','- TR locked at TR input sample: #',lenBlk*lckParms.lckBlkIdx);
else
    sigOut             = [];
    
    fprintf('%s\n\n','- Timing recovery failed, pause for debug ...');
    clf;
    plot(fbrt2stMat*1e6);
    keyboard;
end

% calc TR ppm
trPPM                  = fbrt2stMat*1e6;  % convert to PPM

% collect TR parameters
trParms.fbrt1stMat     = fbrt1stMat;
trParms.fbrt2stMat     = fbrt2stMat;
trParms.trPPM          = trPPM;
trParms.fbrtTmpMat     = fbrtTmpMat;
trParms.clkBufShiftMat = clkBufShiftMat;
trParms.digitalTMat    = digitalTMat;
trParms.lckParms       = lckParms;
end