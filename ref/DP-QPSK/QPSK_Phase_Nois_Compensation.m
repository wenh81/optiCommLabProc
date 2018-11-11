function [stream_tmp] =Phase_Nois_Com(stream£¬window)
% *************************************************************** %
 %-------------Phase Noise Estimation and Compensation--------------%
 % *************************************************************** %
phase=unwrap(angle(smooth(Rx.^4,window))).'/4;
Rx=Rx.'.*exp(-1j*phase);
figure;plot(Rx(200:end-200),'.');
 
CRx=mean(Rx(1:128)./X_Tx(1:128),2);
Rx =Rx*conj(CRx)/abs(CRx)^2;
 Rx=Rx/mean(abs(Rx));
figure;plot(Rx,'.');