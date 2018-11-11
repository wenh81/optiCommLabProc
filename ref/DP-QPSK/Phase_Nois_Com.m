function [R] =Phase_Nois_Com(R_signal,N)
% *************************************************************** %
 %-------------Phase Noise Estimation and Compensation--------------%
 % *************************************************************** %
load data\QPSKpara
M              = QPSKpara.M1;        

phase=unwrap(angle(smooth(R_signal.^M,N))).'/M;
R_signal=R_signal.'.*exp(-1j*phase);
figure;plot(R_signal(200:end-200),'.');axis([-2,2,-2,2])
load data/X_Tx

% CR_siginal=mean(R_signal(1:128)./X_Tx(1:128),2);
% R_signal =R_signal*conj(CR_siginal)/abs(CR_siginal)^2;
 R=R_signal/mean(abs(R_signal));
% figure;plot(R,'.');