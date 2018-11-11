function plotCnstBGw(sigIn,Ngrid) 
% Description:
%     PLOTCNST Plot hist constellation of input signa with white background
% 
% EXAMPLE:
%     plotCnstBGw(sigIn,Ngrid) 
%     
% INPUT:
%     sigIn        - Input signal
%     Ngrid        - Grid number
%     
% OUTPUT:
%     
% Modifications:
% Version    Date        Author        Log.
% V1.0       20181016    H.B. Zhang    Create this script
% 
% Ref:
%     

N                      = length(sigIn);
sigIn_real             = real(sigIn);
sigIn_imag             = imag(sigIn);

% Size of the histogram matrix
if (nargin == 1)
    Ngrid              = 160;
else
    % do nothing
end

Nx                     = Ngrid;
Ny                     = Ngrid;
    
% Choose the bounds of the histogram to match min/max of data samples.
% (you could alternatively use fixed bound, e.g. +/- 4)
ValMaxX                = max(sigIn_real);
ValMinX                = min(sigIn_real);
ValMaxY                = max(sigIn_imag);
ValMinY                = min(sigIn_imag);
dX                     = (ValMaxX-ValMinX)/(Nx-1);
dY                     = (ValMaxY-ValMinY)/(Ny-1);

% Figure out which bin each data sample fall into
IdxX                   = 1 + floor((sigIn_real - ValMinX)/dX);
IdxY                   = 1 + floor((sigIn_imag - ValMinY)/dY);

H                      = zeros(Ny,Nx);
for idx = 1:N
    if (IdxX(idx) >= 1 && IdxX(idx) <= Nx && IdxY(idx) >= 1 && IdxY(idx) <= Ny)
        % Increment histogram count
        H(IdxY(idx),IdxX(idx)) = H(IdxY(idx),IdxX(idx)) + 1;
    else
        % do nothing
    end
end

% Colormap that approximate the sample figures you've posted
map                    = [1 1 1;0 0 1;0 1 1;1 1 0;1 0 0];

% Boost histogram values greater than zero so they don't fall in the
% white band of the colormap.
S                      = size(map,1);
Hmax                   = max(max(H));
bias                   = (Hmax-S)/(S-1);
idx                    = find(H>0);
H(idx)                 = H(idx) + bias;

% Plot the histogram
pcolor([0:Nx-1]*dX+ValMinX, [0:Ny-1]*dY+ValMinY, H);
shading flat;
colormap(map);
end