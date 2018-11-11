% Processing the experimental data test

% clear;
clc;
% close all;
warning off

% Kramers Kronig Receiver parameters
kkRxParms.CSPR         = 10;         % dB, CSPR = 10*log10(Pa/Ps)
kkRxParms.bypass       = 0;          % 1 --> w/o KK; 0 --> w/i KK

%%
load rootPath.mat;
% refDataDir             = fullfile(rootPath,'.\offlineData\20181025\');
% dataDir                = fullfile(rootPath,'.\offlineData\20181025\16qam');
refDataDir             = fullfile('C:\Users\hongb\Dropbox\2018_10_25\20181031\');
dataDir                = fullfile('C:\Users\hongb\Dropbox\2018_10_25\20181108');

% loading offline data
refFileIdx             = 1;
[refFileList,refFileListNum] = getFileList(refDataDir,'.mat');
refFileName            = refFileList{refFileIdx};
load(refFileName);
Signal.Rs              = 3.125e9;  % Baud
% set offset frequency here
f_offset               = 6.25e9;  % frequency offset 7.5
Signal.scoperate       = 50e9;    % GSa/s

% loading reference data
oflFileIdx             = 3;
[fileList,fileListNum] = getFileList(dataDir,'.mat');
offlineFileName        = fileList{oflFileIdx};
load(offlineFileName);

% dsp.scopechannels = [ 1 2 ];
dsp.scopechannels = 1;

%% demodulate the signal
dsp.sps = 2;
dsp.CMA.passes = 3;
dsp.CMA.mu = 1e-3;
dsp.CMA.Ntaps = 17;
dsp.CMA.M = 16; % modulation level
modulation = '16_QAM';
dsp.LMS.Debug = 1;
dsp.LMS.Ntaps = 17;
dsp.LMS.sps = dsp.sps;
dsp.LMS.mu = 3e-4;
dsp.LMS.Npasses = 2;
dsp.LMS.M = 16; % modulation level
%dsp.LMS.Nangles = 32; 
dsp.LMS.Nangles = 2^5; 
dsp.LMS.BLen = 128;  %64,256

% Prepare constellations
aux = modem.qammod( dsp.CMA.M );
dsp.CMA.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );
aux = modem.qammod( dsp.LMS.M );
dsp.LMS.const = aux.Constellation / sqrt( mean( abs( aux.Constellation ).^2 ) );

%{ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dats Acquiration
% Scope parameters
Scope = Scope_Tek_70k( 'visa', 'tek', 'TCPIP0::192.168.123.88::inst0::INSTR' );
% Acquire signal
% aa = Scope.getQuickTrace.';
Signal.scopesig = int8( Scope.getQuickTrace.' ); % int to save memory
% Signal.scoperate = 50e9;
rsig = Signal.scopesig( dsp.scopechannels, : );
% rsig = complex( double( rsig( 1, : ) ), double( rsig( 2, : ) ) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save ('tmp_acquire_6.25GHz_2.5Gbaud_9_14_3.mat', 'rsig');
%% save captured data
OflfileNamePre = '4qam';
rfFreq         = 6.25;   % GHz
fBaud          = 6.15;   % 6.25GBaud
scoperate      = 50;     % GSa
preEmphasis    = 'wo_pre';
rootPath       = 'D:\offlineDataTest';

OflfileName = sprintf('%s_%.2fGHz_%.2fGBaud_dso_%.1fGSa_%s_%s.mat',OflfileNamePre, ...
    rfFreq,fBaud,scoperate, preEmphasis, datestr(now,'yyyymmddHHMMSS'));
captureDataFolder = fullfile(rootPath, 'offlineData', ...
    datestr(now,'yyyymmdd'));
if exist(captureDataFolder,'dir')
    % do nothing
else
    mkdir(captureDataFolder);
end
fileFullPath   = fullfile(captureDataFolder,OflfileName);
save(fileFullPath,'rsig');
fprintf('- data saved in file: %s\n',OflfileName);
fprintf('\t- dir: %s\n',captureDataFolder);
%}

% Normalization 
rsig = double(rsig);
rsig = rsig - mean(rsig);
rsig = rsig./max(abs(rsig));

% Kramers Kronig Receiver
kkSigOut               = kkReceiver(rsig, kkRxParms);
kkSigOut               = reshape(kkSigOut,1,[]);
fprintf('- Kramers Kronig Receiver end.\n');

% frequency down-conversion
t_n = 0:length(kkSigOut)-1;
rsig = kkSigOut .* exp( -1i * 2 * pi *f_offset/Signal.scoperate * t_n );

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
phi = calcPhaseRot16QAM(rsig);
fprintf('- the estimated rotation angle is: %.4f degree\n', phi*180/pi);


evm = EVM_RMS( rsig, dsp.LMS.const );
fprintf('%s%.2f\n','- EVM is: ',evm);

[ ber, rseq] = Lu_San_Demodulator_tao( rsig,Signal,modulation);
fprintf('%s%.2e\n','- BER is: ',ber);

% store stuff on Signal
Signal.rsig = rsig;
Signal.evm = evm;
Signal.dsp = dsp;

% scatter plot
scatterplot(rsig);

qFactor                = 1/evm;
QdB                    = 20*log10(qFactor);
fprintf('%s%.2f\n','- Q in dB is: ',QdB);