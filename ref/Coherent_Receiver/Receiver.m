clear all
% clc

restoredefaultpath;
addpath ./Common

% Reference file
reffile = 'referencesignal.mat';

% DSP Parameters
dsp.sps = 2;
dsp.scopechannels = [ 1 2 ];
dsp.timing.method = 'Lee';%'MMAprefilter';%
dsp.timing.sps = 2;
dsp.CMA.passes = 3;
dsp.CMA.mu = 1e-4;
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
%dsp.LMS.BLen = 128;  %64,256
dsp.LMS.BLen = 128;  %64,256

% Prepare constellations
aux = modem.qammod( dsp.CMA.M );
dsp.CMA.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );
aux = modem.qammod( dsp.LMS.M );
dsp.LMS.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );

% Load reference file
load( reffile )

% Scope parameters
Scope = Scope_Tek_70k( 'visa', 'agilent', 'TCPIP0::192.168.123.88::inst0::INSTR' );


% Acquire signal
Signal.scopesig = int8( Scope.getQuickTrace.' ); % int to save memory
Signal.scoperate = 50e9;
rsig = Signal.scopesig( dsp.scopechannels, : );
rsig = complex( double( rsig( 1, : ) ), double( rsig( 2, : ) ) );
figure(1);
f = linspace( -0.5, 0.5, size( rsig, 2 ) ) * Signal.scoperate;
subplot( 2, 1, 1 ); plot( f, fftshift( 10 * log10( abs( fft( rsig ) ) ) ) );
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

evm = EVM_RMS( rsig, dsp.LMS.const );



% store stuff on Signal
Signal.rsig = rsig;
Signal.evm = evm;
Signal.dsp = dsp;

% Demodulate (for 16QAM analysis) added on 2017/Jan
% [ ber, rseq, bers ] = Lu_San_Demodulator( rsig, Signal );

figure(1)
subplot( 2, 1, 2 );
plot( rsig, '.', 'MarkerSize', 1 );
axis( 1.5 * [ -1 1 -1 1 ] );
set( gca, 'DataAspectRatio', [ 1 1 1 ] );
grid on;
% no BER display
title( sprintf( 'EVM: %.2f%%', evm * 100 ) );

% add BER for 16QAM added on 2017/Jan
% title( sprintf( 'BER: %.2e   EVM: %.2f%%', ber, evm * 100 ) );

drawnow;
