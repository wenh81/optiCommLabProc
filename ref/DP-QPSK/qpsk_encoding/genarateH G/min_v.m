
function [Y,I] = min_v(X)

% function [Y,I] = min_v(X)
% For vectors X, Y is the smallest elements in X. 
% The indices of the minimum values are returned in vector I. If there are
% more than one minimal element, the all indices are returned.

%
% Example
%        If X = [2 8 4 2 3]  then
%        [Y,I] = min_v(X) is
%             Y =  2
%             I =  1     4

%   Copyright (c) 2007, Guangrong Fan. MCL.
%   $Revision: 1.0 $  $Date: 2007/07/29 18:52:34 $

Y = min(X);
I = find( X==Y );
