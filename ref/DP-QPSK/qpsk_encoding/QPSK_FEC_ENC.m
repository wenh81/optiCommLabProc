%% 编码
function [data_enc,OH]=QPSK_FEC_ENC(FECmode,OH_LDPC,data_s)
switch FECmode
    case 'RS'
        data_enc=RSconversion(data_s,'coding'); %%% RS encoding
        
    case 'LDPC'
        if OH_LDPC==1/15
            load('qpsk_encoding\outputG15_16_36.mat')
            load('qpsk_encoding\outputH15_16_36.mat')
            G=outputG; H=outputH;
        end
        
        if OH_LDPC==1/7
            load('qpsk_encoding\outputH7_8_46.mat')
            load('qpsk_encoding\outputG7_8_46.mat')
            G=outputG; H=outputH;
        end
        
        N=length(data_s)/size(G,1);
        data_enc=[];
        % %         zc=[];ssd=0;zi=[];
        for i=1:N
            yi=mod(data_s((i-1)*size(G,1)+1:i*size(G,1))*G,2);
            data_enc =[data_enc yi];   % coding
            % % %             zc=[zc yi(1:size(G,2)-size(G,1)) ];%检验位
            % % %             zi=[zi yi(size(G,2)-size(G,1)+1:end)];%信息位
        end
end
OH=(length(data_enc)-length(data_s))/length(data_s);%%开销等于 校验位 除以 信息位 个数
end