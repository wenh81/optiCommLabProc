% Description:
%     Data capture script for TekTronix DSA60000/70000
% 
% EXAMPLE:
%     runTekMain
% 
% Parameters for function Scope.getQuickTrace
%     Scope.getQuickTrace(tekParms.chNum,tekParms.horizonDiv,tekParms.sampleRate);
%         tekParms.chNum      --> selected channel number
%         tekParms.horizonDiv --> horizontal div
%         tekParms.sampleRate --> scope sample rate
% 
% Copyright, 2018 (C), H.B. Zhang, <hongbo.zhang83@gmail.com>
% 
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180914    H.B. Zhang    Create this script
% V1.1       20180922    H.B. Zhang    Support DSO sampling channel selection
% V1.2       20180922    H.B. Zhang    1. Support DSO sampling channel selection
%                                      2. Restore DSO continually mode after
%                                      sampling
%                                      3. open selected channel and close
%                                      un-selected channel
%                                      4. support self-defined DSO sample rate
% Ref:

% clear simulation envirement
clc;
clear;
close all;

% set parameters
tekParms               = setTekParms();

% capture data
Scope                  = Scope_Tek_70k(tekParms.Type,tekParms.Vendor,tekParms.r);
Scope.getQuickTrace(tekParms.chNum,tekParms.horizonDiv,tekParms.sampleRate);
rsig                   = Scope.trace; % int8(scopeSig); % int to save memory

% plot signal
figName                = 'Captured Scope Data';
close(findobj('Name',figName));
h_fig                  = figure('Name',figName);
h_plt                  = plot(rsig);
clear h_fig h_plt;