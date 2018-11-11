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
% V1.0       20180920    H.B. Zhang    Create this script
% 
% Ref:
%     

warning OFF;

% offline file name
load rootPath.mat;
% % defined data root path
% refDataDir             = fullfile(rootPath,'.\offlineData\20181025\');
% dataDir                = fullfile(rootPath,'.\offlineData\20181025\16qam');
refDataDir             = fullfile('C:\Users\hongb\Dropbox\2018_10_25\20181031\');
dataDir                = fullfile('C:\Users\hongb\Dropbox\2018_10_25\20181108');

% loading offline data
refFileIdx             = 1;
[refFileList,refFileListNum] = getFileList(refDataDir,'.mat');
refFileName            = refFileList{refFileIdx};
load(refFileName);
fprintf('- loading referene signal tx data: \n');
fprintf(' : %s\n\n',refFileName);

% loading reference data
oflFileIdx             = 1;
[fileList,fileListNum] = getFileList(dataDir,'.mat');
offlineFileName        = fileList{oflFileIdx};
load(offlineFileName);
fprintf('- loading offline data: \n');
fprintf(' : %s\n\n',offlineFileName);

% get offline data parameters: modulation format and baudrate
oflDataParms           = getOflParmsByFileName(offlineFileName);

% loading offline data
load(offlineFileName);
rxDataLen              = length(rsig);

warning ON;