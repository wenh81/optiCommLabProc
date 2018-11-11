function [streamX,streamY]=waveform(flag,DPOSymbolRate)
if flag == 0                               % direct detection in digital B2B
    load AWG_Double.mat;
    streamXpol_real = Waveform_Data_1;
    streamXpol_real = repmat(streamXpol_real,1,2);
    streamXpol_real = circshift(streamXpol_real,[0 2000]);
    figure('Name','streamX_real','NumberTitle','off');
    plot(1:length(streamXpol_real),streamXpol_real);
    load AWG_Float.mat;
    streamXpol_imag = Waveform_Data_2;
    streamXpol_imag = repmat(streamXpol_imag,1,2);
    streamXpol_imag = circshift(streamXpol_imag,[0 2000]);
    figure('Name','streamX_imag','NumberTitle','off');
    plot(1:length(streamXpol_imag),streamXpol_imag);
    streamX_pol = streamXpol_real+1i*streamXpol_imag;
    streamX =streamX_pol;
    streamY_pol = streamXpol_real-1i*streamXpol_imag;
    streamY =streamY_pol;
    %%
elseif flag == 1                           % capture waveform from the scope
    [sampledData1,sampledData2] = DPOcomm(DPOSymbolRate,1);
    save dataRx\sampledData1 sampledData1
    save dataRx\sampledData2 sampledData2
    streamX=sampledData1;
    streamY=sampledData2;
else                                       % debug with the stored samples
    
    load('E:\zzj\QPSK_SINGLE\dataRx\sampledData5.mat')
    streamX= sampledData5;
end
end