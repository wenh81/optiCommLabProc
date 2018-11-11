% Description:
%     The main offline processing scripts for Single-Carrier QPSK
%     Demo script for processing offline data from UESTC
% 
% EXAMPLE:
%     runMainOfflineSCQPSK
% 
%  Copyright, 2018, H.B. Zhang, <hongbo.zhang83@gmail.com>
%
% Modifications:
% Version    Date        Author        Log.
% V1.0       20181005    H.B. Zhang    Create this script
% Ref:
%     

% clear envirement
clc;
clear;
close all;
tBegin                 = clock;
% TekEnd(instrfind);

% loading or capture DSO offline data
loadOfflineDataSCQPSK;

% Configure and parameter settings
cfgOfflineSCQPSK;

% DSP part
rxdspSCQPSK;

%{
% calc restuls
resultsSCQPSK;

% analysis signal
analysisOfflineSCQPSK;

% end DSP processing
tEnd                   = clock;
fprintf('%s%.2f seconds\n','DSP processing Time: ', etime(tEnd,tBegin));
fprintf('%s\n', '-------------------------------------------');

% save results
saveResultsSCQPSK;
%}
diary off;