data_s=load('PRBS15.txt');                           % PRBS15 2^15  32768bits
data_s=repmat(data_s,1,4);   % repmat the data  98304 bits
%% fec 编码
OH_LDPC=1/7;   %%LDPC的开销overhead  有两种选择 为1/15 或 1/7
% % OH_RS=  ; %%不是一个确定的值,
data_s=data_s(1:2^14/(1+OH_LDPC));
FECmode='LDPC';
[data_enc,OH]=QPSK_FEC_ENC(FECmode,OH_LDPC,data_s);
%% 调制
M=4;
symbolmap='gray';
mod_format='QPSK'; %%%y由于采用新的对数似然比的计算，该计算对于差分和非差分 qpsk和bpsk 都适用，所以不用进行细分调制格式
% % modobj1 = comm.PSKModulator('ModulationOrder',4,'PhaseOffset',0);
bin = vec2mat(data_enc,log2(M));
ts_enc = bi2de(bin,'left-msb');
data_m =pskmod(ts_enc,M,0,'gray').';         %Remodulation bits to mode QPSK


%%

for snr=8
    receivedsig = awgn(data_m,snr, 'measured');
    % Compute hard decisionratios (AWGN channel)
    % %     demodObj1= comm.PSKDemodulator('ModulationOrder',4,'SymbolMapping','Gray',...
    % %         'BitOutput',true,'DecisionMethod','Hard decision','PhaseOffset',0);
    %     HD = step(demodObj1, receivedsig.').';
    HD_sym= pskdemod(receivedsig.',M,0,'gray');
    HD_bit=reshape(de2bi(HD_sym,'left-msb').',1,[]);
    
    
    berbeforefec = sum(data_enc~=HD_bit)/length(data_enc);
    fprintf(['\n ber harddecision is ' num2str(berbeforefec) '\n']);
    
    %% 解码
    
    [r_decode,ber]= QPSK_FEC_DEC0720(FECmode,data_s,ts_enc,receivedsig,OH_LDPC,symbolmap);
end
