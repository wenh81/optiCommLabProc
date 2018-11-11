function output=IQimbalance(input,CMA)

RI=real(input);
RQ=imag(input);

%% IQ-imbalance
beta1=RI;
beta2=RQ-sum(RQ.*beta1)/sum(beta1.*beta1)*beta1;%Q
gama1=RQ;
gama2=RI-sum(RI.*gama1)/sum(gama1.*gama1)*gama1;%I
e1=beta1/sqrt(mean(abs(beta1).^2));
e2=beta2/sqrt(mean(abs(beta2).^2));
Rcvr=e1+j*e2;
% figure(2),plot(Rcvr,'.'),axis([-1,1,-1,1]*max(abs(R)))
%% CMA 
if CMA==1
NoTaps_CMA=1;mu=0.001;
CenterIndex=round(NoTaps_CMA/2);
H_xx=[zeros(CenterIndex-1,1); 1; zeros(CenterIndex-1,1)];
H_xy=zeros(NoTaps_CMA,1);
H_yx=zeros(NoTaps_CMA,1);
H_yy=[zeros(CenterIndex-1,1); 1; zeros(CenterIndex-1,1)];
tmpLength=length(e1)-NoTaps_CMA+1;

for iter=1
    for i=1:tmpLength %length(Pol_X_input)%
        %butterfly-like CMA filter
        Pol_X_input=RI(i+NoTaps_CMA-1:-1:i).';
        Pol_Y_input=RQ(i+NoTaps_CMA-1:-1:i).';
        Pol_X=H_xx.'*Pol_X_input+H_xy.'*Pol_Y_input;
        Pol_Y=H_yx.'*Pol_X_input+H_yy.'*Pol_Y_input;
        Y=norm([Pol_X,Pol_Y]);%???
        epsilon(i)=1-Y;%mean square error
        H_xx=H_xx+mu*epsilon(i)*Pol_X*conj(Pol_X_input);
        H_xy=H_xy+mu*epsilon(i)*Pol_X*conj(Pol_Y_input);
        H_yx=H_yx+mu*epsilon(i)*Pol_Y*conj(Pol_X_input);
        H_yy=H_yy+mu*epsilon(i)*Pol_Y*conj(Pol_Y_input);
        output(i)=Pol_X+j*Pol_Y;
    end
end
else
    output=Rcvr.';
end
%% 
% tmp=Rx(10000:10:end)
% opts = statset('Display','final');
% [idx,C]=kmeans([real(tmp)',imag(tmp)'],4,'Distance','cityblock','Replicates',150,'Options',opts)
% figure,plot(Rx','.')
% hold on,plot(C(:,1)+j*C(:,2),'ro')
% figure,plot(angle(S0),angle(Rx),'.')
%%
