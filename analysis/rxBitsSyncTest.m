% rxbits sync
load('prbs23_18.mat');
refBitsSeq             = repmat(refBits,2,1);
inBits                 = 1-bitsCh1;
lenInBits              = length(inBits);

% sync bits
[tau,reverseSign]      = rxBitsSync(inBits, refBitsSeq);

% expand refBits
lenRefBits             = length(refBits);
if (lenRefBits < lenInBits)
    section            = ceil(lenInBits/lenRefBits) + 1;
    refBitsSeq         = repmat(bits,section,1);
end

% get tx bits
txBitsCh1              = refBitsSeq(tau + (1:length(bitsCh1) ) );
if (reverseSign == 1)
    inBits             = 1 - inBits;
else 
    % do nothing
end
[inBits(1:30), txBitsCh1(1:30)]