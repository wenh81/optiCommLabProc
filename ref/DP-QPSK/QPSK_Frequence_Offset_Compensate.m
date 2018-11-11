function [stream_tmp] = QPSK_Frequence_Offset_Compensate(stream)
% % *************************************************************** %
% % ------------------------Frequence_Offset_Compensate-------------------- %
% % *************************************************************** %
    temp =fft(stream);
    [peak center]=max(abs(temp(100:end)));
    center=center+99;                       %avoid DC
    temp_x= circshift(temp,[-center,0]);    %fre_offset_comp
    stream_tmp=ifft(temp_x);
    figure,plot(10*log10(abs(temp_x)))
