clear;close all;
addpath ./Common
addpath ./kkreceiver

%% Parameters settting
fs = 40e9; % awg sampling rate 50e9
fc = [10e9,11e9]; % carrier frequecies
fb = 1e9; % baud rate
N = 1e5; % number of symbols
overN = 2; % oversampling ratio
%% generate QPSK signal
delayVec = [33, 66, 99]; % for decorrelation
sig{1} = genPRBS(N,0) + 1i.*genPRBS(N,delayVec(1));
sig{2} = genPRBS(N,delayVec(2)) + 1i.*genPRBS(N,delayVec(3));
%% design RRC filter
filterType = 'Square Root Raised Cosine';
filterParams = 'Nsym,Beta';
filterNsym = 80;
filterBeta = 0.05;
try
    fdes = fdesign.pulseshaping(overN, filterType, filterParams, filterNsym, filterBeta);
    filt = design(fdes);
catch ex
    errordlg({'Error during filter design. Please verify that' ...
        'you have the "Signal Processing Toolbox" installed' ...
        'MATLAB error message:' ex.message}, 'Error');
end
%% upsampling and apply the RRC filter
for idx = 1:length(sig)
    rawIQ = upsample(sig{idx}.',overN);
    phOffset = 0;
    len = length(rawIQ);
    nfilt = length(filt.Numerator);
    wrappedIQ = [rawIQ(end-mod(nfilt,len)+1:end)-phOffset repmat(rawIQ, 1, floor(nfilt/len)+1)];
    tmp = fftfilt(filt.Numerator, wrappedIQ);
    iqdata{idx} = tmp(nfilt+1:end);
end
%% up conversion
for idx = 1:length(iqdata)
    tmp = iqdata{idx};
    tmp = resample(tmp,fs,fb.*2,200);
    t = (0:length(tmp)-1)./fs;
    upconvdata{idx} = tmp.*exp(1i*2*pi.*fc(idx).*t); % up conversion
end
%% combine together
% txsig = upconvdata{1} + upconvdata{2};  %% two ssb
txsig = upconvdata{1};                    %% one ssb 

%% visualize
nSeq = length(txsig);
freq = [-nSeq/2:-1 0:nSeq/2-1]./nSeq.*fs;
plot(freq./1e9,20*log10(fftshift(abs(fft(txsig)))));
grid on;
xlabel('Frequency (GHz)');
ylabel('Magnitude (dB)');

%% load data to AWGs
Signal.awgRs=fs;
Signal.Rs=fb;
Signal.awgsig(1,:)=real(txsig);
Signal.awgsig(2,:)=imag(txsig);

maxAmp = max( max( abs( Signal.awgsig ) ) );
Signal.awgsig = Signal.awgsig / maxAmp;

sequenceDelays = [ 0, 0 ];
phases = [ 0, -4704 ];

% Load signal onto AWGs
Load2AWG( Signal, phases, sequenceDelays );
