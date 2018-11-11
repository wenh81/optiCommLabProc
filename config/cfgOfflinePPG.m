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
% V1.0       20180925    H.B. Zhang    Create this script
% Ref:
%

%% save log
load rootPath.mat;
[~,OflfileNameHeader]  = fileparts(OflfileName);
logFileName            = sprintf('%s_%s.txt','logs',OflfileNameHeader);
logFilePath            = fullfile(rootPath,'logs');
logFullFilePath        = fullfile(logFilePath,logFileName);
if ~checkDirExist(logFilePath)
    mkdir(logFilePath);
end
diary(logFullFilePath);
diary on;

% loading configure
fprintf('- loading configuration ...\n');

% warning setting
% warning('OFF','comm:shared:willBeRemoved');
warning('OFF');

%% Global settings
% choose ref bits
refBitsNum             = 1;
refBitsFile            = {'prbs23_18','prbs7_6','prbs7_4'};
load(refBitsFile{refBitsNum});
vP.refBits             = refBits;
vP.lenRefBits          = length(refBits);

% platform information
vP.verInfo.verNo       = 'B002T002';
vP.verInfo.date        = '20181025';
vP.sysModeStr          = 'offline';
vP.verInfo.projName    = 'TOKAIIMDD';
vP.verInfo.author      = 'Zhang Hongbo';
vP.verInfo.email       = 'hongbo.zhang83@gmail.com';

%% ctroller
isLMS                  = 1;

%% transmitter settings
fBaud                 = 10e9;   % symbol rate
Signal.Rs             = fBaud;   % symbol rate

%% receiver settings
% samples per symbol in equalizer
dsp.Sps                = Scope.scoperate/Signal.Rs;
dsp.sps                = 2;
dsp.M                  = 4;                     % PAM-M,MPAM
aux                    = modem.pammod( 'M',dsp.M );
modFormatStrTmp        = strsplit(aux.Type);
modFormat              = strcat(num2str(aux.M),'-',modFormatStrTmp{1});
dsp.modFormat          = modFormat;
dsp.constScale         = rms(aux.Constellation);
dsp.const              = aux.Constellation / dsp.constScale;

% DC block
dcBlockParms.mu        = 1-1/1e4;
dcBlockParms.lenBlk    = 100;

% AGC for DSP
% agc                    = comm.AGC;  % MATLAB2018a provided comm.AGC
% agc.AdaptationStepSize = 1e-4;
% agc.DesiredOutputPower = rms(dsp.const)^2;
agcParms.lenBlk          = 100;
agcParms.mu              = 5e-3;
agcParms.tgtPwrRms       = rms(dsp.const);
agcParms.initGain        = 1;
agcParms.gain            = [];
% AGC lock indicator parameters
lckParms.lenBuffer     = 300;
lckParms.lckTh         = 0.01;
lckParms.lckCntTh      = 100;
lckParms.isLocked      = 0;
lckParms.lckBuffer     = zeros(lckParms.lenBuffer,1);
lckParms.aveBufferLast = 0;
lckParms.lckCnt        = 0;
lckParms.lckCounter    = 0;
lckParms.lckBlkIdx     = 0;
lckParms.aveDiffMat    = [];
agcParms.lckParms      = lckParms;
clear lckParms;

% TR parameters
trParms.bypass         = 0;
trParms.modFormat      = dsp.modFormat;
trParms.Rs             = Signal.Rs;
trParms.sampleRate     = Scope.scoperate;
trParms.sps            = trParms.sampleRate/trParms.Rs;
trParms.trPPM          = 0;
trParms.mode           = 'MM';
trParms.lenBlk         = 200;
trParms.bufferLen      = 3*trParms.lenBlk;
trParms.buffer         = zeros(trParms.bufferLen,1);
trParms.ted            = [];
m                      = 1;
f3dB                   = 2e6;  % Hz, bandwidth of TR loop
Kted                   = Scope.scoperate;
Knco                   = 1/trParms.lenBlk;
Kp                     = 2*pi*f3dB/Kted/Knco;
Ki                     = (2*pi*f3dB)^2/Kted/Knco/(m*Scope.scoperate);
trParms.kp             = Kp;
trParms.ki             = Ki;
trParms.fbrt1st        = 0;
trParms.fbrt2st        = 0;
trParms.fbrtDly        = 0;
trParms.clkBufShift    = 0;
trParms.digitalT       = 0;
trParms.interpMethod   = 'PCHIP';   % {'cubic','linear','spline','pchip','nearest','v5cubic'}
% TR lock indicator parameters
lckParms.lenBuffer     = 2000;
lckParms.lckTh         = 0.02;
lckParms.lckCntTh      = 1000;
lckParms.isLocked      = 0;
lckParms.lckBuffer     = zeros(lckParms.lenBuffer,1);
lckParms.aveBufferLast = 0;
lckParms.lckCnt        = 0;
lckParms.lckCounter    = 0;
lckParms.lckBlkIdx     = 0;
lckParms.aveDiffMat    = [];
trParms.lckParms       = lckParms;
clear lckParms;

% Kramers Kronig Receiver parameters
kkRxParms.CSPR         = 10;         % dB, CSPR = 10*log10(Pa/Ps)
kkRxParms.bypass       = 0;          % 1 --> w/o KK; 0 --> w/i KK

% LMS parameters
lmsParms.modFormat     = dsp.modFormat;
lmsParms.const         = dsp.const;
lmsParms.constScale    = dsp.constScale;
lmsParms.sps           = dsp.sps;
lmsParms.fBaud         = fBaud;
lmsParms.tapNum        = 17;
lmsParms.tapOfst       = 0;
lmsParms.mu            = 0.3e-4;
lmsParms.stepAdaptive  = 0;
lmsParms.errArr        = 0;
lmsParms.errAveLen     = 1;
lmsParms.mode          = 'slide'; % {fixed, slide}
lmsParms.Wxx           = zeros(lmsParms.tapNum,1);
lmsParms.Wxx(floor(lmsParms.tapNum/2)+1+lmsParms.tapOfst) = 1;
lmsParms.freqOffst     = 0;
dsp.lmsParms           = lmsParms;
% CR
crParms.bypass         = 0;
crParms.modFormat      = modFormat;
crParms.fBaud          = fBaud;
crParms.sps            = dsp.sps;
crParms.lenBlk         = 1;
m                      = 3;
f3dB                   = 2e5;  % Hz, bandwidth of CR loop
Kted                   = fBaud*dsp.sps;
Knco                   = 1/crParms.lenBlk;
Kp                     = 2*pi*f3dB/Kted/Knco;
Ki                     = (2*pi*f3dB)^2/Kted/Knco/(m*fBaud);
crParms.kp             = Kp;
crParms.ki             = Ki;
crParms.cr1st          = 0;
crParms.cr2st          = 0;
crParms.theta          = 0;
crParms.fo             = 0;
lmsParms.crParms       = crParms;
dsp.lmsParms           = lmsParms;

% Coarse Frequency offset estimation and compensation parameters
coarseFreqOffstEstParms.bypass  = 1;
coarseFreqOffstEstParms.lenData = [];
coarseFreqOffstEstParms.fBaud = fBaud;
coarseFreqOffstEstParms.fs    = fBaud*dsp.sps;
coarseFreqOffstEstParms.freqResolution = 1e3; % 1Hz corresp. to fs
coarseFreqOffstEstParms.modFormat      = modFormat;
coarseFreqOffstEstParms.initPhase      = 0;
coarseFreqOffstEstParms.freqOffset     = 0;

% Fine Frequency offset estimation parameters
fineFreqOffstEstParms.modFormat = modFormat;
dsp.fineFreqOffstEstParms      = fineFreqOffstEstParms;


% set scope sample rate
Signal.scoperate       = Scope.scoperate;
% set offset frequency here
rfFreq                 = 0e9;   %% frequency offset 7.5

% warning setting
% warning('ON','comm:shared:willBeRemoved');
warning('ON');

%% collect global settings information
vP.glb.modFormat       = dsp.modFormat;
vP.glb.bitsPerSymbol   = log2(dsp.M);
vP.glb.fBaud           = Signal.Rs;
vP.glb.bitrate         = vP.glb.fBaud * vP.glb.bitsPerSymbol;
vP.glb.isEqualization  = isLMS;

print_sim_info;