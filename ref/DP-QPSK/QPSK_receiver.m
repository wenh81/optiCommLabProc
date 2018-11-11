function [BER_final_X,BER_final_Y,streamX_tmp,streamY_tmp] = QPSK_receiver(AWGSymbolRate,DPOSymbolRate,flag,preFileName,postFileName,iLoop)


load data\QPSKpara
M              = QPSKpara.M1;                       % bits of per sysmbol
Mode           = QPSKpara.Mode;                     % Remodulation bits of per sysmbol
ModFormat      = QPSKpara.ModFormat;
disp1          = QPSKpara.disp;                     % dispersion of the fiber
Length         = QPSKpara.Length;                   % length of fiber
window         = QPSKpara.window;                    % Phase Noise Estimation and Compensation
% *************************************************************** %
% ------------------------Get digital Signal Waveform-------------- %
% *************************************************************** %
if flag==1
    [streamX,streamY]=waveform(flag,DPOSymbolRate);%–≈∫≈ªÒ»°
    if QPSKpara.DP~=1
        streamX=streamY;
    end
    streamX=(streamX-mean(streamX))./sqrt(mean(abs(streamX-mean(streamX)).^2));
    streamY=(streamY-mean(streamY))./sqrt(mean(abs(streamY-mean(streamY)).^2));
elseif flag==2
%     filename1    = 'dataRx\sampledData1.mat';
%     filename2    = 'dataRx\sampledData2.mat';
    filename1    = 'dataRx\ROP_37dBm_7X.mat';%…Ë÷√¥?¡»°Œƒº?∑æ∂
    load(filename1);
    streamY      = streamX;

end
%% 
% *************************************************************** %
% ------------------------Diginal Signal Processing-------------- %
% *************************************************************** %

                % 1 Chromatic Dispersion Compensate
                % 2 Frequence Offset Compensate
                % 3 IQ Imbalnce Compensation
                % 4 Symbol Timing
                % 5 Demutiplexing
                % 6 Synchronization
                % 7 Phase Compensation
                % 8 Decoding
                % 9 BER calculation
%-----------------------------------------------------------------%
%%
% *************************************************************** %
% ------------------------Chromatic dispersion Compensate-------- %
% *************************************************************** %
streamX_pol= CDC(streamX.',-disp1,DPOSymbolRate,Length); % Compensate X_pol Chromatic dispersion
streamX_pol=streamX_pol.';
streamY_pol= CDC(streamY.',-disp1,DPOSymbolRate,Length); % Compensate X_pol Chromatic dispersion
streamY_pol=streamY_pol.';

% streamY_pol= CDC(streamY,-disp,DPOSymbolRate,Length);
%%
% % *************************************************************** %
% % ------------------------Frequence_Offset_Compensate-------------------- %
% % *************************************************************** %
% streamX_tmp=streamX_pol;
[streamX_tmp,streamY_tmp] = Frequence_Offset_Com(streamX_pol,streamY_pol);%X_pol_Frequence_Offset_Compensate
% Frequence_Offset_Com2(streamX_pol);
%% Alterntive I Ω¯––¡À∑˚∫≈Õ¨≤Ω
alternative=1;
if alternative==1
% %     IQ imbalance
    streamX_tmp1=streamX_tmp;
    streamY_tmp1=streamY_tmp;
    streamX_tmp=IQimbalance(streamX_tmp1,0).';
    streamY_tmp=IQimbalance(streamY_tmp1,0).';
    % Symbol Sync.
    Nb=DPOSymbolRate/AWGSymbolRate;
    [outputX,Time_ptX]=delayTest(streamX_tmp,Nb);outputY=outputX;Time_ptY=Time_ptX;
%     [outputY,Time_ptY]=delayTest(streamY_tmp,Nb);
    t1=mod(round(Time_ptX/10)+floor(Nb/2)-1,Nb);
    t2=mod(round(Time_ptY/10)+floor(Nb/2)-1,Nb);    
    % Down sampling
    streamX_tmp2= downsample(streamX_tmp,Nb,t1);
    streamY_tmp2= downsample(streamY_tmp,Nb,t2);
    streamX_tmp = streamX_tmp2;
    streamY_tmp = streamY_tmp2;
    % Demutiplexing
    streamX_tmp3=streamX_tmp;
    streamY_tmp3=streamY_tmp;
    N=150;%%Points length in Stokes domain estimtion
    [streamX_tmp,streamY_tmp]=SsInitCMA(streamX_tmp3.',streamY_tmp3.',N,11);
    streamX_tmp=streamX_tmp.';
    streamY_tmp=streamY_tmp.';
    % Synchronization
    [streamX_tmp,head1] = QPSK_Synchronous_Head(streamX_tmp);
    streamY_tmp=streamX_tmp;head2=head1;
%     [streamY_tmp,head2] = QPSK_Synchronous_Head(streamY_tmp);
    tau=head1-head2
figure,plot(abs(streamX_tmp)),hold on,plot(abs(streamY_tmp),'r.-')
%     % Normalization again
%     streamX_tmp=IQimbalance(streamX_tmp,0).';
%     streamY_tmp=IQimbalance(streamY_tmp,0).';
    streamX_tmp=(streamX_tmp-mean(streamX_tmp))./sqrt(mean(abs(streamX_tmp-mean(streamX_tmp)).^2));
    streamY_tmp=(streamY_tmp-mean(streamY_tmp))./sqrt(mean(abs(streamY_tmp-mean(streamY_tmp)).^2));

% 
%     % IQ imbalance compensation again
%     streamX_tmp5=streamX_tmp;
%     streamY_tmp5=streamY_tmp;
%     streamX_tmp=IQimbalance(streamX_tmp5,0).';
%     streamY_tmp=IQimbalance(streamY_tmp5,0).';

    % Phase noise compensation
    [streamX_tmp4] =Phase_Nois_Com(streamX_tmp,51);streamY_tmp4=streamX_tmp4;
%     [streamY_tmp4] =Phase_Nois_Com(streamY_tmp,45);
    streamX_tmp = streamX_tmp4;
    streamY_tmp = streamY_tmp4;
    streamX_tmp=(streamX_tmp-mean(streamX_tmp))./sqrt(mean(abs(streamX_tmp-mean(streamX_tmp)).^2));
    streamY_tmp=(streamY_tmp-mean(streamY_tmp))./sqrt(mean(abs(streamY_tmp-mean(streamY_tmp)).^2));

    % BER calculation
    load data\X_Tx X_Tx
    %%%%%%%%%%%%%%%%%%%%%%%%
%     streamX_tmp=awgn(streamX_tmp,13,'measured');figure();scatterplot(streamX_tmp);
    %%%%%%%%%%%%%%%%%%%
    BER_final_X = BER_QPSK(streamX_tmp,X_Tx);
%     BER_final_Y = BER_QPSK(streamY_tmp,X_Tx);
    BER_final_Y = BER_final_X;
end

%% save DATA
if flag==1
ROP='_XX';
filename1=['dataRx\ROP',ROP,'dBm_',num2str(iLoop),'X.mat'];
save(filename1,'streamX');
% filename2=['dataRx\ROP',ROP,'dBm_',num2str(iLoop),'Y.mat'];
% save(filename2,'streamY');
end






