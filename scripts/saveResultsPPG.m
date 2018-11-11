% Description:
%     Save results of runMainOfflinePPG.m
% 
% EXAMPLE:
%     saveResultsPPG
%     
% INPUT:
%     Input        - none
%     
% OUTPUT:
%     Output       - none
% 
%  Copyright, 2018, H.B. Zhang, <hongbo.zhang83@gmail.com>
%
% Modifications:
% Version    Date        Author        Log.
% V1.0       20181001    H.B. Zhang    Create this script
% 
% Ref:
%   

load rootPath.mat;
resultFileName         = sprintf('%s_%s.txt','results',OflfileNameHeader);
resultFilePath         = fullfile(rootPath,'results');
resultFullFilePath     = fullfile(resultFilePath,resultFileName);
if ~checkDirExist(resultFilePath)
    mkdir(resultFilePath);
end

% open file to print result
fid                    = fopen(resultFullFilePath,'w+');

% print result file header
fprintf(fid,'%s\t%s\t%s\t%-4s\t%-4s\n','modFormat','fBaud','bitrate','EVM','QdB');

% print result
fprintf(fid, '%-9s\t%.2f\t%.2f\t%.2f\t%.2f\n', vP.glb.modFormat, ...
                vP.glb.fBaud/1e9,vP.glb.bitrate/1e9,vP.Signal.evm,vP.Signal.QdB);

fclose(fid);