function output=Volterra_RLS(xn,dn,w,delta,N,Fl,Sl,Tl)
l=length(xn);  %输入数据的长度
%Fl,Sl,Tl分别代表1 2 3 阶滤波器长度
%初始化一阶 二阶 三阶 滤波器
%%   初始化滤波器输入矩阵
x1=zeros(Fl,l);
x2=zeros(Sl*(Sl+1)/2,l);
x3=zeros(Tl*(Tl+1)*(Tl+2)/6,l);
%计算各阶滤波器输入
% 一阶滤波器
yn=[zeros(1,200) xn zeros(1,200)];
% fl=0;
sl=0;
tl=0;
fl=ceil(Fl/2);
% sl=ceil(Sl/2);
% tl=ceil(Tl/2);
flag1=0;
% flag2=0;%floor((Sl-1)/2);%修改这里就可以了
% flag3=0;%floor((Tl-1)/2);%修改这里就可以了
flag2=floor((Sl-1)/2);%修改这里就可以了
flag3=floor((Tl-1)/2);%修改这里就可以了
for i=1:l
    for j=1:Fl
        x1(j,i)=yn(200+fl+i-j+flag1);
    end
end
 % 二阶滤波器
for k=1:l
     m_=0;   %计数
     for m=1:Sl
         for n=m:Sl
             m_=m_+1;
             x2(m_,k)=yn(200+k-m+1-sl+flag2)*yn(200+k-n+1-sl+flag2);
         end 
     end
end
    

% 三阶滤波器
for ii=1:l
     m_=0;   %计数
     for jj=1:Tl
         for kk=jj:Tl
             for ll=kk:Tl
                 m_=m_+1;
                 x3(m_,ii)=yn(200+ii-jj+1-tl+flag3)*yn(200+ii-kk+1-tl+flag3)*yn(200+ii-ll+1-tl+flag3);
             end
         end
      end
end

X=[x1;x2;x3];   %volterra输入矩阵
% save algorithm\volterra\volterra_Matrix X;
%%
%初始化迭代参数
pN=eye(size(X,1))/delta;      
en=zeros(1,N);                 %误差序列  
h=zeros(size(X,1),N);          %volterra核迭代矩阵
yn=zeros(1,N);                 %输出序列
%RLS迭代算法
for k=2:N
    yn(k)=h(:,k-1)'*X(:,k);   
    en(k)=dn(k)-yn(k);        
    kn=pN*X(:,k)/(w+X(:,k)'*pN*X(:,k));
    pN=pN/w-kn*X(:,k)'*pN/w;
    h(:,k)=h(:,k-1)+kn*en(k);
end
% figure
% plot(h');

% figure
% save algorithm\volterra\volterra_kernel h;
H=h(:,N);  
output=H'*X;                %volterra均衡后输出
end
