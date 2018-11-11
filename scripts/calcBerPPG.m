% framer and sync bits
fprintf('- sync tx bits of channel 1 ...\n');
[txBits1,reverseSign1] = framerPPG(bitsCh1,vP);

% bits sequence sign correction
fprintf('- correction rx bits reversal of channel 1 ...\n');
bitsCh1                = reverseSign1*(1-bitsCh1) + (1- reverseSign1)*bitsCh1;

% calc BER
fprintf('- calc err bits and ber for channel 1 ...\n');
errNum1                = sum(bitsCh1 ~= txBits1);
ber1                   = errNum1/length(bitsCh1);

if (isempty(bitsCh2) == 0)
    fprintf('- sync tx bits of channel 2 ...\n');
    [txBits2,reverseSign2] = framerPPG(bitsCh2,vP);
    
    % bits sequence sign correction
    fprintf('- correction rx bits reversal of channel 2 ...\n');
    bitsCh2 = reverseSign2*(1-bitsCh2) + (1- reverseSign2)*bitsCh2;
    
    % calc BER
    fprintf('- calc err bits and ber for channel 2...\n');
    errNum2            = sum(bitsCh2 ~= txBits2);
    ber2               = errNum2/length(bitsCh2);
else
    errNum2            = 0;
    ber2               = 0;
end

fprintf('- calc total errNum and ber ...\n');
errNum                 = errNum1 + errNum2;
ber                    = errNum/(length(bitsCh1) + length(bitsCh2));


SigNal.errNum1         = errNum1;
SigNal.errNum2         = errNum2;
Signal.ber1            = ber1;
Signal.ber2            = ber2;
Signal.errNum          = errNum;
Signal.ber             = ber;
vP.Signal              = Signal;
