function [BER] = QPSK_receiver_polx(AWGSymbolRate,DPOSymbolRate,transmittedX,flag,preFileName,postFileName)
% ***************************************************** %
% ------------------ QPSK Parameters ------------------ %
% ***************************************************** %
load data\QPSKpara
M              = QPSKpara.M1;
Mode           = QPSKpara.Mode;
disp           = QPSKpara.disp;                     % dispersion of the fiber
Length         = QPSKpara.Length;

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
    stream =streamX_pol;
    elseif flag == 1                           % capture waveform from the scope 
     [sampledData1,sampledData2] = DPOcomm(DPOSymbolRate,1);
     % save waveform from the scope 
     save dataRx\sampledData1 sampledData1    %X polarization  waveform
     save dataRx\sampledData2 sampledData2    %Y polarization  waveform
        
       streamX=sampledData1;
       streamY=sampledData2;

  else                                       % debug with the stored samples

load('E:\zzj\QPSK_SINGLE\dataRx\sampledData5.mat')


    stream= sampledData5;

end

% *************************************************************** %
% ------------------------Chromatic dispersion Compensate-------------------- %
% *************************************************************** %
streamX_pol= CDC(streamX,-disp,DPOSymbolRate,Length); % Compensate X_pol Chromatic dispersion
streamY_pol= CDC(streamY,-disp,DPOSymbolRate,Length); % Compensate Y_pol Chromatic dispersion


% % *************************************************************** %
% % ------------------------Fre_offset_comp-------------------- %
% % *************************************************************** %
    temp =fft(stream);
    [peak center]=max(abs(temp(100:end)));
    center=center+99;                       %avoid DC
    temp_x= circshift(temp,[-center,0]);    %fre_offset_comp
    stream_tmp=ifft(temp_x);
       figure,plot(10*log10(abs(temp_x)))
% %     streamX=conj(ifft(temp_x));%for IQ imblance debugging
%      [streamX_pol]=fre_offset_comp(streamX_pol);   

%     streamX = resample(streamX,DPOSymbolRate/1e9,AWGSymbolRate/1e9,1);%downsample
for m=0:4
stream= downsample(stream_tmp,5,m);
% stream_re=real(stream);
% stream_im=imag(stream);
% streamY = downsample(streamY,2,1);

% stream = fre_resample(stream,AWGSymbolRate/1e9,DPOSymbolRate/1e9/Nb);

% *************************************************************** %
% ------------------------Find X_REAL Block-------------------- %
% *************************************************************** %
load data\transmittedX transmittedX
len1   = length(stream);
index1 = zeros(1,len1-128*8*Nb*2);                % preallocating resources for speed
for i = 1:len1-128*2*Nb*8
    index1(i) = sum((stream(i:i+128*Nb*8-1).*conj(stream(i+128*Nb*8:i+128*2*Nb*8-1))));
end
[peak,head1] = max(abs(index1));
if head1 > len1/2
     head1 = head1-length(transmittedX);
end
% head1
head1 = head1+128*8*Nb*2+1;

figure; set(gcf,'NumberTitle','off');set(gcf,'Name','X_re_Synchronization');
plot(abs(index1));
title('X_re_polSynchronization');

load data\transmittedX transmittedX
stream   = stream(head1:head1+length(transmittedX)-(128*2*Nb*8)-1);  % cut the block out

% % Rx   = Rx.'; 
% stream=stream_re+j*stream_im;
 load data\X_Tx X_Tx
Rx=stream;

 % *************************************************************** %
 %-------------Phase Noise Estimation and Compensation--------------%
 % *************************************************************** %
window=28;
phase=unwrap(angle(smooth(Rx.^4,window))).'/4;
Rx=Rx.'.*exp(-1j*phase);
figure;plot(Rx(200:end-200),'.');
 
CRx=mean(Rx(1:128)./X_Tx(1:128),2);
Rx =Rx*conj(CRx)/abs(CRx)^2;
 Rx=Rx/mean(abs(Rx));
figure;plot(Rx,'.');
end

% CR=Rx./X_Tx; 
% CR=mean(CR);
% Rx=Rx*conj(CR);
% *************************************************************** %
% --------------------- Y ------------- ------------------------- %
% *************************************************************** %

    temp =fft(streamY);
    [peak center]=max(abs(temp(100:end)));
    center=center+99;                       %avoid DC
    temp_y= circshift(temp,[-center,0]);    %fre_offset_comp
    stream_tmp=ifft(temp_y);
       figure,plot(10*log10(abs(temp_y)))
% %     streamX=conj(ifft(temp_x));%for IQ imblance debugging
%      [streamX_pol]=fre_offset_comp(streamX_pol);   

%     streamX = resample(streamX,DPOSymbolRate/1e9,AWGSymbolRate/1e9,1);%downsample
for m=0:4
stream= downsample(stream_tmp,5,m);
% stream_re=real(stream);
% stream_im=imag(stream);
% streamY = downsample(streamY,2,1);

% stream = fre_resample(stream,AWGSymbolRate/1e9,DPOSymbolRate/1e9/Nb);

% *************************************************************** %
% ------------------------Find Y_REAL Block-------------------- %
% *************************************************************** %
load data\transmittedX transmittedX
len1   = length(stream);
index1 = zeros(1,len1-128*8*Nb*2);                % preallocating resources for speed
for i = 1:len1-128*2*Nb*8
    index1(i) = sum((stream(i:i+128*Nb*8-1).*conj(stream(i+128*Nb*8:i+128*2*Nb*8-1))));
end
[peak,head1] = max(abs(index1));
if head1 > len1/2
     head1 = head1-length(transmittedX);
end
% head1
head1 = head1+128*8*Nb*2+1;

figure; set(gcf,'NumberTitle','off');set(gcf,'Name','X_re_Synchronization');
plot(abs(index1));
title('X_re_polSynchronization');

load data\transmittedX transmittedX
stream   = stream(head1:head1+length(transmittedX)-(128*2*Nb*8)-1);  % cut the block out

% % Rx   = Rx.'; 
% stream=stream_re+j*stream_im;
load data\X_Tx X_Tx
Rx=stream;

 % *************************************************************** %
 %-------------Phase Noise Estimation and Compensation--------------%
 % *************************************************************** %
window=28;
phase=unwrap(angle(smooth(Rx.^4,window))).'/4;
Rx=Rx.'.*exp(-1j*phase);
figure;plot(Rx(200:end-200),'.');
 
CRx=mean(Rx(1:128)./X_Tx(1:128),2);
Rx =Rx*conj(CRx)/abs(CRx)^2;
 Rx=Rx/mean(abs(Rx));
figure;plot(Rx,'.');

tmp=Rx;
end


% *************************************************************** %
% --------------------- BER Calculation ------------------------- %
% *************************************************************** %
n=1;
for theta=-pi*3/4:pi/2:pi*3/4
    switch Mode
        case 'PSK'
            Rx_deci = pskdemod(Rx.*exp(j*theta),M,[],'gray');
            Tx_deci= pskdemod(X_Tx,M,[],'gray');
        case 'QAM'
            Rx_deci = qamdemod(Rx,M,[],'gray');
            Tx_deci = qamdemod(X_Tx,M,[],'gray');
        otherwise error;
    end
    % SNR=OFDM_funs('snr',Rx, Tx_deci, 16,0);
    % figure;
    % plot(SNR,'.');
    % SNR_max=max(SNR);
    % SNR_total=mean(SNR)
    [~, BER(n), ~] = biterr(Tx_deci,circshift(Rx_deci,[0,0]));
    if BER(n)<0.1
       eyediagram(real(tmp),10)
    end
        n=n+1;
end
[BERs(m+1),loc]=min(BER)
end 

% for nsc=1:size(Rx,2)
% BERtotal(nsc) = biterr(Tx_deci(:,nsc),Rx_deci(:,nsc));
% end