function oflDataParms = getOflParmsByFileName(offlineFileName)
% Description:
%     get offline data parameters by offline file name with specified
%     format
% 
% EXAMPLE:
%     
% 
% Parameter description
%     oflDataParms = getOflParmsByFileName(offlineFileName)
%     
% Input
%     offlineFileName  - offline file name
%     
% Output
%     oflDataParms     - offline data parameters
% 
% Copyright, 2018 (C), H.B. Zhang, <hongbo.zhang83@gmail.com>
% 
% Modifications:
% Version    Date        Author        Log.
% V1.0       20181108    H.B. Zhang    Create this script
% 
% Ref:

% get file information
[~,oflFileName,~]      = fileparts(offlineFileName);

% split file name
fileNameStrArr         = strsplit(oflFileName,'_');
strArrLen              = length(fileNameStrArr);

% get parameters
fileNameStrArrTmp      = fileNameStrArr;
if (strArrLen == 9) % because of 16QAM named 16_QAM
    oflDataParms.M     = str2double(fileNameStrArrTmp{1});
    oflDataParms.modFormat = [fileNameStrArrTmp{1},fileNameStrArrTmp{2}];
    fileNameStrArrTmp(1)   = [];
else
    oflDataParms.M     = 4;
    oflDataParms.modFormat = fileNameStrArrTmp{1};
end

% RF: 
rfreqStrTmp            = fileNameStrArrTmp{2};
rfreqStrTmp(end-2:end) = [];
oflDataParms.rfFreq    = str2double(rfreqStrTmp)*1e9;

% Baud: 
baudrateStrTmp         = fileNameStrArrTmp{3};
baudrateStrTmp(end-4:end) = [];
oflDataParms.fBaud     = str2double(baudrateStrTmp)*1e9;

% DSO: 
dsoStrTmp              = fileNameStrArrTmp{5};
dsoStrTmp(end-2:end)   = [];
oflDataParms.scoperate = str2double(dsoStrTmp)*1e9;

% captured data time
oflDataParms.time      = fileNameStrArrTmp{end};

end