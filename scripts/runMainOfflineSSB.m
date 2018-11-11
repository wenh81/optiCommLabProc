% Description:
%     The main script for "Receiver_SSB_test04.m"
% 
% EXAMPLE:
%     runMainOfflineSSB
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
% V1.0       20180929    H.B. Zhang    Add TR and performance improved
% V1.1       20181025    H.B. Zhang    Add Kramers Kronig Receiver
% V1.2       20181106    H.B. Zhang    Add ML for phase noise compensation
% V1.3       20181108    H.B. Zhang    Add BER calculation, modified 
%                                      pfLmsEqualizer bug and release B001
% V1.4       20181109    H.B. Zhang    Add BPS-OSA for optical synthesizing
% 
% Ref:
%     

% clear envirement
% clc;
% clear;
close all;
 
% loading or capture DSO offline data
loadOfflineData;

% Configure and parameter settings
cfgOfflineSSB;

% DSP part
rxdspSSB;

% calc restuls
results;

% analysis signal
analysisOfflineSSB;