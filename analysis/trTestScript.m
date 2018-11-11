% test script controller
caseNum                = 3;

switch caseNum
    case 1 % test digital filter and square timing recovery, feed-foward
        dspsigTmp      = reSample(rsig,Signal.scoperate,Signal.Rs*dsp.sps);
        dataLen        = length(dspsigTmp);
        
        % Config: ReTiming Parameters
        reTimingDFSTRParms.symbolRate      = Signal.Rs;
        reTimingDFSTRParms.sps             = dsp.sps;
        reTimingDFSTRParms.numPerBlk       = 5e3;      % 1024
        reTimingDFSTRParms.numAveDFSTR     = reTimingDFSTRParms.numPerBlk/2;    % 512
        reTimingDFSTRParms.interpAlgorithm = 'interp1';% {'interp1','interpft'}
        reTimingDFSTRParms.interpMethod    = 'PCHIP';   % {'cubic','linear','spline','pchip','nearest','v5cubic'}
        
        reTimingDFSTRParms.numPerBlk   = 5e3;      % 1024
        reTimingDFSTRParms.numAveDFSTR = reTimingDFSTRParms.numPerBlk/2;    % 512
        
        lenBlk         = 5e4;
        numBlk         = fix(dataLen/lenBlk);
        
        dspRTIn        = reshape(dspsigTmp,[],numBlk);
        
        sigOut = [];
        for iBlk = 1:numBlk
            sigOutTmp = reTimingDFSTR(dspRTIn(:,iBlk),reTimingDFSTRParms);
            sigOut = [sigOut;sigOutTmp];
        end
        clf;
        plot(sigOut(1:2:end),'.')
        grid on;
        
    case 2  % test TED
        dspsigTmp      = rsig;
        dataLen        = length(dspsigTmp);
        trParms.ted    = [];
        lenBlk         = trParms.lenBlk;
        numBlk         = fix(dataLen/lenBlk);
        dspsigTmp      = dspsigTmp(1:lenBlk*numBlk);
        trTEDIn        = reshape(dspsigTmp,lenBlk,numBlk);
        
        for iBlk = 1:numBlk
            trParms    = trTED(trTEDIn(:,iBlk),trParms);
        end
        
        clf;
        plot(trParms.ted);
        grid on;
        
    case 3 % test trClockRec.m
        % parameters
        trParms.sps            = dsp.sps;
        trParms.trPPM          = 0;
        trParms.mode           = 'MM';
        trParms.lenBlk         = 1000;
        trParms.bufferLen      = 3*trParms.lenBlk;
        trParms.buffer         = zeros(trParms.bufferLen,1);
        trParms.ted            = [];
        f3dB                   = 40e6;  % Hz
        Kted                   = Scope.scoperate*15;
        Knco                   = 1/trParms.lenBlk;
        Kp                     = 2*pi*f3dB/Kted/Knco;
        Ki                     = (2*pi*f3dB)^2/Kted/Knco/(4*Scope.scoperate);
        trParms.kp             = Kp; % 5e-3;
        trParms.ki             = Ki; % 4.5e-4;
        trParms.fbrt1st        = 0;
        trParms.fbrt2st        = 0;
        trParms.fbrtDly        = 0;
        trParms.clkBufShift    = 0;
        trParms.digitalT       = 0;
        trParms.interpMethod   = 'PCHIP';   % {'cubic','linear','spline','pchip','nearest','v5cubic'}
        % TR lock indicator parameters
        lckParms.lenAverage    = 80;
        lckParms.lckTh         = 0.8;
        lckParms.lckCntTh      = 400;
        lckParms.isLocked      = 0;
        lckParms.lckBuffer     = zeros(lckParms.lenAverage,1);
        lckParms.aveBufferLast = 0;
        lckParms.lckCnt        = 0;
        lckParms.lckCounter    = 0;
        lckParms.lckBlkIdx     = 0;
        lckParms.aveDiffMat    = [];
        trParms.lckParms       = lckParms;
        
        % run trClockRec for clock recovery
        [t_sigTRTest,t_trParms] = trClockRec(bbsig,trParms);
        
        % plot result
        figName                = 'Timinig Recovery Monitor';
        close(findobj('Name',figName));
        fig_reTiming           = figure('Name',figName);
        plt_fbrt2st            = plot(t_trParms.trPPM);
        hold on;
        plot([1,1]*t_trParms.lckParms.lckBlkIdx, get(gca, 'YLim'), '--r', 'LineWidth', 2) % º?«£¬¿úÒÈÎª3
        hold off;
        xlabel('block index of TR');
        ylabel('TR tracking in ppm');
        grid on;
        
    otherwise
        error('Error(in test.m): un-supported case number');
end