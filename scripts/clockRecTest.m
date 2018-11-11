% Clock recovery estimate
clc;
clear;
close all;
warning OFF;

%% Parameters
isPltTR               = 1;

Signal.Rs             = 2.5e9;   % symbol rate
Scope.scoperate       = 12.5e9;

% samples per symbol in equalizer
dsp.Sps                = Scope.scoperate/Signal.Rs;
dsp.sps                = 2;
dsp.M                  = 4;
aux                    = modem.qammod( 'M',dsp.M );
modFormatStrTmp        = strsplit(aux.Type);
dsp.modFormat          = strcat(num2str(aux.M),'-',modFormatStrTmp{1});
dsp.const              = aux.Constellation;


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
f3dB                   = .1e6;  % Hz, bandwidth of TR loop
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

%% load data
load('ROP_37dBm_7X.mat');

%%
fprintf('%s\n\n','- digigal clock recovery working ...');
fprintf('%s\n','- Inphase data digigal clock recovery working ...');
[realsigTR,trParms]    = trClockRec(real(streamX),trParms);
fprintf('%s\n','- Quadrature data digigal clock recovery working ...');
[imagsigTR,trParms]    = trClockRec(imag(streamX),trParms);
sigTR                  = complex(realsigTR,imagsigTR);

% calc fadc offset
trPpmAveLen            = 100;
avePPM                 = mean(trParms.trPPM(end-trPpmAveLen:end));
TtrOfst                = (avePPM*1e-6+1)*(1/Scope.scoperate);
BtrOfst                = (Scope.scoperate - 1/TtrOfst)*1e-3;         % KHz
fprintf('- the bandwidth of fadc offset is: %.2f PPM, %.2fKHz\n',avePPM,BtrOfst);
Signal.Btr             = BtrOfst;

scrsz                  = get(0,'ScreenSize');
% plot TR
if (isPltTR == 1)
    figName            = 'Timinig Recovery Monitor';
    close(findobj('Name',figName));
    fig_reTiming       = figure('Name',figName,'Position',[scrsz(3)/4 scrsz(4)*5/8 scrsz(3)/4 scrsz(4)/4]);
    plt_fbrt2st        = plot(trParms.trPPM);
    hold on;
    plot([1,1]*trParms.lckParms.lckBlkIdx, get(gca, 'YLim'), '--r', 'LineWidth', 2) % ??«£¬¿úÒÈÎ?3
    hold off;
    xlabel('block index of TR');
    ylabel('TR tracking in ppm');
    title(sprintf('Bandwidth of fadc offset: %.2fKHz',Signal.Btr));
    grid on;
end

warning ON;