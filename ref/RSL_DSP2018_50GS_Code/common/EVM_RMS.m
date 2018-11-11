function [ out, dmin ] = EVM_RMS(IN,const)
% Calculates the root mean square EVM of an input signal
% Gives the root mean square of an input signal (IN) according to an input
% constellation (const).
% The first step of the algorithm is to normalize the average power of the
% input signal and of the constellation to 1.
% The next step is to associate each symbol of the input signal to a
% specific point in the constellation.
% Finally the program calculates the distance between the input signal
% symbol and the corresponding constellation point.
% 
%   Use: 
%       out = EVM_RMS(IN,const);
%       IN the input signal (complex) and const is the constellation


if nargin ~=2
    error('Must provide the input signal and the constellation points')
end


%% Normalization
% Centers and normalizes the constellation
Icmean = mean(real(const));
Qcmean = mean(imag(const));
const  = const - Icmean - 1i*Qcmean;

Pconst = mean(abs(const).^2);
const  = const/sqrt(Pconst);

% Centers and normalizes the input signal
Ismean = mean(real(IN));
Qsmean = mean(imag(IN));
IN     = IN - Ismean - 1i*Qsmean;

Ps     = mean(abs(IN).^2);
IN     = IN/sqrt(Ps);

%% Minimum distance --> associates each symbol with the respective symbol in the constellation

INr    = repmat(IN(:).',numel(const),1);
constr = repmat(const(:),1,numel(IN));
dmin   = min(abs(INr-constr).^2); 
% figure
% plot(dmin,'.');
%% EVM calculation
out = sqrt(mean(dmin)); % Since we normalized the powerr of the constellation,
                        % and of the input signal, the EVM is simply the
                        % the square root of the average of the distance
                        % between the signal and ideal constellation points