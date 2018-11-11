% Description:
%     Calc results 
% 
% EXAMPLE:
%     
%     
% INPUT:
%     Input        - Input signal
%     
% OUTPUT:
%     Output       - Output signal
% 
%  Copyright, 2018, H.B. Zhang, <hongbo.zhang83@gmail.com>
%
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180920    H.B. Zhang    Create this script
% V1.1       20180927    H.B. Zhang    Calc fadc offset
% V1.2       20181024    H.B. Zhang    Calc BER for PPG signal
% 
% Ref:
%   

% calc fadc offset
trPpmAveLen            = 100;
TtrOfst                = (mean(trParms.trPPM(end-trPpmAveLen:end))*1e-6+1)*(1/Scope.scoperate);
BtrOfst                = (Scope.scoperate - 1/TtrOfst)*1e-6;         % MHz
fprintf('- the bandwidth of fadc offset is: %.2fMHz\n',BtrOfst);

% det symbols and de-mapping PPG
fprintf('- slice received symbol ...\n');
detRxSymbol            = slicer(rxSymbol,dsp.modFormat);
fprintf('- de-mapping symbol to PPG bit stream ...\n');
[bitsCh1,bitsCh2]      = binDeMapPPG(detRxSymbol,dsp.modFormat);

% calc BER
fprintf('- calc ber begin ...\n');
calcBerPPG;
fprintf('%s%.2e\n','- Chanel 1 BER is: ',vP.Signal.ber1);
fprintf('%s%.2e\n','- Chanel 2 BER is: ',vP.Signal.ber2);
fprintf('%s%.2e\n','- Total BER is: ',vP.Signal.ber);

% calc evm
evm                    = EVM_RMS( rxSymbol, dsp.const );
fprintf('%s%.2f\n','- EVM is: ',evm);

qFactor                = 1/evm;
QdB                    = 20*log10(qFactor);
fprintf('%s%.2f\n','- Q in dB is: ',QdB);

% store stuff on Signal
Signal.rxSymbol        = rxSymbol;
Signal.bitsCh1         = bitsCh1;
Signal.bitsCh2         = bitsCh2;
Signal.evm             = evm;
Signal.QdB             = QdB;
Signal.dsp             = dsp;
Signal.Btr             = BtrOfst;
vP.Signal              = Signal;

fprintf('\n');
