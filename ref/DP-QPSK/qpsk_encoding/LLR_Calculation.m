function [APPllr1,EXACTllr1,S]=LLR_Calculation(receivedsig,M)

load  data\data_dec.mat
%%求近似的LLR   16QAM gray
%%Approximate LLR is computed by using only the nearest constellation point to the received signal
%%with a 0 (or 1) at that bit position, rather than all the constellation points
% function ap_llr=approximate_llr4(ts,receivedsig,sigma)

ts_enc=data_dec.';
a=receivedsig;
% sigma=0.1;%基带信号的噪声方差
APPllr=ones(length(a),log2(M));
APPllr1=ones(length(a),log2(M));
EXACTllr=ones(length(a),log2(M));
EXACTllr1=ones(length(a),log2(M));
APPllr1_p=ones(length(a),log2(M));
EXACTllr1_p=ones(length(a),log2(M));
%%求均值，确定中心位置
U=zeros(1,M);S=zeros(1,M);P=zeros(1,M);
for m=0:M-1
    U(m+1)=mean( a(ts_enc==m) );%%%发送序列用于统计中心位置和方差
    S(m+1)=var( a(ts_enc==m) );
    P(m+1)=sum(ts_enc==m)./length(ts_enc);
end
sigma=mean(S);
switch M
%     case 16 %%16QAM
%         con11=U(9:16);                                      con10=U(1:8);%%从高位到低位 第一位为1/0 的星座点
%         con21=[U(5:8),U(13:16)];                            con20=[U(1:4),U(9:12)];
%         con31=[U(3),U(4),U(7),U(8),U(15),U(16),U(11),U(12)];con30=[U(1),U(2),U(5),U(6),U(13),U(14),U(9),U(10)];
%         con41=[U(2),U(4),U(6),U(8),U(14),U(16),U(10),U(12)];con40=[U(1),U(3),U(5),U(7),U(13),U(15),U(9),U(11)];
%         CON1=[con11;con21;con31;con41]; CON0=[con10;con20;con30;con40];
%         %%%星座点对应的概率
%         pro11=P(9:16);                                       pro10=P(1:8);%%从高位到低位 第一位为1/0 的星座点
%         pro21=[P(5:8),P(13:16)];                            pro20=[P(1:4),P(9:12)];
%         pro31=[P(3),P(4),P(7),P(8),P(15),P(16),P(11),P(12)];pro30=[P(1),P(2),P(5),P(6),P(13),P(14),P(9),P(10)];
%         pro41=[P(2),P(4),P(6),P(8),P(14),P(16),P(10),P(12)];pro40=[P(1),P(3),P(5),P(7),P(13),P(15),P(9),P(11)];
%         PRO1=[pro11;pro21;pro31;pro41]; PRO0=[pro10;pro20;pro30;pro40];
        
    case 4 %QPSK
        con11=U(3:4);                                      con10=U(1:2);%%从高位到低位 第一位为1/0 的星座点
        con21=[U(2),U(4)];                                 con20=[U(1),U(3)];
        CON1=[con11;con21]; CON0=[con10;con20];
    case 2  %BPSK
        con11=U(2);                                      con10=U(1);%%从高位到低位 第一位为1/0 的星座点
        CON1=con11; CON0=con10;
end


for w1=1:length(a)
    %%%1
    %     %%第一位
    %     APPllr(w1,1)=(-1/sigma)*( min((a(w1)-con10).*conj(a(w1)-con10)) - min((a(w1)-con11).*conj(a(w1)-con11)) );
    %     %%第二位
    %     APPllr(w1,2)=(-1/sigma)*( min((a(w1)-con20).*conj(a(w1)-con20)) - min((a(w1)-con21).*conj(a(w1)-con21)) );
    %     %%第三位
    %     APPllr(w1,3)=(-1/sigma)*( min((a(w1)-con30).*conj(a(w1)-con30)) - min((a(w1)-con31).*conj(a(w1)-con31)) );
    %     %%第四位
    %     APPllr(w1,4)=(-1/sigma)*( min((a(w1)-con40).*conj(a(w1)-con40)) - min((a(w1)-con41).*conj(a(w1)-con41)) );
    
    %% 2
    for v1=1:1:log2(M)
        APPllr1(w1,v1)=(-1/sigma)*( min((a(w1)-CON0(v1,:)).*conj(a(w1)-CON0(v1,:))) - min((a(w1)-CON1(v1,:)).*conj(a(w1)-CON1(v1,:))) );
    end
    
    %     for v4=1:1:log2(M)
    %         APPllr1_p(w1,v4)=(-1/sigma)*( min(log(PRO0(v4,:))+(a(w1)-CON0(v4,:)).*conj(a(w1)-CON0(v4,:))) - min(log(PRO1(v4,:))+(a(w1)-CON1(v4,:)).*conj(a(w1)-CON1(v4,:))) );
    %     end
end

for w2=1:length(a)
    %%%1
    %     %%第一位
    %     sum10=sum( exp( (-1/sigma).*((a(w2)-con10).*conj(a(w2)-con10)) ));
    %     sum11=sum( exp( (-1/sigma).*((a(w2)-con11).*conj(a(w2)-con11)) ));
    %     EXACTllr(w2,1)=log(sum10/sum11);
    %     %%第二位
    %     sum20=sum( exp( (-1/sigma).*((a(w2)-con20).*conj(a(w2)-con20)) ));
    %     sum21=sum( exp( (-1/sigma).*((a(w2)-con21).*conj(a(w2)-con21)) ));
    %     EXACTllr(w2,2)=log(sum20/sum21);
    %     %%第三位
    %     sum30=sum( exp( (-1/sigma).*((a(w2)-con30).*conj(a(w2)-con30)) ));
    %     sum31=sum( exp( (-1/sigma).*((a(w2)-con31).*conj(a(w2)-con31)) ));
    %     EXACTllr(w2,3)=log(sum30/sum31);
    %     %%第四位
    %     sum40=sum( exp( (-1/sigma).*((a(w2)-con40).*conj(a(w2)-con40)) ));
    %     sum41=sum( exp( (-1/sigma).*((a(w2)-con41).*conj(a(w2)-con41)) ));
    %     EXACTllr(w2,4)=log(sum40/sum41);
    %% 2
    for v2=1:1:log2(M)
        EXACTllr1(w2,v2)=log((sum( exp( (-1/sigma).*((a(w2)-CON0(v2,:)).*conj(a(w2)-CON0(v2,:))) )))/(sum( exp( (-1/sigma).*((a(w2)-CON1(v2,:)).*conj(a(w2)-CON1(v2,:))) ))));
    end
    
    %     for v3=1:1:log2(M)
    %         EXACTllr1_p(w2,v3)=log((sum( PRO0(v3,:).*(exp( (-1/sigma).*((a(w2)-CON0(v3,:)).*conj(a(w2)-CON0(v3,:))) ))))/(sum(PRO1(v3,:).*( exp( (-1/sigma).*((a(w2)-CON1(v3,:)).*conj(a(w2)-CON1(v3,:))) )))));
    %     end
end
end