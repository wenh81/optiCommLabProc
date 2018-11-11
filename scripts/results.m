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
%
% Ref:
%

% CR FO tracking
if (crParms.bypass == 0) || (lmsParms.crParms.bypass == 0)
    fprintf('- the fo tracked by CR is: %.6f Hz\n',crParms.fo);
end

% calc fadc offset
if (trParms.bypass == 0)
    trPpmAveLen        = 100;
    TtrOfst            = (mean(trParms.trPPM(end-trPpmAveLen:end))*1e-6+1)*(1/Scope.scoperate);
    BtrOfst            = (Scope.scoperate - 1/TtrOfst)*1e-6;         % MHz
    fprintf('- the bandwidth of fadc offset is: %.6fMHz\n',BtrOfst);
else
    BtrOfst            = 0;
end

% calc BER
% if strcmpi(dsp.modFormat, '16-QAM')
%     modFormatBER       = '16_QAM';
% else
%     modFormatBER       = dsp.modFormat;
% end
% berSigIn               = rxSymbol/rms(rxSymbol);
% [ ber, rseq]           = Lu_San_Demodulator_tao( berSigIn.', Signal, modFormatBER);
berSigIn               = rxSymbol/rms(rxSymbol);
[ber, rseq]            = calcBerSSB(berSigIn,calcBerParms);
fprintf('%s%.2e\n','- BER is: ',ber);

% calc evm
evm                    = EVM_RMS( rxSymbol, dsp.const );
fprintf('%s%.2f\n','- EVM is: ',evm);

qFactor                = 1/evm;
QdB                    = 20*log10(qFactor);
fprintf('%s%.2f\n','- Q in dB is: ',QdB);

% store stuff on Signal
Signal.rxSymbol        = rxSymbol;
Signal.evm             = evm;
Signal.QdB             = QdB;
Signal.dsp             = dsp;
Signal.Btr             = BtrOfst;
