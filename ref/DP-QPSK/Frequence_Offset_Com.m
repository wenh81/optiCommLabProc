function [stream_tmp1,stream_tmp2] = Frequence_Offset_Com(stream1,stream2)
% % *************************************************************** %
% % ------------------------Frequence_Offset_Compensate-------------------- %
% % *************************************************************** %
if nargin>0
    temp =fft(stream1);
    [peak center]=max(abs(temp(100:end-100)));
    center=center+99;                       %avoid DC
    temp_x= circshift(temp,[-center,0]);    %fre_offset_comp
    stream_tmp1=ifft(temp_x);
%     figure,plot(10*log10(abs(temp_x)))
end
if nargin==2
    temp =fft(stream2);
%     [peak center]=max(abs(temp(100:end-100)));
%     center=center+99;                      %avoid DC
    temp_x= circshift(temp,[-center,0]);    %fre_offset_comp
    stream_tmp2=ifft(temp_x);
    figure,plot(10*log10(abs(temp_x)));
end