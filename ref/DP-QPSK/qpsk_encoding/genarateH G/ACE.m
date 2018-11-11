%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Bachelor of Science Graduation Dissertation
% ACE algorithm for Constructing LDPC Codes
% Copyright (C) 2009, Duanmu Fanyi, BIT
% Code Designed by Student Duanmu Fanyi (Reg. No. 20050042)
% Directed by Fan Guangrong
% Class 01510500, Department of Electronic Engineering, 
% School of Information Science, Beijing Institute of Technology
% Reference:
% T Tao, C Jones, Villasenor R.D. and R Wesel. Construction of Irregular LDPC Codes with Low Error Floors [J]. IEEE
% Trans. Comm, 2003, 3: 3125-3129.
% For simplicity and efficiency, the M and N is set small, just for algorithm test

% Initialization
% ¡°m¡± indicate the row number, and ¡°n¡± indicate the column number
% ¡°dc¡± indicate the maximum number of ¡°1¡±s in one column, and ¡°dr¡± indicate the maximum number of ¡°1¡±s in one %row
% row_sum counts the number of ¡°1¡±s in one row
% H1 and H2 are submatrix of final H matrix
% rank_num is used to check whether H2 is full-ranked or not
% cir is used to count the actual effective number of target column vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% m=5;
% n=10;
% k=5;
% R=0.5;
m=2520;
n=10080;
k=n-m;
R=0.75;
dc=3;
dr=6;

row_sum=zeros(5,1);       
Column_Vector=zeros(5,1); 
H1=zeros(m,k);
H2=zeros(m,m);
H=[H1,H2];

row_num=5;
col_num=10;

rank_num=1;
cir=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)
Column=col_num-cir;
% redo:
% detect row degree
   row_sum=zeros(5,1);
   for c1=1:5
    for c2=1:10
     if H(c1,c2)~=0
      %temp1=c1;
      %temp2=c2;
       row_sum(c1,1)=row_sum(c1,1)+1;
     end;
    end;
   end;

% Get Target Rows with smallest degree
    [v index]=sort(row_sum);

% Create Vi
% check bits, randomly generation
   if Column>5
      a=[1:5].';
      for i=1:5
       b=fix(rand(1)*5)+1;
       tmp=a(i);
       a(i)=a(b);
       a(b)=tmp;
      end
      Column_Vector=zeros(5,1);
      for k=1:3
       Column_Vector(a(k),1)=1;
      end;
% informationo bits, uniformly generation
   else
      Column_Vector=zeros(5,1); 
       for k=1:3 
         Column_Vector(index(k),1)=1;
       end;
   end;
% obtain final H matrix
   for row_num=1:5
    H(row_num,Column)=Column_Vector(row_num,1);
    H2=H(:,6:10);
    H1=H(:,1:5);
   end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACE processing
  if Column>m      %vi is a parity bit(check bit)    
% detect H2¡¯ rank. If it is full, continue to ACE detection; If it is not full, go back to redo and generate another column % vector
    GE_num=rank(H2);
    if GE_num~=rank_num 
      continue; %goto redo
    end;
  end;

% ACE detection for vi
% if ACE not applicable, goto redo; if ACE applicable, actual circulation increases and the H2¡¯s rank increases
  cir=cir+1;
  rank_num=rank_num+1;
% If and only if circulation reaches the target column number, stop; else continue to generate new column vectors
  if cir==10
    break;
  end;
end; %end while(1)













