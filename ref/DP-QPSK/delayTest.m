function [output,Time_pt]=delayTest(input,Nb0)
%% Timing for each Channel
close all;

Nb=Nb0*10;
% input=angle(input)-mean(angle(input));
% input=mod((input+2*pi),2*pi);
I1_1=resample(input,Nb/Nb0,1);tmp=I1_1;


for m=1
I1_1=[0;abs(diff(I1_1)).^2];
% I1_1=[0;diff(abs(I1_1).^2)];
end
I1_1(1:100)=0;
% [loc,val]=find((abs(I1_1)>max(I1_1)*0.6)==1);
[val,loc]=findpeaks(I1_1,'minpeakheight',max(I1_1)*0.4);
% Loc_M=[mod(loc,Nb)==0,mod(loc,Nb)==1,mod(loc,Nb)==2,mod(loc,4)==3];
Loc_M=2*ones(length(loc),Nb);
for m=0:Nb-1
Loc_M(:,m+1)=(mod(loc,Nb)==m);
end
[~,Time_pt]=max(sum(Loc_M))
                figure,plot(sum(Loc_M))
                figure,plot(tmp(Time_pt+Nb-ceil(Nb/2):Nb:end),'.')
output=tmp(Time_pt+Nb-Nb/2:Nb:end);
