% Description:
%     cfgOfflineSSB.m
% 
% EXAMPLE:
%     
%     
% INPUT:
%     Input        - none
%     
% OUTPUT:
%     Output       - none
% 
%  Copyright, 2018, H.B. Zhang, <hongbo.zhang83@gmail.com>
%
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180920    H.B. Zhang    Create this script
% V1.1       20181108    H.B. Zhang    Add pfLmsParms, mlParms, version info
% 
% Ref:
%     

% platform information
vP.verInfo.verNo       = 'B001T000';
vP.verInfo.date        = '20181108';
vP.sysModeStr          = 'offline';
vP.verInfo.projName    = 'TOKAISSB';
vP.verInfo.author      = 'Zhang Hongbo';
vP.verInfo.email       = 'hongbo.zhang83@gmail.com';

% warning setting
warning('OFF','comm:shared:willBeRemoved');

% set offset frequency here
rfFreq                 = oflDataParms.rfFreq;   % frequency offset
fBaud                  = oflDataParms.fBaud; % Signal.Rs; % 2.5GBd-QPSK, 6.25G-16QAM
Signal.scoperate       = oflDataParms.scoperate;
Scope.scoperate        = Signal.scoperate;

% ctroller
isCMA                  = 1;
isLMS                  = 1;
isPfEqua               = 1;

% samples per symbol in equalizer
dsp.rxDataLen          = rxDataLen;
dsp.M                  = oflDataParms.M; 
dsp.fBaud              = fBaud;
dsp.sps                = 2;
dsp.fs                 = dsp.fBaud * dsp.sps;
aux                    = modem.qammod('M', dsp.M );
modFormatStrTmp        = strsplit(aux.Type);
modFormat              = strcat(num2str(aux.M),'-',modFormatStrTmp{1});
dsp.modFormat          = modFormat;
dsp.constScale         = rms(aux.Constellation);
dsp.const              = aux.Constellation / dsp.constScale;

% TR parameters
trParms.bypass         = 1;
trParms.modFormat      = dsp.modFormat;
trParms.Rs             = fBaud;
trParms.sampleRate     = Scope.scoperate;
trParms.sps            = trParms.sampleRate/trParms.Rs;
trParms.trPPM          = 0;
trParms.mode           = 'godard'; % TED method: {'mm','godard'}
trParms.lenBlk         = 2^7;
trParms.bufferLen      = 3*trParms.lenBlk;
trParms.buffer         = zeros(trParms.bufferLen,1);
trParms.ted            = [];
m                      = 8;
f3dB                   = 1e6;  % Hz, bandwidth of TR loop
Kted                   = trParms.sampleRate;
Knco                   = 1/trParms.lenBlk;
Kp                     = 2*pi*f3dB/Kted/Knco;
Ki                     = (2*pi*f3dB)^2/Kted/Knco/(m*trParms.sampleRate);
Kpd                    = 1;
if strcmpi(trParms.mode,'godard')
    Kpd                = 1/10;
end
trParms.kp             = Kp*Kpd;
trParms.ki             = Ki*Kpd;
trParms.fbrt1st        = 0;
trParms.fbrt2st        = 0;
trParms.fbrtDly        = 0;
trParms.clkBufShift    = 0;
trParms.digitalT       = 0;
trParms.interpMethod   = 'PCHIP';   % {'cubic','linear','spline','pchip','nearest','v5cubic'}
% TR lock indicator parameters
lckParms.lckDelay      = 1000;
lckParms.bypass        = trParms.bypass;
lckParms.lenBuffer     = 2000;
lckParms.lckTh         = 0.05;
lckParms.lckCntTh      = 2000;
if strcmpi(trParms.mode,'godard')
    lckParms.lckTh    = 0.01;
end
lckParms.isLocked      = 0;
lckParms.lckBuffer     = zeros(lckParms.lenBuffer,1);
lckParms.aveBufferLast = 0;
lckParms.lckCnt        = 0;
lckParms.lckCounter    = 0;
lckParms.lckBlkIdx     = [];
lckParms.aveDiffMat    = [];
trParms.lckParms       = lckParms;

% Kramers Kronig Receiver parameters
kkRxParms.CSPR         = 50;         % dB, CSPR = 10*log10(Pa/Ps)
kkRxParms.bypass       = 0;          % 1 --> w/o KK; 0 --> w/i KK

% CMA parameters
cmaParms.bypass        = 0;
equlizerTapNum         = 17;
cmaParms.modFormat     = dsp.modFormat;
cmaParms.constScale    = dsp.constScale;
cmaParms.sps           = dsp.sps;
cmaParms.dspSps        = dsp.sps;
cmaParms.tapNum        = equlizerTapNum;
cmaParms.mu            = 1e-3;
cmaParms.stepAdaptive  = 1;
cmaParms.const         = dsp.const;
cmaParms.weightP       = [1.0; 1.0; 1.0];
cmaParms.gammaOffst    = [-0.0; 0; +0.0];
cmaParms.errArr        = 0;
cmaParms.Wxx           = zeros(cmaParms.tapNum,1);
cmaParms.Wxx(floor(cmaParms.tapNum/2)+1) = 1;
dsp.cmaParms           = cmaParms;

% LMS parameters
lmsParms.bypass        = 0;
lmsParms.Npass         = 3;
lmsParms.modFormat     = dsp.modFormat;
lmsParms.const         = dsp.const;
lmsParms.constScale    = dsp.constScale;
lmsParms.sps           = dsp.sps;
lmsParms.fBaud         = fBaud;
lmsParms.tapNum        = equlizerTapNum;
lmsParms.tapOfst       = 0;
lmsParms.mu            = 2e-4;
lmsParms.stepAdaptive  = 0;
lmsParms.errArr        = 0;
lmsParms.errAveLen     = 1;
lmsParms.mode          = 'slide'; % {fixed, slide} % DO NOT support now
lmsParms.Wxx           = zeros(lmsParms.tapNum,1);
lmsParms.Wxx(floor(lmsParms.tapNum/2)+1+lmsParms.tapOfst) = 1;
lmsParms.freqOffst     = 0;

% CR
crParms.bypass         = 0;  % CR out of LMS loop
lmsParms.interCrBypass = 1;  % CR in LMS loop: there is some problem here
crParms.modFormat      = modFormat;
crParms.fBaud          = fBaud;
crParms.sps            = lmsParms.sps;
crParms.lenBlk         = 1;
crParms.m              = 3;
crParms.f3dB           = 10e6;  % Hz, bandwidth of CR loop
crParms.cr1st          = 0;
crParms.cr2st          = 0;
crParms.theta          = 0;
crParms.fo             = 0;
% CR lock indicator parameters
lckParms.lckDelay      = 1e4;
lckParms.bypass        = crParms.bypass;
lckParms.lenBuffer     = 1000;
lckParms.lckCntTh      = 1000;
lckParms.lckThFo       = 8e6;    % Hz
lckParms.lckTh         = lckParms.lckThFo * 2*pi/(crParms.sps * fBaud);
lckParms.isLocked      = 0;
lckParms.lckBuffer     = zeros(lckParms.lenBuffer,1);
lckParms.aveBufferLast = 0;
lckParms.lckCnt        = 0;
lckParms.lckCounter    = 0;
lckParms.lckBlkIdx     = [];
lckParms.aveDiffMat    = [];
crParms.lckParms       = lckParms;
lmsParms.crParms       = crParms;
dsp.lmsParms           = lmsParms;
% clear lckParms;

% post-LMS equalization: working in 1SPS
postLmsParms           = lmsParms;
postLmsParms.bypass    = 0;
postLmsParms.sps       = 1;
postLmsParms.mu        = 1e-6;
postLmsParms.crParms.sps = postLmsParms.sps;

% phase folded LMS equalizer in 1SPS
pfLmsParms             = lmsParms;
pfLmsParms.sps         = 1;
pfLmsParms.tapNum      = 17;
pfLmsParms.mu          = 1e-5;
pfLmsParms.Wxx         = zeros(pfLmsParms.tapNum,1);
pfLmsParms.Wxx(floor(pfLmsParms.tapNum/2)+1) = 1;
pfLmsParms.is4QAM      = 1;  % select 16QAM or 4QAM equalization in PF-LMS
dsp.pfLmsParms         = pfLmsParms;

% Coarse Frequency offset estimation and compensation parameters
coarseFreqOffstEstParms.bypass  = 0;
coarseFreqOffstEstParms.lenData = [];
coarseFreqOffstEstParms.fBaud = fBaud;
coarseFreqOffstEstParms.fs    = Scope.scoperate;
coarseFreqOffstEstParms.freqResolution = 1e3; % 1Hz corresp. to fs
coarseFreqOffstEstParms.modFormat      = modFormat;
coarseFreqOffstEstParms.initPhase      = 0;
coarseFreqOffstEstParms.freqOffset     = 0;

% Fine Frequency offset estimation parameters
fineFreqOffstEstParms.modFormat = modFormat;
dsp.fineFreqOffstEstParms       = fineFreqOffstEstParms;

% Feed-forward frequency offset compensation by VVPE
ffFocVvpeParms.bypass     = 0;
ffFocVvpeParms.constScale = dsp.constScale;
ffFocVvpeParms.blkLen     = 32;
dsp.ffFocVvpeParms        = ffFocVvpeParms;

% phase compensation using ML algorithm
pnCompMLParms.bypass     = 0;
pnCompMLParms.modFormat  = dsp.modFormat;
pnCompMLParms.constScale = dsp.constScale;
pnCompMLParms.blkLen     = 8;
dsp.pnCompMLParms        = pnCompMLParms;

% OSA-BPS for optical synthesizing approach
bps4OptiSynthParms.bypass = 0;
bps4OptiSynthParms.Nangle = 128;     % 64
bps4OptiSynthParms.const  = dsp.const; % dsp.const
bps4OptiSynthParms.constScale = dsp.constScale; % dsp.constScale
bps4OptiSynthParms.method = 1;     % you'd better DO NOT change this value
dsp.bps4OptiSynthParms = bps4OptiSynthParms;

% calc BER
aux                    = modem.qammod( 4 );
constScaleQPSK         = rms(aux.Constellation);
constQPSK              = aux.Constellation / constScaleQPSK;
calcBerParms.constScaleQPSK = constScaleQPSK;
calcBerParms.constQPSK   = constQPSK.';
calcBerParms.modFormat   = dsp.modFormat;
calcBerParms.M           = dsp.M;
calcBerParms.Signal      = Signal;
calcBerParms.demodem     = modem.qamdemod( Signal.hmodem );

% warning setting
warning('ON','comm:shared:willBeRemoved');

%% collect global settings information
vP.glb.modFormat       = dsp.modFormat;
vP.glb.bitsPerSymbol   = log2(dsp.M);
vP.glb.fBaud           = Signal.Rs;
vP.glb.bitrate         = vP.glb.fBaud * vP.glb.bitsPerSymbol;
vP.glb.isEqualization  = isLMS;
print_sim_info;