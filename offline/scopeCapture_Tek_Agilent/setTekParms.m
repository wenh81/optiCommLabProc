function tekParms = setTekParms()
% Description:
%     Set parameters for TekVISA of TDS5000/6000/7000/8000 ...
% 
% EXAMPLE:
%     tekParms = setTekParms()
% 
% Parameter description
%     
% Input
%     none
%     
% Output
%     tekParms         TekTronix DSA Capture parameters
%        - r           TekVISA resources
%        - bs          Buffer Size
%        - t           timeout with unit of ms
% 
% Copyright, 2018 (C), H.B. Zhang, <hongbo.zhang83@gmail.com>
% 
% Modifications:
% Version    Date        Author        Log.
% V1.0       20180914    H.B. Zhang    Create this script
% V1.1       20180922    H.B. Zhang    1. Support DSO sampling channel selection
%                                      2. support self-defined horizon div
%                                      3. support self-defined DSO sample rate
% 
% Ref:


fprintf('- Init scope capture configration ...\n');

% parameter settings
chNum                  = [3];  % channel number of DSO: {1,2,3,4}, single or combination
IPADDR                 = '192.168.2.101';
MODE                   = 'TCPIP0';
SEP                    = '::';
Type                   = 'visa';
Vendor                 = 'tek'; % {'Agilent','tek'}

% command parameters
r                      = strcat(MODE,SEP,IPADDR,SEP,'inst0',SEP,'INSTR');
bs                     = 10e6;           % buffer size
t                      = 10;             % ms, timeout
horizonDiv             = 20000e-9;       % sencond, xx/div
sampleRate             = 50e9;           % scape sample rate

% collect parameters
tekParms.r             = r;
tekParms.bs            = bs;
tekParms.t             = t;
tekParms.horizonDiv    = horizonDiv;
tekParms.sampleRate    = sampleRate;
tekParms.chNum         = chNum;
tekParms.Type          = Type;
tekParms.Vendor        = Vendor;

fprintf('\n');
end