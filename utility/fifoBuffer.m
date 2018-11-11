function sigOut = fifoBuffer(sigBuffer,sigNew,bufferLength)
% Description:
%     FIFOBUFFER Generate a fifo buffer of signal for mass data simulation
% 
% EXAMPLE:
%     sigOut = fifoBuffer(sigBuffer,sigNew,bufferLength)
%     
% INPUT:
%     sigBuffer    - Signal with buffer structure
%     sigNew       - Signal prepared for input
%     bufferLength - defined fifo buffer length
%     
% OUTPUT:
%     Output       - Output signal with buffer structure
%     
% Modifications:
% Version    Date        Author        Log.
% V1.0       20151023    H.B. Zhang    Create this script
% 
% Ref:
%     

if (nargin < 3)
    bufferLength = length(sigBuffer);
end

if (length(sigBuffer) ~= bufferLength)
    error('Length of orignal data does not match defined buffer length');
end

sigOut = [sigBuffer(length(sigNew)+1:bufferLength); sigNew(:)];

end