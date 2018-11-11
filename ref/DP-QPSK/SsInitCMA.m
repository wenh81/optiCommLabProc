function [Pol_X,Pol_Y]=SsInitCMA(Pol_x_Rx,Pol_y_Rx,N,NoTaps_CMA)
%% Get inverse matrix
ex=Pol_x_Rx(1:N);ey=Pol_y_Rx(1:N);
exy=[ex;ey];
%=======================================================%
exy=exy/sqrt(mean(mean(abs(exy).^2)))/2;
ex=exy(1,:);ey=exy(2,:);

x=ex.*conj(ex)-ey.*conj(ey);
y=conj(ex).*ey+ex.*conj(ey);
z=-1j*conj(ex).*ey+1j*ex.*conj(ey);

xm = mean(x); ym = mean(y); zm = mean(z); 
A=[x(:)-xm, y(:)-ym, z(:)-zm];
[u,s,v]=svd(A,0);
Nor = v(:,end);  %plane normal
s1 = Nor(1,1);
s2 = Nor(2,1);
s3 = Nor(3,1);
normal = [s1,s2,s3]; %normal for the plane
%Then the best-fitting plane in the above sense is given by the equation
% z = zm-s1*(x-xm)/s3 -s2*(y-ym)/s3;

% theta = acos(s1/sqrt(s1^2+s2^2+s3^2));
% if theta >= pi/2
% if s3 > 0
%     s1 = -s1;
%     s2 = -s2;
%     s3 = -s3;
%     normal = [s1,s2,s3]; 
% end

%
 s1=s1;s2=s2;s3=s3;
                                %  figure,plot3(x,y,z,'.'),grid on;
phi=atan2(s2,s1)/2;
eph=atan2(s3,sqrt(s1^2+s2^2))/2;
mce=cos(eph);mse=sin(eph);
mcp=cos(phi);msp=sin(phi);
M_inverse = [mce*mcp+1j*mse*msp mce*msp-1j*mse*mcp;-mce*msp-1j*mse*mcp mce*mcp-1j*mse*msp];
% M_inverse = [cos(eph)*cos(phi)+j*sin(eph)*sin(phi) cos(eph)*sin(phi)-j*sin(eph)*cos(phi);...
%     -cos(eph)*sin(phi)-j*sin(eph)*cos(phi) cos(eph)*cos(phi)-j*sin(eph)*sin(phi) ]


% phi=atan2(s3,s2)/2;
% eph=atan2(sqrt(s2^2+s3^2),s1)/2;
% mce=cos(eph);mse=sin(eph);
% mcp=cos(phi);msp=sin(phi);
% M_inverse=[mce*mcp+1j*mce*msp mse*mcp-1j*mse*msp;-mse*mcp-1j*mse*msp mce*mcp-1j*mce*msp];
M11 = M_inverse(1,1);
M12 = M_inverse(1,2);
M21 = M_inverse(2,1);
M22 = M_inverse(2,2);
D1 = abs(M11*M22);
D2 = abs(M12*M21);
if D1<D2
   M_inverse = [M21 M22;M11 M12];
end    
% if M11*M22<0
%      M_inverse = [M21 M22;M11 M12];
% end
ex=Pol_x_Rx;ey=Pol_y_Rx;
exy=[ex;ey];
data=M_inverse*exy;
Pol_X_S=data(1,:);
Pol_Y_S=data(2,:);
M=inv(M_inverse);
%% CMA
%  NoTaps_CMA=15;      %Number of taps for CMA Equalization
                   mu=0.006;            % coarse stepsize
                   mu_refine=0.0002;    %fine stepsize
                   CenterIndex=round(NoTaps_CMA/2);
                   Pol_x_Rx0=Pol_X_S;
                   Pol_y_Rx0=Pol_Y_S;

                   Pol_x_Rx=[Pol_x_Rx0(end-CenterIndex+2:end),Pol_x_Rx0,Pol_x_Rx0(1:CenterIndex-1)];
                   Pol_y_Rx=[Pol_y_Rx0(end-CenterIndex+2:end),Pol_y_Rx0,Pol_y_Rx0(1:CenterIndex-1)];
%                    Pol_x_Rx=Pol_x_Rx0;
%                    Pol_y_Rx=Pol_y_Rx0;
                   H_xx=[zeros(CenterIndex-1,1); M(1,1); zeros(CenterIndex-1,1)];
                   H_xy=[zeros(CenterIndex-1,1); M(1,2); zeros(CenterIndex-1,1)];
                   H_yx=[zeros(CenterIndex-1,1);-conj( M(1,2)); zeros(CenterIndex-1,1)];
                   H_yy=[zeros(CenterIndex-1,1); conj(M(1,1)); zeros(CenterIndex-1,1)];
                   tmpLength=length(Pol_y_Rx)-NoTaps_CMA+1;
                   MeanPower1=mean(abs(Pol_x_Rx).^2);
                   Pol_x_Rx=Pol_x_Rx./sqrt(MeanPower1)*sqrt(1);
                   MeanPower2=mean(abs(Pol_y_Rx).^2);
                   Pol_y_Rx=Pol_y_Rx./sqrt(MeanPower2)*sqrt(1);

                   epsilon_x=zeros(1,length(Pol_y_Rx));
                   epsilon_y=zeros(size(epsilon_x));
%CMA Adaptation process 
epsilon_x=[];
epsilon_y=[];
                   for iter=1
                           for i=1:10000 %length(Pol_X_input)%
                           %butterfly-like CMA filter    
                                 Pol_X_input=Pol_x_Rx(i+NoTaps_CMA-1:-1:i).';
                                 Pol_Y_input=Pol_y_Rx(i+NoTaps_CMA-1:-1:i).';
                                 Pol_X=H_xx.'*Pol_X_input+H_xy.'*Pol_Y_input;
                                 Pol_Y=H_yx.'*Pol_X_input+H_yy.'*Pol_Y_input;
                                 epsilon_x(i)=1-abs(Pol_X)^2;%mean square error
                                 epsilon_y(i)=1-abs(Pol_Y)^2;
                                 H_xx=H_xx+mu*epsilon_x(i)*Pol_X*conj(Pol_X_input);
                                 H_xy=H_xy+mu*epsilon_x(i)*Pol_X*conj(Pol_Y_input);
                                 H_yx=H_yx+mu*epsilon_y(i)*Pol_Y*conj(Pol_X_input);
                                 H_yy=H_yy+mu*epsilon_y(i)*Pol_Y*conj(Pol_Y_input); 

%                                  if iter==1
                                 temp(:,i)=H_xy;%figure,plot(abs(temp(1,:)))
%                                  end
%                                  epsilon_x(i)=sign(Pol_X)*(abs(Pol_X)-1);%mean square error
%                                  epsilon_y(i)=sign(Pol_Y)*(abs(Pol_Y)-1);
%                                  H_xx=H_xx+mu*epsilon_x(i)*conj(Pol_X_input);
%                                  H_xy=H_xy+mu*epsilon_x(i)*conj(Pol_Y_input);
%                                  H_yx=H_yx+mu*epsilon_y(i)*conj(Pol_X_input);
%                                  H_yy=H_yy+mu*epsilon_y(i)*conj(Pol_Y_input);  
                                 
                           end
                   
                              figure,plot(epsilon_x),title('epsilon1')
                     end
%% CMA Adaptation process 
                  for i=1:tmpLength
                           %butterfly-like CMA filter
                        Pol_X_input=Pol_x_Rx(i+NoTaps_CMA-1:-1:i).';
                        Pol_Y_input=Pol_y_Rx(i+NoTaps_CMA-1:-1:i).';
                        ii=ceil(i);
                        Pol_X(ii)=H_xx.'*Pol_X_input+H_xy.'*Pol_Y_input;
                        Pol_Y(ii)=H_yx.'*Pol_X_input+H_yy.'*Pol_Y_input;
                        epsilon_x(ii)=1-abs(Pol_X(ii))^2;%mean square error
                        epsilon_y(ii)=1-abs(Pol_Y(ii))^2;
                        H_xx=H_xx+mu_refine*epsilon_x(ii)*Pol_X(ii)*conj(Pol_X_input);
                        H_xy=H_xy+mu_refine*epsilon_x(ii)*Pol_X(ii)*conj(Pol_Y_input);
                        H_yx=H_yx+mu_refine*epsilon_y(ii)*Pol_Y(ii)*conj(Pol_X_input);
                        H_yy=H_yy+mu_refine*epsilon_y(ii)*Pol_Y(ii)*conj(Pol_Y_input);
temp2(:,i)=H_xy;%figure,plot(abs(temp2(1,:)))
%                                  epsilon_x(i)=sign(Pol_X(ii))*(abs(Pol_X(ii))-1);%mean square error
%                                  epsilon_y(i)=sign(Pol_Y(ii))*(abs(Pol_Y(ii))-1);
%                                  H_xx=H_xx+mu*epsilon_x(i)*conj(Pol_X_input);
%                                  H_xy=H_xy+mu*epsilon_x(i)*conj(Pol_Y_input);
%                                  H_yx=H_yx+mu*epsilon_y(i)*conj(Pol_X_input);
%                                  H_yy=H_yy+mu*epsilon_y(i)*conj(Pol_Y_input);  

                       
                  end
                  figure,plot(epsilon_x),title('epsilon2')
%                    average_x2=sqrt(sum(abs(Pol_X).^2)/length(Pol_X));
%                    display_x2= Pol_X/average_x2*sqrt(2);
%                    scatterplot(display_x2);
                   average_x2=sqrt(sum(abs(Pol_X).^2)/length(Pol_X));
                   display_x2= Pol_X/average_x2*sqrt(2);
                   scatterplot(display_x2);
                   set(gca,'YLim',[-2.5,2.5])
                   set(gca,'XLim',[-2.5,2.5])
                   set(gca,'ytick',-2:1:2,'yticklabel',(-2:1:2));
                   set(gca,'xtick',-2:1:2,'xticklabel',(-2:1:2));
                   grid on 
                   
                   average_y2=sqrt(sum(abs(Pol_Y).^2)/length(Pol_Y));
                   display_y2= Pol_Y/average_y2*sqrt(2);
                   scatterplot(display_y2);
                   set(gca,'YLim',[-2.5,2.5])
                   set(gca,'XLim',[-2.5,2.5])
                   set(gca,'ytick',-2:1:2,'yticklabel',(-2:1:2));
                   set(gca,'xtick',-2:1:2,'xticklabel',(-2:1:2));
                   grid on 
                   E=[H_xx,H_xy,H_yx,H_yy];
%                   save('E:\【1】科研\【项目】偏振解复用1\VPI_PDM\仿真对比\FDE-FSEMMSE\DBP.vtmu_pack\Resources\DBP_receiver.vtmg_pack\Inputs\ECMA.mat','E')
    