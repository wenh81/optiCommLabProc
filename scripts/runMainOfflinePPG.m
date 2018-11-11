% Description:
%     The main offline processing scripts for PAM-M with PPG as transmitter
% 
% EXAMPLE:
%     runMainOfflinePPG
% 
%  Copyright, 2018, H.B. Zhang, <hongbo.zhang83@gmail.com>
%
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180925    H.B. Zhang    Create this script
% V1.1       20180927    H.B. Zhang    Add TR, release B001T001
% V1.1       20180929    H.B. Zhang    Add slicer to TED, Add DCBlock
%                                      Add self-defined agc and MATLAB AGC
%                                      release B001T002
% V1.2       20181001    H.B. Zhang    Add AGC lock indicator, Release B002
% V1.3       20181024    H.B. Zhang    Add BER calculation, Release B002T001
% V1.3       20181025    H.B. Zhang    Add K-K Receiver, Release B002T002
%     

% clear envirement
clc;
clear;
close all;
tBegin                 = clock;
% TekEnd(instrfind);

% loading or capture DSO offline data
loadOfflineDataPPG;

% Configure and parameter settings
cfgOfflinePPG;

% DSP part
rxdspPPG;

% calc restuls
resultsPPG;

% analysis signal
analysisOfflinePPG;

% end DSP processing
tEnd                   = clock;
fprintf('%s%.2f seconds\n','DSP processing Time: ', etime(tEnd,tBegin));
fprintf('%s\n', '-------------------------------------------');

% save results
saveResultsPPG;
diary off;