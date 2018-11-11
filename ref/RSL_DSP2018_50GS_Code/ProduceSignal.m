% clear all
close all
clc

restoredefaultpath;
addpath ./Common

% Reference file
referencefile = 'referencesignal.mat';

% Use only for time alignment
TIME_ALIGNMENT_SIGNAL = false;  %  ### true for alignment ####
% TIME_ALIGNMENT_SIGNAL = true;  %  ### true for alignment ####
% AWG Synchronization Parameters
% phases = [ 0, -4700 ];% previous setting ### awg2=-25
% phases = [ 0, -4796 ];% previous setting ### awg2=-25
% phases = [ 0, -4704 ];% previous setting ### awg2=-25
% phases = [ 0, 367 ];

phases = [ 49, -7056 ];
sequenceDelays = [ 0, 0];% ### for alignment ###

% sequenceDelays = [ 0, 86e-9 ];% ### for alignment ###

% sequenceDelays = [ 0, 0.9e-9 ]; % ### for alignment ###
% sequenceDelays = [ 0, -1e-9 ];% ### for alignment ###
% sequenceDelays = [ 0, -0.9e-9-0.025e-9];% ### for alignment ###
% sequenceDelays = [ 0, (3.752e-6-2.071e-9)*4];% ### for alignment ###
% sequenceDelays = [ 0, 3.752e-6];% ### for alignment ###

% Generate signal
Signal = SignalGenerator();  % for generating single carrier signal 
% Signal = SignalGenerator_SSB(); % for generating SSB signal 


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Without Pre-Equalization
% 
% Signal.awgsig(1,:)=real(Signal.composite_signal);
% Signal.awgsig(2,:)=imag(Signal.composite_signal);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pre-Equalization
equalizerfilename = 'Equalizer_20GHz_40GSps.mat';
load( equalizerfilename );
Equalizer = [ Equalizer.Equalizers{1}; Equalizer.Equalizers{2} ];
fsig = [ real( Signal.composite_signal ); imag( Signal.composite_signal ) ];

for awgcount = 1:2
    ntaps_eq = size( Equalizer, 2 );
    hex = zeros( size( fsig( awgcount, : ) ) );
    hex( 1:ntaps_eq ) = Equalizer( awgcount, end:-1:1 );
    hex = circshift( hex, [ 0, -( ntaps_eq - 1 ) / 2 ] ); % Alignment
    % Filter using fft
    esig = real( ifft( fft( fsig( awgcount, : ) ) .* fft( hex ) ) );
    % Normalize*
    Signal.awgsig( awgcount, : ) = esig;
end;




% Normalize combined signal
maxAmp = max( max( abs( Signal.awgsig ) ) );
Signal.awgsig = Signal.awgsig / maxAmp;

% Plot stuff
figure(1); hold on;
f = Signal.awgRs * linspace( -0.5, 0.5, size( Signal.awgsig, 2 ) ) / 1e9;
aux = complex( Signal.awgsig( 1, : ), Signal.awgsig( 2, : ) );
plot( f, fftshift(10*log10(abs(fft(hex)))));
plot( f, fftshift(10*log10(abs(fft(aux)))),'r'); hold off;
grid on;
axis( [ Signal.awgRs / 2e9 * [ -1, 1 ], -70, 40 ] )
drawnow;


% Prepare time alignment signal
if TIME_ALIGNMENT_SIGNAL
    pos = 1:20000:100000;
    aux = 0:9999;
    for n = 1:length( pos )
        Signal.awgsig( 1, pos(n) + aux ) = 0;
        Signal.awgsig( 2, pos(n) + aux ) = 0;
%         Signal.awgsig( 1, pos(n) + 100 ) = 1;
%         Signal.awgsig( 2, pos(n) + 100 ) = 1;
        Signal.awgsig( 1, pos(n) + 4000 ) = 1;
        Signal.awgsig( 2, pos(n) + 4000 ) = 1;
    end
%     Signal.awgsig = Signal.awgsig( :, 1:150000 );
    Signal.awgsig = Signal.awgsig( :, 1:130000 );

end;

% % Load signal onto AWGs
% Load2AWG( Signal, phases, sequenceDelays );

% % Save reference signal
% save( referencefile, 'Signal' );
