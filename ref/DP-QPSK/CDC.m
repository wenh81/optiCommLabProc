function output=CDC(input,disp,fs,L)
%negative "disp" is to compensate the chromatic dispersion, 
%dispersion by ps/nm/km, fs: sample rate by Hz, L: the fiber length in m 
%input must be row wise
%cd(matlabroot)
% cd PCTW_vpi
% save Paratemp_CDC input disp fs L;


Len = size(input,2) ;    
f_step=fs/Len;
freq = ((0:1:Len-1)-Len/2)*f_step; %Frequence in Hz

Spec=fftshift(fft(input.').',2);
delay=freq.*disp*L*1e-12/124.78e9/1e3;% 124.78e9 is 1nm   delay in second

phase =freq.*delay*pi;
%plot(freq,phase)
Spec=Spec.*exp(-1j*phase);%repmat(exp(1j*phase),size(input,1),1);

output=ifft(fftshift(Spec,2).').';