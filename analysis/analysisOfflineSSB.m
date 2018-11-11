% Description:
%     Analysis script for receiver ssb offline data
%
% EXAMPLE:
%
%
% INPUT:
%     Input        - Input signal
%
% OUTPUT:
%     Output       - Output signal
%
%  Copyright, 2018, H.B. Zhang, <hongbo.zhang83@gmail.com>
%
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180920    H.B. Zhang    Create this script
%
% Ref:
%

% plot controller
isPltResp              = 0;
isPltTR                = 0;
isPltLmsErr            = 0;
isPltCnst              = 0;
isPltFo                = 0;

scrsz = get(0,'ScreenSize');
% plot signal response
if (isPltResp == 1)
    figName                = 'Frequency Response of received signal';
    close(findobj('Name',figName));
    fig_response          = figure('Name',figName,'Position',[1 scrsz(4)*5/8 scrsz(3)/4 scrsz(4)/4]);
    [h_plt,freq_in_GHz,amp_in_dB] = plotSigResp(rsig,2^12,Scope.scoperate);
    grid on;
end

% plot TR
if (isPltTR == 1) && (trParms.bypass == 0)
    figName                = 'Timinig Recovery Monitor';
    close(findobj('Name',figName));
    fig_reTiming           = figure('Name',figName,'Position',[1 1.15*scrsz(4)*2/8 scrsz(3)/4 scrsz(4)/4]);
    plt_fbrt2st            = plot(trParms.trPPM);
    hold on;
    plot([1,1]*trParms.lckParms.lckBlkIdx, get(gca, 'YLim'), '--r', 'LineWidth', 2) % ??«£¬¿úÒÈÎ?3
    hold off;
    xlabel('block index of TR');
    ylabel('TR tracking in ppm');
    title(sprintf('Bandwidth of fadc offset: %.2fMHz',Signal.Btr));
    grid on;
end

% plot CMA error curve
if (isPltLmsErr == 1)
    if (isCMA == 1)&&(isLMS == 1)
        errArr             = lmsParms.errArr;
    elseif (isCMA == 1)
        errArr             = cmaParms.errArr;
    elseif (isLMS == 1)
        errArr             = lmsParms.errArr;
    else
        errArr             = 0;
    end
    figName                = 'Error convergence';
    close(findobj('Name',figName));
    fig_err                = figure('Name',figName,'Position',[scrsz(3)/4 scrsz(4)*5/8 scrsz(3)/4 scrsz(4)/4]);
    plt_err                = plot(real(errArr));
    grid on;
end

% plot constellations
if (isPltCnst == 1)
    lenPlt                 = length(rxSymbol);
    figName                = 'Constellation of SSB offline data';
    close(findobj('Name',figName));
    fig_CnstSSB            = figure('Name',figName,'Position',[scrsz(3)/4 1.15*scrsz(4)*2/8 scrsz(3)/4 scrsz(4)/4]);
    plt_CnstSSB            = plot(rxSymbol(end-lenPlt+1:end),'.');
%     plotCnstBGw(rxSymbol(end-lenPlt+1:end),200);
    hold on;
    plot(dsp.const*dsp.constScale,'+r','LineWidth',3)
    title(sprintf('QdB = %.2f',QdB));
    grid on;
end

% plot CR fo
if (isPltFo == 1)
    if ((crParms.lckParms.bypass == 0) || (lmsParms.crParms.lckParms.bypass == 0))
        figName                = 'Frequency offset Monitor';
        close(findobj('Name',figName));
        fig_fo                 = figure('Name',figName,'Position',[2*scrsz(3)/4 scrsz(4)*5/8 scrsz(3)/4 scrsz(4)/4]);
        plt_cr2st              = plot(crParms.foMat);
        hold on;
        plot([1,1]*crParms.lckParms.lckBlkIdx, get(gca, 'YLim'), '--r', 'LineWidth', 2);
        % plot thresholds
%         plot(get(gca, 'XLim'),[1,1]*crParms.lckParms.lckThFo,  '--k', 'LineWidth', 2);
%         plot(get(gca, 'XLim'),-[1,1]*crParms.lckParms.lckThFo,  '--k', 'LineWidth', 2);
        hold off;
        xlabel('samples');
        ylabel('fo tracking in Hz');
        grid on;
    end
end