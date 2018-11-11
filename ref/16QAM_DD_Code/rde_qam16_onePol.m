function [SignalOut, P] = rde_qam16_onePol(SignalIn, P)
% P.FilterLength - full length of adaptive FIR filter
% P.mu           - convergence parameter for MMSE algorithm
% P.NViterbi     - full width of Viterbi GWA phase estimator: of form 4a+1
%                   for +ve integer a
% 
%
% --------- Blind Equaliser using the Godard Constant Modulus Algorithm ---------------
%  Adaptive algorithm for blind equalisation using constant modulus algorithm to minimise mean square error,
%  suitable for complex baseband signals such as QPSK, QAM etc. with CoherentRx

SignalOut=SignalIn;

samplelength = length(SignalIn.Et(1,:)); % calculate length of sample stream

error1 = zeros(samplelength,1);% setup AFIR error term 1
out1   = zeros(samplelength,1);

tapcenter = floor((P.FilterLength+1)/2);% index of central tap
H11       = zeros(1,P.FilterLength); 
H11(tapcenter) = 1;% initial AFIR tap weights 11
Hcen11    = zeros(1,samplelength); % vectors to track tap evolution

fout2n1 = SignalIn.Et(1,:);    
% fout2n1 = fout2n1/mean(abs(fout2n1)); % normalise to unit power
fout2n1 = fout2n1.';

if isfield(P,'Taps')
    H11 = P.Taps(1,:);
end

if isfield(P,'QAM16_Radii')
    r1 = P.QAM16_Radii(1);
    r2 = P.QAM16_Radii(2);
    r3 = P.QAM16_Radii(3);
else
    r1 = sqrt(2/10); 
    r2 = 1; 
    r3 = sqrt(18/10);
end

% Thresholds - determine decision regions
th1 = (r1+r2)/2; 
th2 = (r2+r3)/2; 

% keyboard

%% AFIR Filter Block using Godard Algorithm    
for s=P.FilterLength+1:samplelength-10                    %% AFIR loop
    
    %% New AFIR update every 2*Sa ----------------------------------------------------------  
    out1(s) = H11*fout2n1(s-P.FilterLength:s-1);
    
    if (~mod(s,2))                                      %% AFIR update condition -----------------------------
    
        if (abs(out1(s))<th1) %% if on inner ring
            R1 = r1;
        elseif (abs(out1(s))<th2) %% if on middle ring 
            R1 = r2;
        else
            R1 = r3;
        end
            
        error1(s)=R1.^2-(abs(out1(s)))^2;% calculate error term 1    
    
        % calculate tap weights 11 ?? index correct ??
        H11=H11+P.mu*error1(s)*out1(s)*(fout2n1(s-P.FilterLength:s-1))'; 
    
    end% end if 
    Hcen11(s)=H11(tapcenter);
end% End filter for loop    

SignalOut.Et(1,:) = out1;        % Output Field
SymOut = SignalOut.Et(:,2:2:end);% Output Symbols
SymOut = SymOut(:);              % Convert to Linear Index

% UPDATE Radii
R1_New = mean(mean(abs(SymOut(abs(SymOut)<th1))));     
R2_New = mean(mean(abs(SymOut((abs(SymOut)>th1)&(abs(SymOut)<th2)))));
R3_New = mean(mean(abs(SymOut(abs(SymOut)>th2))));

SignalOut.QAM16_Radii = [R1_New R2_New R3_New];
SignalOut.error1      = error1;
P.Taps        = H11;
P.TapsTrack   = Hcen11;

end% end function


