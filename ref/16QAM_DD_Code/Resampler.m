function [SignalOut, varargout] = Resampler(SignalIn, P)

% Function block to resample Et in a signal struct
%
% [SignalOut, varargout] = Resampler(SignalIn, P)
%
% Inputs:
% SignalIn          - Signal structure
% P.sample_ratio    - Ratio for resampling
% Optional Inputs:
% P.window          - Ratio for resampling
%
% Returns:
% SignalOut         - Output signal structure
%
% Author:

SignalOut = SignalIn;

[Np,Nt] = size(SignalIn.Et);

%% Create Parameters
[n,d] = rat(P.sample_ratio,1e-7);
nWIN = 10;

%% resampling by oversampling, filtering, and downsampling
if Np==2.
    SignalOut.Et = [resample(SignalIn.Et(1,:),d,n,nWIN);...
                    resample(SignalIn.Et(2,:),d,n,nWIN)];
else
    SignalOut.Et = [resample(SignalIn.Et(1,:),d,n,nWIN)];
end
        
SignalOut.Fs = (d/n)*SignalIn.Fs;

%% Assign outputs
P.ResampleWindow = nWIN;
varargout{1} = P;

end