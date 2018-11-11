% The Program to construct a  short length of QC LDPC codes without girth 4 and girth 6
% Copyright (C) Yang XIAO, Jun FAN, BJTU, July 26, 2007, E-Mail: yxiao@bjtu.edu.cn.
% 
% This program presents an approach [1] for constructing  the short length of LDPC codes with girth 8. 
% First, we design 3 submatrices with different shifting functions given by our schemes, 
% then combine them into a matrix according to our approach, finally, expand the matrix 
% into a desired parity-check matrix using identity matrices and cyclic shift matrices 
% of the identity matrices. 
% The simulation results in AWGN channels show that the codes which can be obtained by 
% the generator matrix derived from this check matrix for encoding the random information
% bits are as good as random LDPC codes [1]. 
% 
% Ref:
% [1] J. Fan, Y. Xiao, ¡°A design of LDPC codes with large girth based on the sub-matrix shifting¡±, 
% IET International Conference on Wireless Mobile and Multimedia Networks Proceedings (ICWMMN 2006),
% (CP525), p. 295, Hangzhou, China, 6-9 Nov. 2006 , ISBN: 0 86341 644 6 
% [2] J. Fan, Y. Xiao, A method of counting the number of cycles in LDPC codes,  8th International
% Conference on Signal Processing, ICSP 2006,Volume: 3, ISBN: 0-7803-9737-1, Digital Object Identifier:
% 10.1109/ICOSP.2006.345906
% The papers [1] and [2] can be downloaded from Web site of IET Digital Library and IEEE Explore.

clear;
D0=zeros(6,36);
D0(:,1)=1;
E0=zeros(6,36);
E0(:,1:6)=eye(6);
F0=zeros(6,36);
for i=1:6
    F0(i,(i-1)*6+1)=1;
end

NT1=1;
NT2=6*NT1;
for i=1:36
    DD(:,:,i)=circshift(D0,[0,(i-1)*NT1]);
end
%stop
E1=[E0;E0;E0;E0;E0;E0];
E2=circshift(E1,[0,NT2]);
E3=circshift(E2,[0,NT2]);
E4=circshift(E3,[0,NT2]);
E5=circshift(E4,[0,NT2]);
E6=circshift(E5,[0,NT2]);

F1=circshift(F0,[0,NT1]);
F2=circshift(F1,[0,NT1]);
F3=circshift(F2,[0,NT1]);
F4=circshift(F3,[0,NT1]);
F5=circshift(F4,[0,NT1]);

F6=[F0;F1;F2;F3;F4;F5];

D=[DD(:,:,1);DD(:,:,2);DD(:,:,3);DD(:,:,4);DD(:,:,5);DD(:,:,6);...
    DD(:,:,7);DD(:,:,8);DD(:,:,9);DD(:,:,10);DD(:,:,11);DD(:,:,12);...
    DD(:,:,13);DD(:,:,14);DD(:,:,15);DD(:,:,16);DD(:,:,17);DD(:,:,18);...
    DD(:,:,19);DD(:,:,20);DD(:,:,21);DD(:,:,22);DD(:,:,23);DD(:,:,24);...
    DD(:,:,25);DD(:,:,26);DD(:,:,27);DD(:,:,28);DD(:,:,29);DD(:,:,30);...
     DD(:,:,31);DD(:,:,32);DD(:,:,33);DD(:,:,34); DD(:,:,35);DD(:,:,36)];
E=[E1;E2;E3;E4;E5;E6];
F=[F6;F6;F6;F6;F6;F6];
H1=[D,E,F];

H=H1';
M=size(H,1);
N=size(H,2);

% We can test girth 4 by using the matrix O, see [1].

O=H*H';   
for i=1:M
    O(i,i)=0;
end
for i=1:M
girth(i)=max(O(i,:));
end
girth4=max(girth);

if girth4<2 
  fprintf('No girth 4\n')
else
   fprintf('The H matrix has girth 4\n')  % Provde the test result.
end    
% Display the matrice H and O
% If H matrix has no gith4, the O matrix in Fig.2 has no entry value to
% larger than 1.
figure(1)
mesh(H)
figure(2)
mesh(O)
fprintf('Please see your H matrix in Fig. 1, and the O matrix in Fig.2')
