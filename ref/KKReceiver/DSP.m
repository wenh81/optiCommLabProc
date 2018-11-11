clc;clear all;close hidden all;
load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\different_receive_power\data.mat')
kk = 1;
for i = -7:2:7
    %%
    if i == -7
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_07dB.mat')
    elseif i == -5
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_05dB.mat')
    elseif i == -3
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_03dB.mat')
    elseif i == -1
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_01dB.mat')
    elseif i == 1
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_1dB.mat')
    elseif i == 3
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_3dB.mat')
    elseif i == 5
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_5dB.mat')
    elseif i == 7
        load('D:\科研\研二\KK\simulatoin\DSP\data_for_bye\112G_100km_7dB.mat')
    end
    %%
    Rx = Rx;
    Rx = Rx - mean(Rx);
    %% KK
    signal = signal_resconstruction(Rx);
    signal = signal.*exp(1j*pi/4);
    %     figure
    %     plot(signal,'.');title('reconstraction signal')
    %     signal = CD_compensation(real(signal), imag(signal));   %注意修改距离与速率
    %     figure
    %     plot(signal,'.');title('after compensate CD signal')
    signal = real(signal);
    signal = signal - mean(signal);
    afterresample = resample(signal,8,5);
    
    %% Equalizer
    Fl = 171 ;
    Sl = 16;
    Tl = 0;
    output = Volterra_RLS(re_data,data,1,2^(-10),4000,Fl,Sl,Tl);
    figure
    plot(output,'.'); title('after FFE');
    %% BER
    M = 4;
    Rx_data1 = pamdemod(output,M,[],'gray');
    Tx_data1 = pamdemod(data,M,[],'gray');
    BER(kk) = sum(Tx_data1 ~= Rx_data1)/length(Tx_data1)/log2(M)
    kk = kk + 1;
end
