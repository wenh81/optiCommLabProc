function output =  signal_resconstruction(xn)
%% KK
%% reference: OFC
% l = length(xn); %xn = |s(t)|^2
% a = [zeros(1,l) fftshift(fft(xn)) zeros(1,l)];
% b = ifft(fftshift(a));  %upsample
% It = real(b);   %It = A(1 + st/A*exp(jwt))
NN = 4;
It = resample(xn,NN,1);

% figure
% periodogram(log(It))
phi = 0.5.*imag(hilbert(log(It))); 
% save F:\仿真\PAM系统\VPI\双路单边带复用系统\TWINSSB\Rx\phi phi

output = (sqrt(It).*exp(-1j.*phi));%in order to compensate the CD
% output = real(sqrt(It).*exp(1j.*phi));
% output = output(1:3:end);
output = resample(output,1,NN);
%% reference: null



end