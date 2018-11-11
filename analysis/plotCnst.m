function [mHist,vXEdge,vYEdge] = plotCnst(sigIn,Ngrid) 
% Description:
%     PLOTCNST Plot hist constellation of input signa
% 
% EXAMPLE:
%     [H,mHist,vXEdge,vYEdge] = plotCnst(sigIn,Ngrid)
%     
% INPUT:
%     sigIn        - Input signal
%     Ngrid        - Grid number
%     
% OUTPUT:
%     mHist        - 
%     vXEdge       - Step value of X-axis
%     vYEdge       - Step value of Y-axis
%     
% Modifications:
% Version    Date        Author        Log.
% V1.0       201524    H.B. Zhang    Create this script
% 
% Ref:
%     

sigIn_real = real(sigIn);
sigIn_imag = imag(sigIn);

mX   = [sigIn_real(:) sigIn_imag(:)];
minV = min(mX(:));
maxV = max(mX(:));

vXEdge = minV:(maxV-minV)/Ngrid:maxV;
vYEdge = vXEdge;

mHist  = hist2d(mX,vXEdge,vYEdge);
xAxis  = (vXEdge(1:end-1)+vXEdge(2:end))/2;
yAxis  = (vYEdge(1:end-1)+vYEdge(2:end))/2;

pcolor(xAxis,yAxis,mHist); 
axis('equal');
axis([min(vXEdge) max(vXEdge) min(vYEdge) max(vYEdge)]);

% surf(xAxis,yAxis,mHist); shading('interp');
end


%% ================= SUB FUNCTION(S) =============================
function mHist = hist2d(mX,vXEdge,vYEdge)

nCol = size(mX,2);

if nCol < 2
    error('mX has less than 2 colums');
end

nRow = length(vYEdge)-1;
nCol = length(vXEdge)-1;

vRow = mX(:,1);
vCol = mX(:,2);

mHist = zeros(nRow,nCol);

for iRow = 1:nRow
   rRowLB = vYEdge(iRow);
   rRowUB = vYEdge(iRow+1);
   vColFound = vCol((vRow>rRowLB)&(vRow<=rRowUB));
   
   if (~isempty(vColFound))
      vFound = histc(vColFound,vXEdge); 
      nFound = length(vFound)-1;
      
      if (nFound~=nCol)
          disp([nFound nCol]);
          error('hist2d error: Size error');
      end
      
      [nRowFound,nColFound] = size(vFound);
      nRowFound = nRowFound-1;
      nColFound = nColFound-1;
      
      if nRowFound==nCol
          mHist(iRow,:) = vFound(1:nFound)';
      elseif nColFound == nCol
          mHist(iRow,:) = vFound(1:nFound);
      else
          error('hist2d error: Size Error');
      end
      
   end
end

end