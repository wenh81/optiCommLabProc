function [r_decode,ber]=QPSK_FEC_DEC(FECmode,data_s,receivedsig,OH_LDPC,symbolmap)
load data\QPSKpara
M              = QPSKpara.M1;                       % bits of per sysmbol
ModFormat      = QPSKpara.ModFormat;

switch FECmode
    case 'RS'
        data=receivedsig;
        %%需要先进行硬判决
        %         Compute hard decisionratios (AWGN channel)
        if isequal(ModFormat,'DPSK')
            Rx_deci= dpskdemod(receivedsig,M,[0],'gray');
            data = pskmod(Rx_deci,M,[],'gray');
        end
        if isequal(ModFormat,'DQPSK')
            Rx_deci= dpskdemod(receivedsig,M,[0],'gray');
            data = pskmod(Rx_deci,M,[],'gray');
        end
        demodObj1= comm.PSKDemodulator('ModulationOrder',M,'SymbolMapping','Gray',...
            'BitOutput',true,'DecisionMethod','Hard decision','PhaseOffset',0);
        HD = step(demodObj1, data.').';
        HD=reshape(HD',1,[]);
        
        y_decode=RSconversion(HD,'decoding'); %%% RS decode
        r_decode=y_decode (1:length(data_s));
        ber=sum(data_s~=r_decode)/length(data_s);
        fprintf(['\n ber RS is ' num2str(ber) '\n']);
%%
    case 'LDPC'
        data=receivedsig;
        
        if OH_LDPC==1/15
            load('qpsk_encoding\outputH15_16_36.mat')
            H=outputH;
        end
        if OH_LDPC==1/7
            load('qpsk_encoding\outputH7_8_46.mat')
            H=outputH;
        end
        
        % %       symbolmap  = 'Binary';
        % Compute log-likelihood ratios (AWGN channel)
        demodObj2= comm.PSKDemodulator('ModulationOrder',M,'SymbolMapping',symbolmap,...
            'BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio','PhaseOffset',0);
        llr = step(demodObj2, receivedsig.').'; llr=4*llr;
        r_decode=[];
        N=length(llr)/size(H,2);
        for i=1:N  %%% LDPC decode
            [z_hat, success, k] = ldpc_Qi_decode_v3_3(llr((i-1)*size(H,2)+1:i*size(H,2)),H);
            x_hat = z_hat(size(H,1)+1:size(H,2));
            r_decode=[r_decode x_hat];
        end
        ber = sum(data_s~=r_decode)/length(data_s);
        fprintf(['\n ber ldpc is ' num2str(ber) '\n']);
end
end