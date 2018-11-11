%Configure DPO, download the waveform,
function [stream1,stream2]=DPOcomm(rate,flag)
%clear all;close all
%dpo = gpib('ni',0,2);
%dpo = visa('ni','TCPIP0::192.169.100.2::INSTR');
% dpo = visa('tek','TCPIP::192.168.1.123::INSTR');
dpo = visa('tek','TCPIP::169.254.66.66::INSTR');

% dpo = visa('tek','GPIB8::1::instr');
fopen(dpo);

%configure the DPO
% fprintf(dpo,['HORizontal:MODE:SAMPLERate ' num2str(rate)]);
% fprintf(dpo,'CH1:SCAle 0.1');fprintf(dpo,'CH2:SCAle 0.1');
% fprintf(dpo,'HORizontal:MODE:SCAle 400e-9');

fprintf(dpo,'CH1:SCAle?');Vscale=fscanf(dpo);Vscale=str2num(Vscale);


%let DPO acquire once
% fprintf(dpo,'ACQUIRE:STATE ON');pause(1);
% fprintf(dpo,'ACQUIRE:STATE OFF');
fprintf(dpo,'HORizontal:ACQLENGTH?');len=fscanf(dpo);%get the length of waveform
fprintf(dpo,'DATA:START 1');fprintf(dpo,['DATA:STOP ' len]);
fclose(dpo);set(dpo,'InputBufferSize',8*str2num(len));fopen(dpo);

%upload the data sequence
fprintf(dpo,'DATa:ENCdg RIBinary');
fprintf(dpo,'WFMOutpre:BIT_Nr 8');%8 must be the same in 'InputBufferSize'

if flag==0
    fprintf(dpo,'DATA:SOURCE CH3');
    fprintf(dpo,'curve?');
    I = fread(dpo,str2num(len),'int8');
    
    %scale the data
    stream1=I'/2^7/Vscale;%8 must be the same in 'InputBufferSize'
end

if flag==2
    fprintf(dpo,'CH1:DESKEW 0E-12');
    fprintf(dpo,'CH2:DESKEW -10E-12');
    fprintf(dpo,'CH3:DESKEW 0E-12');
    fprintf(dpo,'CH4:DESKEW -5E-12');
    
    fprintf(dpo,'DATA:SOURCE CH1');
    fprintf(dpo,'curve?');
    I=fread(dpo,str2num(len),'int8');
    
    fprintf(dpo,'DATA:SOURCE CH2');
    fprintf(dpo,'curve?');
    Q=fread(dpo,str2num(len),'int8');
    
    %scale the data
    I=I/2^7/5/Vscale;
    Q=Q/2^7/5/Vscale;%7 must be the same in 'InputBufferSize'
    
    %I=circshift(I,[4 0]);
    stream1=I+j*Q;
end


if flag==1
%     fprintf(dpo,'CH1:DESKEW -0E-12');
%     fprintf(dpo,'CH2:DESKEW -10E-12');
%     fprintf(dpo,'CH3:DESKEW 5E-12');
%     fprintf(dpo,'CH4:DESKEW -0E-12');
        fprintf(dpo,'CH1:DESKEW -0E-12');
    fprintf(dpo,'CH2:DESKEW -5E-12');
    fprintf(dpo,'CH3:DESKEW 0E-12');
    fprintf(dpo,'CH4:DESKEW -0E-12');
    
    fprintf(dpo,'DATA:SOURCE CH1');
    fprintf(dpo,'CURVE?');
    I1 = fread(dpo,str2num(len),'int8');
    
    fprintf(dpo,'DATA:SOURCE CH2');
    fprintf(dpo,'CURVE?');
    Q1 = fread(dpo,str2num(len),'int8');
    
    fprintf(dpo,'DATA:SOURCE CH3');
    fprintf(dpo,'CURVE?');
    I2 = fread(dpo,str2num(len),'int8');
    
    fprintf(dpo,'DATA:SOURCE CH4');
    fprintf(dpo,'CURVE?');
    Q2 = fread(dpo,str2num(len),'int8');
    
    
    
    I1=I1/2^7/Vscale;
    Q1=Q1/2^7/Vscale;%7 must be the same in 'InputBufferSize'
    I2=I2/2^7/Vscale;
    Q2=Q2/2^7/Vscale;%7 must be the same in 'InputBufferSize'
%     fprintf(dpo,'DATA:SOURCE CH3');
%     fprintf(dpo,'CURVE?');
%     I2 = fread(dpo,str2num(len),'int8');
%     
%     fprintf(dpo,'DATA:SOURCE CH4');
%     fprintf(dpo,'CURVE?');
%     Q2 = fread(dpo,str2num(len),'int8');
%     I2=I2/2^7/Vscale;
%     Q2=Q2/2^7/Vscale;%7 must be the same in 'InputBufferSize'
    
%       stream1=I1+j*Q1;
%       stream2=I1-j*Q1;
     stream1=I1+j*Q1;
     
      stream2=I2+j*Q2   ;
      
%        stream1=I1  ;
%        stream2=Q1  ;
%     stream2=I2+j*Q2;
%     stream2=circshift(stream2,[1 0]);
end

fprintf(dpo,'ACQUIRE:STATE ON');
fclose(dpo);delete(dpo);clear dpo;

