function [x_hat, success, k] = ldpc_Qi_decode_v3_30822(llr,H)
% load y.mat; load llr.mat; load H.mat;
% ccc;tic;
% llr=[-0.5 2.5 -4 5 -3.5 2.5];
% H=[1 1 0 1 0 0; 0 1 1 0 1 0; 1 0 0 0 1 1; 0 0 1 1 0 1];
% H = alist2sparse('D:\lab\OFC2011\LDPC\Ivan\H\2011-09-15\Hmatrix.dat');
% load H.mat;
% [a b]=size(H);
% llr=rand(1,b);
%% 

[m,n] = size(H); 
if m>n, H=H'; [m,n] = size(H); end
if ~issparse(H) % make H sparse if it is not sparse yet
   [ii,jj,sH] = find(H);
   H = sparse(ii,jj,sH,m,n);
end

NNN=16;
[a b]=size(H);
llr_matrix=repmat(llr,a/NNN,1);
M0=[];
for ii=1:NNN
    sub_H=H((ii-1)*a/NNN+1:ii*a/NNN,:);
    sub_H1=full(sub_H);
    M0=[M0;sparse(sub_H1.*llr_matrix)];
end
clear sub_H1;

%iterations
k=0;
success = 0;  
max_iter = 25;
while ((success == 0) && (k < max_iter))
    k = k+1;
    if(k==1)        
        M=M0;     
    end
 % fill E matrix
%  toc
    iii=[];jjj=[];sss=[];
    for ii=1:m
        [a,b]=find(M(ii,:));
%         if(ii==1201)
%         end
        A=M(ii,b);
        B=tanh(A/2);
        C=prod(B,2);
        D=C./B;
        E_Temp=log((1+D)./(1-D));
        E_Temp1=floor(abs(E_Temp)/1000);
        E_Temp2=find(E_Temp1);
        if(sum(abs(E_Temp2))>0)
            [aa bb]=find(E_Temp1);
            for jj=1:length(aa)
                E_Temp(aa(jj),bb(jj))=1000*sign(E_Temp(aa(jj),bb(jj)));
            end
        end
        
        iii=[iii;a.'*ii];
        jjj=[jjj;b.'];
        sss=[sss;E_Temp.'];        
    end
    E = sparse(iii,jjj,sss); 
%     toc
    
% current total LLR    
    L=sum(E)+llr;

% HD for current test
    z=(-sign(L)+1)/2;
    
    check=mod(z*H',2);
    if ~(sum(check)) 
        x_hat=z;
        success=1; 
    else         
% toc       
        [a b]=size(H);
        L_matrix=repmat(L,a/NNN,1);
        M_temp=[];
        for ii=1:NNN
            sub_E=E((ii-1)*a/NNN+1:ii*a/NNN,:);
            sub_E1=full(sub_E);
            sub_E2=abs(sign(sub_E));
            AAA=L_matrix.*sub_E2-sub_E1;
            M_temp=[M_temp;sparse(AAA)];
        end
        M=M_temp;
        clear sub_E1 sub_E2 L_matrix;       
%         toc
        
        x_hat=z;
        if(mod(k,1)==0)        
            fprintf([' ' num2str(k)]); end
        
    end

end

