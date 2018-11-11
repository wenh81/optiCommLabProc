function [R,head1] = QPSK_Synchronous_Head(stream)
% *************************************************************** %
% ------------------------Find Synchronous_Head Block-------------------- %
% *************************************************************** %
load data\transmittedX transmittedX
len1   = length(stream);

index1 = zeros(1,len1-128*8*2);                % preallocating resources for speed
% for i = 1:len1-128*2*8
%     index1(i) = sum((stream(i:i+128*8-1).*conj(stream(i+128*8:i+128*2*8-1))));
% end
% [peak,head1] = max(abs(index1));
% if head1 > len1/2
%      head1 = head1-length(transmittedX);
% end
for i = 1:floor(len1/2)
    index1(i) = sum((stream(i:i+128*8-1).*conj(stream(i+128*8:i+128*2*8-1))));
end
[peak,head1] = max(abs(index1));

Lzeros=100;
head1 = head1+128*8*2+Lzeros;

figure; set(gcf,'NumberTitle','off');set(gcf,'Name','X_re_Synchronization');
plot(abs(index1));
title('X_re_polSynchronization');

% load data\transmittedX transmittedX
%% ÐÅºÅ¹¹³É length(transmittedX)£º¡¾Z£¨1,100£©head£¨128*2*8£©Z X_Tx¡¿
stream   = stream(head1:head1+length(transmittedX)-(128*2*8)-200-1);  % cut the block out
R=stream;

