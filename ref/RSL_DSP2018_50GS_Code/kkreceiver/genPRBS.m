function [seq] = genPRBS(N,nDelay)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    nDelay = 0;
end
load('PRBS15.mat');
prbs = +bitSeq;
prbs = circshift(prbs,nDelay);
nPkts = ceil(N/length(prbs));
seq = repmat(prbs,nPkts,1);
seq = seq(1:N).*2-1;
end

