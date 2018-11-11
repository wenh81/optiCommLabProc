% Processing the experimental data test

clear;close all;
warning off
restoredefaultpath;
addpath Common

% Reference file
reffile = 'referencesignal.mat';

% Load reference file
load( reffile )

%% demodulate the signal
dsp.sps = 2;
dsp.CMA.passes = 3;
dsp.CMA.mu = 1e-3;
dsp.CMA.Ntaps = 17;
dsp.CMA.M = 4; % modulation level
dsp.LMS.Debug = 0;
dsp.LMS.Ntaps = 17;
dsp.LMS.sps = dsp.sps;
dsp.LMS.mu = 1e-4;
dsp.LMS.Npasses = 4;
dsp.LMS.M = 4; % modulation level
%dsp.LMS.Nangles = 32; 
dsp.LMS.Nangles = 32; 
dsp.LMS.BLen = 128;  %64,256

% Prepare constellations
aux = modem.qammod( dsp.CMA.M );
dsp.CMA.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );
aux = modem.qammod( dsp.LMS.M );
dsp.LMS.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );

% Load reference file
load( reffile )

% load data file
load('Data\tmp_acquire_5.5GHz.mat');

% set offset frequency here
f_offset = 5.5e9;
Signal.scoperate = 50e9;

% Normalization 
rsig = double(rsig);
rsig = rsig - mean(rsig);
rsig = rsig./max(abs(rsig));

% frequency down-conversion
t_n = 0:length(rsig)-1;
rsig = rsig .* exp( -1i * 2 * pi *f_offset/Signal.scoperate * t_n );

% Resample
[ a, b ] = rat( dsp.sps * Signal.Rs / Signal.scoperate );
rsig = resample( rsig, a, b );

% Normalize the signal
rsig = Orthonormalization( rsig, dsp.sps );

% CMA
[ rtemp, dsp.LMS.Hinit ] = c_cma_rde( rsig, dsp.sps, dsp.CMA.passes, dsp.CMA.mu, dsp.CMA.Ntaps, dsp.CMA.const );
% scatterplot(rtemp);

% Carrier freq. offset estimation
[ ~, dsp.LMS.fOffset ] = FrequencyRecovery( rtemp, dsp.sps );
% dsp.LMS.fOffset

% LMS
rsig = c_IQ_DD_LMS( rsig, dsp.LMS );

% Signal conditioning
rsig = rsig( 1:dsp.sps:end );
rsig = rsig( 128:( end - 128 ) );

% Normalize the signal
rsig = Orthonormalization( rsig, 1 );

evm = EVM_RMS( rsig, dsp.LMS.const );


% store stuff on Signal
Signal.rsig = rsig;
Signal.evm = evm;
Signal.dsp = dsp;

% scatter plot
scatterplot(rsig);