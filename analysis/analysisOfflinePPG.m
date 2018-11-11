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
% V1.1       20180927    H.B. Zhang    Add Ctrl and TR
%
% Ref:
%

% plot controller
isPltResp              = 1;
isPltAgc               = 1;
isPltTR                = 1;
isPltLmsErr            = 1;
isPltCnst              = 1;

scrsz = get(0,'ScreenSize');
% plot signal response
if (isPltResp == 1)
    figName            = 'Frequency Response of received signal';
    close(findobj('Name',figName));
    fig_response       = figure('Name',figName,'Position',[1 scrsz(4)*5/8 scrsz(3)/4 scrsz(4)/4]);
    [h_plt,freq_in_GHz,amp_in_dB] = plotSigResp(rsig,2^12,Signal.scoperate);
    grid on;
end

% plot AGC
if (isPltAgc == 1)
    figName            = 'AGC Monitor';
    close(findobj('Name',figName));
    fig_reTiming       = figure('Name',figName,'Position',[1 1.15*scrsz(4)*2/8 scrsz(3)/4 scrsz(4)/4]);
    plt_agcGain        = plot(agcParms.gain);
    hold on;
    plot([1,1]*agcParms.lckParms.lckBlkIdx, get(gca, 'YLim'), '--r', 'LineWidth', 2) % ???1?7?1?7?1?7?1?7?1?7?1?7?1?7?1?7?3
    hold off;
    xlabel('block index of AGC');
    ylabel('AGC Gain tracking');
    grid on;
end

% plot TR
if (isPltTR == 1)
    figName            = 'Timinig Recovery Monitor';
    close(findobj('Name',figName));
    fig_reTiming       = figure('Name',figName,'Position',[scrsz(3)/4 scrsz(4)*5/8 scrsz(3)/4 scrsz(4)/4]);
    plt_fbrt2st        = plot(trParms.trPPM);
    hold on;
    plot([1,1]*trParms.lckParms.lckBlkIdx, get(gca, 'YLim'), '--r', 'LineWidth', 2) % ???1?7?1?7?1?7?1?7?1?7?1?7?1?7?1?7?3
    hold off;
    xlabel('block index of TR');
    ylabel('TR tracking in ppm');
    title(sprintf('Bandwidth of fadc offset: %.2fMHz',Signal.Btr));
    grid on;
end

% plot CMA error curve
if (isPltLmsErr == 1)
    if (isLMS == 1)
        errArr         = lmsParms.errArr;
    else
        errArr         = 0;
    end
    figName            = 'Error convergence';
    close(findobj('Name',figName));
    fig_err            = figure('Name',figName,'Position',[scrsz(3)/4 1.15*scrsz(4)*2/8 scrsz(3)/4 scrsz(4)/4]);
    plt_err            = plot(errArr);
    hold on;
    plt_errAve         = plot(smooth(errArr,8),'r');
    hold off;
    xlabel('block index of error calculation');
    ylabel('Equalizer convergence (error)');
    grid on;
end

% plot constellations
if (isPltCnst == 1)
    figName            = 'Constellation of SSB offline data';
    close(findobj('Name',figName));
    fig_CnstSSB        = figure('Name',figName,'Position',[2*scrsz(3)/4 scrsz(4)*5/8 scrsz(3)/4 scrsz(4)/4]);
    plt_CnstSSB        = plot(rxSymbol(1:end),'.');
    xlabel('symbol index');
    ylabel('Amplitude (a.u.)');
    title(sprintf('QdB = %.2f',QdB));
    grid on;
end
