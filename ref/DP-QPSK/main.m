clc; close all; clear all;
% Dual Pol transceiver MATLAB code
%% parameter setting
flag    =2;           % "0":Generate transmitted waveform; "1":Capture and measure waveform from scope; 
                      % "2":debug with saved samples
               
AWGflag =0;           %s "0":Don't use AWG; "1":AWG tr6ansmit the waveform

   
iLoop  = 1;          % number of performance

% M1             = 2^2;                   % bits of per sysmbol///BPSK:M1=2;QPSK:M1=4
M2             = 2^2;                     % Remodulation bits of per sysmbol /is not used
Mode           = 'PSK';                   % modulate format; PSK or QAM 
ModFormat      = 'QPSK';                 %  more modulate format£ºPSK,DPSK,QPSK,DQPSK
CodeFormat     = 'LDPC';                  % RS or LDPC encoding
OH             = 1/15;
DP             = 0;                     % 1 dual polarization;0 single polarization/ is not used
disp           = 13;                    % dispersion of the fiber
Length         = 0*100e3;                 % length of fiber 
window         = 28;                       % window of Phase Noise Estimation and Compensation 
switch ModFormat
    case 'BPSK', M1=2;case 'DPSK',M1=2;case 'QPSK',M1=4;case 'DQPSK',M1=4;
end     

QPSKpara = struct( 'M1',             M1,               ...
                   'M2',             M2,               ...
                   'Mode',           Mode,             ...
                   'ModFormat',      ModFormat,        ...
                   'CodeFormat',     CodeFormat,       ...
                   'OH',             OH,               ...
                   'DP',             DP,               ...
                   'disp',           disp,             ...
                   'Length',         Length,           ...   
                   'window',         window               );
save  data\QPSKpara  QPSKpara;  
DPOSymbolRate = 12.5e9;       % DPO symbol rate
AWGSymbolRate = 2.5e9;    % AWG symbol rate
AWGrate       = 2.5e9;     % AWG symbol rate
 
%% generate QPSK siginal
if flag == 0
 [streamX] = QPSK_generator_xPol;  
 save data\streamX streamX
end
    load data\streamX 
%% use AWG to transmit the waveform
if AWGflag == 1
    waveformName  = 'QPSKsignal';
    waveformName1='I';
    waveformName2='Q';
%     streamX=real(streamX)+j*real(streamX);  
    AWGcomm(AWGrate,streamX/70,waveformName1,waveformName2);

%     AWGcomm(AWGrate,(real(streamX)+1j*real(streamX))/70,waveformName1,waveformName2);%% for Sync checking
end
%%  DSP in receiver       
BER         = zeros(1,iLoop);
% bersc       = zeros(iLoop,Nsc);
preFileName = 'data\sampledData32mAOPt\32mAOPt_sampledData_';
BERpreFileName = 'data\BER32mAOPt\32mAOPt_BER_';

tic
iLoop=1;BER_final_X_tmp=[];
for i = 1:iLoop
    
    postFileName = i;
    if flag~=0
    [BER_final_X,BER_final_Y,streamX_tmp,streamY_tmp] = QPSK_receiver(AWGSymbolRate,DPOSymbolRate,flag,preFileName,postFileName,i);
    if BER_final_X(1)<0.1
      BER_final_X_tmp=[BER_final_X_tmp;BER_final_X];
    end
%     BER_final_X_tmp(i)=min(BER_final_X);
    pause(0.5);
%     BER=min(BER_final_X_tmp)
    end
end
 
BER_final_X=mean(BER_final_X_tmp);
BER_final_Y=mean(BER_final_X_tmp);

t = toc
%% 
if flag==1
clc
clear disp
disp(['                                          ½ÓÊÕ»úÎóÂ?ÔÄÜ£º'])
disp(['            --------------------------------------------------------------------------------------'])
disp(['             X-pol : FECÇ° FECºó£¬  ',num2str(BER_final_X)])
disp(['             Y-pol : FECÇ° FECºó£¬ ',num2str(BER_final_Y)])
disp(['            -----------------------------------------1---------------------------------------------'])
BitRate=2*AWGSymbolRate*log2(M1)/1e9;
disp(['             Format £º',ModFormat,'       ±àÂ?½Ê½ £º ',CodeFormat,'        ±ÈÌØÂÊ £º ',num2str(BitRate),'Gbit/s'])
disp(['            --------------------------------------------------------------------------------------'])
% if input('                 Constellation=1? ')==1
%     figure,plot(streamX_tmp,'.'),figure,plot(streamY_tmp,'.r')
% end
% if input('                 eyediagram=1? ')==1
%     eyediagram(angle(streamY_tmp(1000:2000)),4)
% end
end