% Description:
%     configurations for RxDSP of QPSK
%
% EXAMPLE:
%     cfgOfflineSCQPSK
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
% V1.0       20181005    H.B. Zhang    Create this script
% Ref:
%

% save log
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
% platform information
vP.verInfo.verNo       = 'B001T001';
vP.verInfo.date        = '20181005';
vP.sysModeStr          = 'offline';
vP.verInfo.projName    = 'CUITCoQPSK';
vP.verInfo.author      = 'Zhang Hongbo';
vP.verInfo.email       = 'hongbo.zhang83@hotmail.com';

%% ctroller
isCMA                  = 1;

%% transmitter settings
Signal.Rs             = 2.5e9;   % symbol rate
Scope.scoperate       = 12.5e9;

%% receiver settings
% samples per symbol in equalizer
dsp.Sps                = Scope.scoperate/Signal.Rs;
dsp.sps                = 2;
dsp.M                  = 4;                     % PAM-M,MPAM
aux                    = modem.pskmod( 'M',dsp.M );
modFormatStrTmp        = strsplit(aux.Type);
dsp.modFormat          = strcat(num2str(aux.M),'-',modFormatStrTmp{1});
dsp.const              = aux.Constellation;

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
trParms.sps            = dsp.sps;
trParms.modFormat      = dsp.modFormat;
trParms.Rs             = Signal.Rs;
trParms.sampleRate     = Scope.scoperate;
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
lckParms.lenBuffer     = 200;
lckParms.lckTh         = 0.02;
lckParms.lckCntTh      = 100;
lckParms.isLocked      = 0;
lckParms.lckBuffer     = zeros(lckParms.lenBuffer,1);
lckParms.aveBufferLast = 0;
lckParms.lckCnt        = 0;
lckParms.lckCounter    = 0;
lckParms.lckBlkIdx     = 0;
lckParms.aveDiffMat    = [];
trParms.lckParms       = lckParms;
clear lckParms;

% CMA parameters
cmaParms.modFormat     = dsp.modFormat;
cmaParms.sps           = dsp.sps;
cmaParms.tapNum        = 17;
cmaParms.tapOfst       = 0;
cmaParms.mu            = 0.3e-4;
cmaParms.errArr        = 0;
cmaParms.errAveLen     = 1;
cmaParms.Wxx           = zeros(cmaParms.tapNum,1);
cmaParms.Wxx(floor(cmaParms.tapNum/2)+1+cmaParms.tapOfst) = 1;
dsp.lmsParms           = cmaParms;

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
vP.glb.isEqualization  = isCMA;

print_sim_info;