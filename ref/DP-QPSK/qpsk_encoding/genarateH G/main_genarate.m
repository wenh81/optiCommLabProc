 
 % This program is to construct a random LDPC codes by using the bit filling method[1]. 
 % 
 % Ref:
 % [1] J. Campellot, D. S. Modhat and S. Rajagopalant. "Designing LDPC
 % Codes Using Bit-Filling". ICC 2001, pp. 55–59, 2001.
 %
 % The paper[1] can be downloaded from Web site of IEEE Explore.
 %
 
 %   Copyright (C) 2007, Guangrong Fan. MCL. BIT.
 %   $Revision: 1.0 $  $Date: 2007/07/30 21:12:41 $
 
 clear;
 clc;
 
 %============ Parameters related to parity check matrix ============%
 M = 1640;          % 校验矩阵行数
 N =9832;         % 校验矩阵列数
 cols_w = 4;      % The column weight
 girth =6;       % The demand girth length

 %============ Initialization ============%
 H = sparse(M,N);
 n = 0;
 U1 = []; 
 ck_deg(1:1:M) = 0;
 
 max_rows = ceil(cols_w*N/M);    % The maximum row weight

 %======================= Bit Filling =======================%
 while ( (n == 0) | ((i==cols_w) & (~isempty(F0))) ) 
    A = 1:1:M;
   
    %对于c属于U1,置ck_deg(c)增加1,令H(c,n) = 1
    for j = 1:1:length(U1)
        H(U1(j),n) = 1;
        ck_deg(U1(j)) = ck_deg(U1(j)) + 1;
    end
    l = find(ck_deg == max_rows); 
    A(l) = [];     %%除去校验节点的度大于max_rows的节点                                                                
    %%%%%%%%%%%%%%%%%%%%
    i = 0;
    U1 = [];
    U = [];
    F0 = A;
    while ( (i < cols_w) & (~isempty(F0)) )
            for j = 1:1:length(U);
                l = (find(F0==U(j)));
                F0(l) = [];   %计算 F0 = A\U
            end
            if ( ~isempty(F0) )  
                [min_y,min_i] = min_v(ck_deg(F0));
                min_v_num = length(min_i);
                if ( min_v_num > 1)                  
                  new_cn = F0(min_i(unidrnd(min_v_num)));
                else  
                  new_cn = F0(min_i);
                end;
                U1 = [U1,new_cn];  
                U_tmp = srh_cn_set(new_cn,H,girth);
                U = [U1,U_tmp];
                U = unique(U);
                i = i + 1;                             
            end
         
    end  %%while
    if ( (i == cols_w) & (~isempty(F0)))
      n = n+1; 
    end;
 end %%while
 %%%%%%%%%%%%%%%%%%%%%%%%%

 %================ Get the parity check matrix H ================%
 if ( n > N )
   H = sparse(H(:,1:1:N));
 else
   H = sparse(H(:,1:1:n));    
 end;
 
H=full(H);
x=H;
[Hm,Hn]=size(x);
y =1;% 标志位，确定最后生成的G是右边为单位阵(iny = 1),还是左边为单位阵(iny = else)
x=x(randperm(Hm),:);
x=x(:,randperm(Hn));
[outputH,outputG]=GassianXY(x,y);% 调用GassianXY将x处理，返回一个最终的校验矩阵H和生成矩阵G
 
 save('F:\【项目】西安光机所\QPSK\fec\genarateH G\H1640_9832.mat','outputH');
 
 save('F:\【项目】西安光机所\QPSK\fec\genarateH G\G8192_9832.mat','outputG');

 
 
 