%data conversion for RS FEC
%input, ouput are the bin data in one row
%the size of output may be shorter
function output=RSconversion(input,flag)
rsm = 8; % Number of bits per symbol
n = 2^rsm-1; k = 239; % Word lengths for code

switch flag
    case 'coding'
        bin1 = vec2mat(input,rsm);
        dec1 = bi2de(bin1,'left-msb');
        data=vec2mat(dec1,k);
        
        msg = gf(data,rsm); %  rows of m-bit symbols
        code = rsenc(msg,n,k);
        
        coded=code.x;
        bindata=dec2bin(coded',rsm);%convert to bin column-wise
        bin=reshape(bindata',1,size(bindata,1)*size(bindata,2));%convert to vector
        output=bin-'0';%conver to bin data
        
    case 'decoding'
        bin2=vec2mat(input,rsm);
        dec2 = bi2de(bin2,'left-msb')';
        dec2=dec2(1:n*floor(length(dec2)/n));
        data=vec2mat(dec2',n);
        msg=gf(data,rsm);
        [dec,cnumerr] = rsdec(msg,n,k);%RS decoding
        
        decoded=dec.x;
        bindata=dec2bin(decoded',rsm);%convert to bin column-wise
        bin=reshape(bindata',1,size(bindata,1)*size(bindata,2));%convert to vector
        output=bin-'0';%conver to bin data              
        
end