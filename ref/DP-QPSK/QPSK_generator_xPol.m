function [transmittedX] =  QPSK_generator_xPol
% ***************************************************** %
% ------------------ QPSK_siginal_Parameters ------------------ %
% ***************************************************** %


load data\QPSKpara
M              = QPSKpara.M1;                       % bits of per sysmbol
Mode           = QPSKpara.Mode;                     % Remodulation bits of per sysmbol
ModFormat      = QPSKpara.ModFormat;
disp           = QPSKpara.disp;                     % dispersion of the fiber
Length         = QPSKpara.Length;                   % length of fiber
CodeFormat     = QPSKpara.CodeFormat;
OH             = QPSKpara.OH;

% ***************************************************** %
% --------------- loading the binary bits ------------- %
% ***************************************************** %
data_s=load('PRBS15.txt');                           % PRBS15 2^15  32768bits
data_s=repmat(data_s,1,3);   % repmat the data  2^16 bits
data_s=data_s(1:length(data_s)/(1+OH));   %% 给校验位预留空间
save data\data_s.mat data_s
%% FEC
% % load('outputH910_9102.mat')
% % load('outputG8192_9102.mat')
% % G=outputG;H=outputH;
% % data=ldpc_code1220(data_s,G);%%ldpc code
%  anothor function: data=RSconversion(data_s,'coding');
[data,~]=QPSK_FEC_ENC(CodeFormat,OH,data_s);%% 'RS'/'LDPC';1/7 // 1/15;data uncoded

bin = vec2mat(data,log2(M));
dec = bi2de(bin,'left-msb');
data_dec=dec;
save data\data_dec.mat data_dec
 
switch Mode
    case 'PSK'
        
        if isequal(ModFormat,'QPSK')
            data = pskmod(dec,M,[],'gray').';         %Remodulation bits to mode QPSK
        end
        
        if isequal(ModFormat,'DQPSK')
            data = dpskmod(dec,M,[0],'gray').';% RS encoding
            if isequal(CodeFormat,'LDPC')
                d = zeros(1,length(dec)+1);
                d(1)=0;
                for w1=2:length(dec)+1
                    d(w1)=mod(d(w1-1)+dec(w1-1),4);
                end
                dec1=d(1:end);
                data = pskmod(dec1,M,[],'bin');    
            end
        end
        
        if isequal(ModFormat,'BPSK')
            data = pskmod(dec,M,[],'gray').';
        end
        
        if isequal(ModFormat,'DPSK')
            data = dpskmod(dec,M,[0],'gray').';
            if isequal(CodeFormat,'LDPC')
                d = zeros(1,length(dec)+1);
                d(1)=0;
                for w1=2:length(dec)+1
                    d(w1)=mod(d(w1-1)+dec(w1-1),M);
                end
                dec1=d(1:end);
                data = pskmod(dec1,M,[],'bin');
            end
        end
        
        
    case 'QAM'
        data = qammod(dec,M,[],'gray').';
    otherwise error;
end

%%%caogao
% receivedsig = awgn(modulatedsig, 15, 'measured'); scatterplot(receivedsig);

% X_Tx = data(1:length(data)*log2(M)/2);                                      % transmitted X data
X_Tx=data;
save data\X_Tx X_Tx;
X_Tx = X_Tx/mean(abs(X_Tx))*exp(1*j*(pi/4));      % rotate the constellation pi/4 as 4QAM constellation
% ***************************************************** %
% -----------------Add Synchronisation Header---------- %
% ***************************************************** %
head       = load('PRBS7.txt');                                 % length=128
head       = head-0.5;
head       = head.'+j*head.';
syncheader = kron(head,ones(1,8));

syncheader = [syncheader conj(syncheader)];

Z=zeros(1,100);
transmittedX = 100*[Z syncheader*max(abs(X_Tx))*1.1  Z X_Tx];  % transmitted streamX
save data\transmittedX transmittedX;


x           = length(transmittedX);
t           = 1:1:x;
baseWfmX     = real(transmittedX);
baseWfmY     = imag(transmittedX);

baseMarkers = uint8(square(2*pi*1/x*t,50));
%% Create WaveforM11 (Double)

Waveform_Name_1 = 'MyDoubleWfm';

Waveform_Data_1 = baseWfmX;                  % already a double array

Waveform_M1_1   = baseMarkers;              % already uint8 array

Waveform_M2_1   = baseMarkers;

save('AWG_Double', '*_1', '-v7.3');         % MAT 7.3 Can save > 2GB

%% Create WaveforM12 (Single)

Waveform_Name_2 = 'MySingleWfm';

Waveform_Data_2 = baseWfmY;

Waveform_M1_2   = baseMarkers;              % already uint8 array

Waveform_M2_2   = baseMarkers;


save('AWG_Float', '*_2', '-v7.3');