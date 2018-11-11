% Description:
%     Print System information for PPG-DSO offline processing information.
%  
% Copyright, 2018, H.B. Zhang, <hongbo.zhang83@gmail.com>
% 
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180927    H.B. Zhang    Create this script
fprintf('%s : %s\n','- System running mode is',vP.sysModeStr);
fprintf('%s\n','**********************************************************************');
fprintf('%30s : %s\n','PAM-N/SSB Offline Platform', 'PPG-DSO/RF-SSB');
fprintf('%30s : %s %s\n','Matlab Platform Version', vP.verInfo.projName, vP.verInfo.verNo);
fprintf('%30s : %s\n', 'Released on', vP.verInfo.date);
fprintf('%30s : %s\n', 'Released by', vP.verInfo.author);
fprintf('%30s : %s\n', 'Contact Email Address', vP.verInfo.email);
fprintf('%s\n','**********************************************************************');

fprintf('%s\n', 'Simulation parameters:')
fprintf('%s\n', '-------------------------------------------')
fprintf('%20s : %s\n', 'Modulation Format', vP.glb.modFormat);
fprintf('%20s : %d\n', 'Modulation Index', vP.glb.bitsPerSymbol);
fprintf('%20s : %.2f%s\n', 'BaudRate', vP.glb.fBaud/1e9, ' GBaud');
fprintf('%20s : %.2f%s\n', 'BitRate', vP.glb.bitrate/1e9, ' Gbps');
fprintf('%20s : %d\n', 'Equalization ON/OFF', vP.glb.isEqualization);
fprintf('%20s : %d\n', 'FFE tap number', lmsParms.tapNum);
fprintf('%20s : %.1e\n', 'FFE step mu', lmsParms.mu);
fprintf('%s\n', '-------------------------------------------')

fprintf('%s\n', 'Digital Signal Processing begin ...')
