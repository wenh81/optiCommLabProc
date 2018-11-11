function phi = calcPhaseRot16QAM(sigIn)
% Description:
%     Calc phase rotation for 16-QAM by optical_synthesizing_approach
%
% EXAMPLE:
%     phi = calcPhaseRot16QAM(sigIn)
% INPUT:
%     sigIn        - Input rx dec symbols in 1SPS
%
% OUTPUT:
%     phi          - output calc phase
%
%  Copyright, 2018 (C), H.B. Zhang, <hongbo.zhang93@gmail.com>
%
% Modifications:
% Version    Date        Author               Log.
% V1.0       20181025    H.B. Zhang    Create this script
% Ref:
%

% 4-QAM to QPSK
preRotPhi              = pi/4;

% init rotated rxSymbol sequence
rxSymbolRot            = sigIn(:)*exp(1i*preRotPhi);

% hard decision by angle
% calc angles and hard decision
rxAngle                = angle(sigIn);
rxAngleQ2Idx           = find(rxAngle<=pi & rxAngle>pi/2);
rxAngleQ3Idx           = find(rxAngle<=-pi/2 & rxAngle>-pi);
rxAngleQ4Idx           = find(rxAngle<=0 & rxAngle>-pi/2);

% divide original 16-QAM to 4 part and rotate Q2-Q4 to Q1
rxSymbolRot(rxAngleQ2Idx) = rxSymbolRot(rxAngleQ2Idx)*exp(1j*(-pi/2));
rxSymbolRot(rxAngleQ3Idx) = rxSymbolRot(rxAngleQ3Idx)*exp(1j*(pi));
rxSymbolRot(rxAngleQ4Idx) = rxSymbolRot(rxAngleQ4Idx)*exp(1j*(pi/2));

% remove DC
% IrxSymbolRot           = real(rxSymbolRot) - mean(real(rxSymbolRot));
% QrxSymbolRot           = imag(rxSymbolRot) - mean(imag(rxSymbolRot));
% rxSymbolRotQPSK        = complex(IrxSymbolRot,QrxSymbolRot);
rxSymbolRotQPSK        = Orthonormalization( rxSymbolRot.', 1 );

deSigX4                = rxSymbolRotQPSK.^4;
phiRotQPSK             = mean(angle(deSigX4))/4;

phi                    = preRotPhi + phiRotQPSK;

end