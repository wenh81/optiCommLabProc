function BER_output = BER_QPSK(Rx,X_Tx,ts_enc)
load data\QPSKpara
load data\data_s
load data\data_dec

M              = QPSKpara.M1;
Mode           = QPSKpara.Mode;
ModFormat      = QPSKpara.ModFormat;
CodeFormat      = QPSKpara.CodeFormat;
OH             = QPSKpara.OH;
n=1;m=1;BER_final=2;BER_final_rs=2;
train=0;
if train==1
    T=X_Tx(1:30);
    R=Rx(1:30);
    theta=mean(unwrap(angle(T.*conj(R))));
else
    theta =0:pi/2:pi*3/2;
end
for theta=theta%=0:pi/2:pi*3/2
    switch Mode
        case 'PSK'
            
            if isequal(ModFormat,'QPSK')
                Rx_deci= pskdemod(conj(Rx.*exp(j*theta)),M,[],'gray');
%                 Rx_deci= pskdemod(Rx.*exp(j*theta),M,[],'gray');

                Rx_deci1=circshift(Rx_deci,[0,0]);
                %                 Tx_deci= pskdemod(X_Tx,M,[],'gray');        %Remodulation bits to mode QPSK
                Tx_deci= data_dec.';        %Remodulation bits to mode QPSK
            end
            
            if isequal(ModFormat,'BPSK')
                Rx_deci= pskdemod(conj(Rx.*exp(j*theta)),M,[],'gray');
                Rx_deci1=circshift(Rx_deci,[0,0]);
                %                 Tx_deci= pskdemod(X_Tx,M,[],'gray');        %Remodulation bits to mode BPSK
                Tx_deci= data_dec.';        %Remodulation bits to mode QPSK
            end
            
            if isequal(ModFormat,'DPSK')&& isequal(CodeFormat,'RS')
                Rx_deci= dpskdemod(conj(Rx.*exp(j*theta)),M,[0],'gray');
                Rx_deci1=circshift(Rx_deci,[0,0]);
                %                 Tx_deci= dpskdemod(X_Tx,M,[],'gray');        %Remodulation bits to mode DPSK
                Tx_deci= data_dec.';        %Remodulation bits to mode QPSK
            end
            
            if isequal(ModFormat,'DQPSK')&& isequal(CodeFormat,'RS')
                Rx_deci= dpskdemod(conj(Rx.*exp(j*theta)),M,[0],'gray');
                Rx_deci1=circshift(Rx_deci,[0,0]);
                %                 Tx_deci= dpskdemod(X_Tx,M,[],'gray');        %Remodulation bits to mode DQPSK
                Tx_deci= data_dec.';        %Remodulation bits to mode QPSK
            end
            
            if isequal(ModFormat,'DPSK')&& isequal(CodeFormat,'LDPC')
                receivedsig=conj(Rx);
                ph = angle(receivedsig).';
                for w2=2:length(receivedsig)
                    dph(w2-1)=ph(w2)-ph(w2-1);
                end
                Rx_deci= pskdemod(exp(j*dph),M,[],'bin');
                Rx_deci1=circshift(Rx_deci,[0,0]);
                Tx_deci= data_dec.';
            end
            
            if isequal(ModFormat,'DQPSK')&& isequal(CodeFormat,'LDPC')
                receivedsig=conj(Rx);
                ph = angle(receivedsig).';
                for w2=2:length(receivedsig)
                    dph(w2-1)=ph(w2)-ph(w2-1);
                end
                Rx_deci= pskdemod(exp(j*dph),M,[],'bin');
                Rx_deci1=circshift(Rx_deci,[0,0]);
                Tx_deci= data_dec.';
            end
            
        case 'QAM'
            Rx_deci = qamdemod(Rx,M,[],'gray');
            Rx_deci1=circshift(Rx_deci,[0,0]);
            
            Tx_deci = qamdemod(X_Tx,M,[],'gray');
        otherwise error;
    end
    [~, BER(n), ~] = biterr(Tx_deci,Rx_deci1);
    
    if BER(n)<0.05
        
        if  isequal(CodeFormat,'LDPC') && ( isequal(ModFormat,'DQPSK') || isequal(ModFormat,'DPSK') )
            symbolmap='Binary';
            [r_decode,ber]=QPSK_FEC_DEC(CodeFormat,data_s,exp(j*circshift(dph,[0,1])),OH,symbolmap);
        else
            symbolmap='Gray';
            %         eyediagram(real(Rx),4)
            Rx_=circshift(conj(Rx.*exp(j*theta)),[0,0]);
            %         Rx_deci1=Tx_deci;
% % %             [r_decode,ber]=QPSK_FEC_DEC70(CodeFormat,data_s,Rx_,OH,symbolmap);
          [r_decode,ber]=QPSK_FEC_DEC0720(CodeFormat,data_s,Rx_,OH,symbolmap)
         
            %         fprintf(['\n ber RS is ' num2str(ber_rs) '\n']);
        end
        ber_rs_tmp(m)=ber;
        m=m+1;
    end
    n=n+1;
end


try
    BER_final=min(BER);
    BER_final_rs=min(ber_rs_tmp);
catch
end
BER_output=[BER_final,BER_final_rs];
% if BER_final<0.1
%
% disp(['BER w/o. RS is: ',num2str(BER_final)]);
% end
end