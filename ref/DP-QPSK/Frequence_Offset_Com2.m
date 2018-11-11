function  Frequence_Offset_Com2(streamX_pol)
streamX_pola=streamX_pol;
streamX_polb=circshift(streamX_pol,[-1,1]);
dphi=angle(streamX_pola.*conj(streamX_polb));
DPOrate=50e9;
df=mean(dphi)*DPOrate/pi/2;
t=(1:length(streamX_pola))'/DPOrate;
output=streamX_pol.*exp(-j*2*pi*df.*t);
 figure,plot(10*log10(abs(fft(output))))







end