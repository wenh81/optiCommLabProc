function setsimenv()
% Description:
%     
% 
% EXAMPLE:
%     setsimenv
% 
% Parameter description
%     
%     
% Input
%     none
%     
% Output
%     none
% 
% Copyright, 2018 (C), H.B. Zhang, <hongbo.zhang83@gmail.com>
% 
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180914    H.B. Zhang    Create this script
% V1.1       20181001    H.B. Zhang    Check if dir of 'database' exist
% 
% Ref:

% restore default path
restoredefaultpath;

% get current path
rootPath               = fileparts(mfilename('fullpath'));
addpath(genpath(rootPath));

% save workspace path
dataBasePath           = fullfile(rootPath,'database');
dataBaseFullPath       = fullfile(dataBasePath,'rootPath.mat');
if ~checkDirExist(dataBasePath)
    mkdir(dataBasePath);
    addpath(dataBasePath);
end
save(dataBaseFullPath,'rootPath');

open runMainOfflineSSB.m
% open runMainOfflinePPG.m
end