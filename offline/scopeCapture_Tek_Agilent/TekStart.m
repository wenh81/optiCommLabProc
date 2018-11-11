function instr = TekStart(tekParms)
% Description:
%     Initialize TekTronix DSA 5000/6000/7000
% 
% EXAMPLE:
%     instr = TekStart(tekParms)
% 
% Parameter description
%     tekParms         - TekTronix parameters
%     
% Input
%     tekParms         - input TekTronix parameters: r, bs, t
%     
% Output
%     instr            - TekVISA handle
% 
% Copyright, 2018 (C), H.B. Zhang, <hongbo.zhang83@gmail.com>
% 
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180914    H.B. Zhang    Create this script
% 
% Ref:

% get parameters
r                      = tekParms.r;
bs                     = tekParms.bs;
t                      = tekParms.t;

% get TekVISA Handle
instr                  = visa('tek', r);

% set TekVISA buffer size and timeout 
set(instr, 'InputBufferSize', bs);
set(instr, 'OutputBufferSize', bs);
set(instr, 'Timeout', t);

% open instrument
fopen(instr);

end
