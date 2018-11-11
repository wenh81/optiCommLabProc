clear all;clc;close all;
% clc

restoredefaultpath;
addpath ./Common

datafile = './12_24_1548_27.mat'; % ber=5.5e-3; evm=17.07%
datafile = './12_27_1548_2749_lower_-1_2.mat'; % ber=1.25e-3; evm=14.7%
datafile = './12_27_1548_2749_lower_-1.mat'; % ber=1.56e-3; evm=14.37%
datafile = './12_27_1548_4349_upper.mat'; % ber=2.8e-5; evm=11.66%
datafile = './1_9_1548_4349_upper.mat'; % ber=5.51e-5; evm=11.02%

%datafile_header = './1_25_1548_4349_upper_';
%datafile_header = './1_30_1548_3549_lower_';
datafile_header = './2_4_1548_3549_lower_';
datafile_header = './2_4_1548_6749_upper3_';
datafile_header = './2_4_1548_1149_lower3_';

fid=fopen('finaldata_2_4_lower3_2.txt','a');
%fid=fopen('finaldata_1_25_upper_3_a.txt','a');

modulation = input('Modulation Types 16_QAM/QPSK: ', 's');

if strcmp(modulation, '16_QAM')
    dsp.CMA.M = 16; 
    dsp.LMS.M = 16; 
else 
    dsp.CMA.M = 4; 
    dsp.LMS.M = 4;
end

for i=15:0.2:26
  %figureindex=i-39; 
  %figureindex=1+(i-40)/0.2; 
  %figureindex=1+(i-30)/0.2;
   figureindex=1+(i-15)/0.2;
  figureindex=round(figureindex);
datafile =[datafile_header,num2str(i),'dB_2.mat'];

% DSP Parameters
dsp.sps = 2;
dsp.scopechannels = [ 1 2 ];
dsp.timing.method = 'Lee';%'MMAprefilter';%
dsp.timing.sps = 2;
dsp.CMA.passes = 3;
dsp.CMA.mu = 1e-4;
dsp.CMA.Ntaps = 17;   
%dsp.CMA.M = 4; % modulation level
dsp.LMS.Debug = 0;
dsp.LMS.Ntaps = 17;
dsp.LMS.sps = dsp.sps;
dsp.LMS.mu = 1e-4;
dsp.LMS.Npasses = 4;
%dsp.LMS.M = 4; % modulation level
dsp.LMS.Nangles = 32; 
dsp.LMS.BLen = 256;  %64

% Prepare constellations
aux = modem.qammod( dsp.CMA.M );
dsp.CMA.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );
aux = modem.qammod( dsp.LMS.M );
dsp.LMS.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );



% Load signal
load( datafile )
rsig = Signal.scopesig( dsp.scopechannels, : );
rsig = complex( double( rsig( 1, : ) ), double( rsig( 2, : ) ) );
figure(figureindex);
f = linspace( -0.5, 0.5, size( rsig, 2 ) ) * Signal.scoperate;
subplot( 2, 1, 1 );
plot( f, fftshift( 10 * log10( abs( fft( rsig ) ) ) ) );
drawnow;

% Resample
[ a, b ] = rat( dsp.sps * Signal.Rs / Signal.scoperate );
rsig = resample( rsig, a, b );

% Align timing
rsig = TimingRecovery( rsig, dsp.timing );

% Normalize the signal
rsig = Orthonormalization( rsig, dsp.sps );

% CMA
[ rtemp, dsp.LMS.Hinit ] = c_cma_rde( rsig, dsp.sps, dsp.CMA.passes, dsp.CMA.mu, dsp.CMA.Ntaps, dsp.CMA.const );

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

% Measure EVM
evm = EVM_RMS( rsig, dsp.LMS.const );

%% Demodulate
[ ber, rseq] = Lu_San_Demodulator_tao( rsig,Signal,modulation);
% store stuff on Signal
Signal.rsig = rsig;
Signal.evm = evm;
Signal.dsp = dsp;

% figure(1)
% subplot( 2, 1, 2 );
% plot( rsig, '.', 'MarkerSize', 1 );
% axis( 1.5 * [ -1 1 -1 1 ] );
% set( gca, 'DataAspectRatio', [ 1 1 1 ] );
% grid on;
% title( sprintf( 'BER: %.2e   EVM: %.2f%%', ber, evm * 100 ) );
% drawnow;

%figure(figureindex)
subplot( 2, 1, 2 );
plot( rsig, '.', 'MarkerSize', 1 );
axis( 1.5 * [ -1 1 -1 1 ] );
set( gca, 'DataAspectRatio', [ 1 1 1 ] );
grid on;
title( sprintf( 'BER: %.2e   EVM: %.2f%%', ber, evm * 100 ) );
drawnow;


fprintf(fid,'%.3e\t%.2f\n',ber,evm*100);
end 
fclose(fid);
