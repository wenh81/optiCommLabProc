% Description:
%     loading offline data or capture DSO data
%
% EXAMPLE:
%     loadOfflineData
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
%
% Ref:
%

% loading offline data or capture DSO data
fprintf('- loading offline data or capture DSO data\n');

% controller
isCaptureDSO           = 0;
isPltCapturedData      = 1;
isSaveData             = 0;
dataLen                = [];  % {number or []}

if (isCaptureDSO == 1)
    % capture DSO data
    % set parameters
    tekParms           = setTekParms();
    
    % capture data
    fprintf('- capture scope data ...\n');
    Scope  = Scope_Tek_70k(tekParms.Type,tekParms.Vendor,tekParms.r);
    Scope.getQuickTrace(tekParms.chNum,tekParms.horizonDiv, ...
        tekParms.sampleRate);
    rsig               = Scope.trace; % int8(scopeSig); % int to save memory
    fprintf('- data size: %d x %d\n',size(rsig,1),size(rsig,2));
    
    % save captured data
    OflfileName = sprintf('ofl_ppg_tx_%.1fg_rx_%.1fg_%s.mat',10, ...
        Scope.scoperate/1e9,datestr(now,'yyyymmddHHMMSS'));
    if (isSaveData == 1)
        load('rootPath');
        captureDataFolder = fullfile(rootPath, 'offlineData', ...
            datestr(now,'yyyymmdd'));
        if exist(captureDataFolder,'dir')
            % do nothing
        else
            mkdir(captureDataFolder);
        end
        fileFullPath   = fullfile(captureDataFolder,OflfileName);
        save(fileFullPath,'Scope');
        fprintf('- data saved in file: %s\n',OflfileName);
        fprintf('\t- dir: %s\n',captureDataFolder);
    else
        % do nothing
    end
else
    % loading offline data
    fprintf('- loading captured offline data ...\n');
    load('rootPath');
    
    %         % 10G NRZ
    %         captureDataFolder = fullfile(rootPath, 'offlineData', '20180925');
    %         fileName          = 'ofl_ppg_tx_10.0g_rx_50.0g_20180925172035.mat';
    
    % 10GBd PAM-4
    captureDataFolder = fullfile(rootPath, 'offlineData', '20181024');
    oflFileIdx         = 2;
    [fileList,fileListNum] = getFileList(captureDataFolder,'.mat');
    OflfileName        = fileList{oflFileIdx};
    
    load(OflfileName);
    rsig               = Scope.trace; % int8(scopeSig); % int to save memory
    fprintf('- data size: %d x %d\n',size(rsig,1),size(rsig,2));
end

% plot captured signal
if (isPltCapturedData == 1)
    figName            = 'Captured Scope Data';
    close(findobj('Name',figName));
    scrsz              = get(0,'ScreenSize');
    figure('Name',figName,'Position',[2*scrsz(3)/4 1.15*scrsz(4)*2/8 scrsz(3)/4 scrsz(4)/4]);
    plot(rsig);
    xlabel('Samples');
    ylabel('Amplitude (V)');
    grid on;
    clear h_fig h_plt;
else
    % do nothing
end

% processing data
if isempty(dataLen)
    % do nothing
else
    if (dataLen <= length(rsig))
        rsig           = rsig(1:dataLen);
    end
end
fprintf('- processing data size: %d x %d\n',size(rsig,1),size(rsig,2));
fprintf('%s\n','**********************************************************************');