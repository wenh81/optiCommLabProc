function [SignalOut, P] = DD_LMS_16QAM( SignalIn, P )
% Call:
% [e,w]=lms(mu,M,u,d);
%
% Input arguments:
% mu = step size, dim 1x1
% n_Taps = filter length, dim 1x1
% u = input signal - TXData, dim Nx1
% d = desired signal, dim Nx1
%
% Output arguments:
% e = estimation error, dim Nx1
% w = final filter coefficients, dim Mx1

SignalOut = SignalIn;

samplelength = length(SignalIn.Et(1,:)); %% calculate length of sample stream
SamplesOut = zeros(samplelength,1); % output of the equalizer
error      = zeros(samplelength,1);
D          = zeros(samplelength,1);% Desired output

tapcenter = floor((P.FilterLength+1)/2);        %% index of central tap

if isfield(P, 'Taps')
    H11 = P.Taps;
    H11 = H11./max(abs(H11));% normalize the taps
else
    H11 = zeros(1,P.FilterLength); 
    H11(tapcenter) = 1; 
end

SamplesIn = SignalIn.Et(1,:).';

%% LMS adaptation
for n = 2*ceil((P.FilterLength+1)/2):int64(SignalIn.Ns):samplelength-1,   

    SamplesOut(n)   = H11*SamplesIn(n-P.FilterLength+1:n);   % calculate AFIR output 1 on symbol
    SamplesOut(n+1) = H11*SamplesIn(n-P.FilterLength+2:n+1);   % calculate AFIR output 1 on transition
      
    D(n) = QAM16HardDecision( SamplesOut(n), P );
    
    error(n) = D(n) - SamplesOut(n); % error signal
            
%     H11 = H11 + P.mu*conj(error(n))*SamplesOut(n)*SamplesIn(n-P.FilterLength+1:n).'; % Update the filter taps
    H11 = H11 + P.mu*error(n).*SamplesIn(n-P.FilterLength+1:n)'; % Update the filter taps
    
%     e_tot_DD(n) = sum(e.^2)/(length(e)-n_Taps);

end

%% PLOTS
% figure; plot( filter(ones(1,128)./128,1,abs(error)), 'r' ); grid on

% figure; stem( abs(H11) )

%% SAVE the filter values
SignalOut.Et(1,:) = SamplesOut;

SignalOut.error = error;
P.Taps = H11;

end











