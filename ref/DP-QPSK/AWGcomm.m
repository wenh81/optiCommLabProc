function AWGcomm(AWGrate,stream1,waveformName1,waveformName2)
%% Opening VISA Session
visa_vendor  = 'tek';
visa_address = 'TCPIP::192.168.1.101::INSTR';

%% generate the data
% load AWG_Double;
% calculate length of waveform
waveform1       = single(real(stream1));
waveformLength1 = numel(waveform1);
waveform2       = single(imag(stream1));
waveformLength2 = numel(waveform2);
% waveformName   = 'MATLABSignal';

%% Process data for AWG

%% create the Marker
binblockData1 = waveform1 ;
binblockData2 = waveform2 ;
% Generate marker byte for each point 
t1           = 1:1:waveformLength1;  
Marker1      = bitshift(uint8(square(2*pi*1/waveformLength1*t1,50)),6);
markBytes1   = num2str(length(Marker1));
markHeader1  = ['#' num2str(length(markBytes1)) markBytes1];
 
t2           = 1:1:waveformLength2;  
Marker2      = bitshift(uint8(square(2*pi*1/waveformLength2*t2,50)),6);
markBytes2   = num2str(length(Marker2));
markHeader2  = ['#' num2str(length(markBytes2)) markBytes2];
% build binblock header
bytes1  = num2str(length(binblockData1)*4);
header1 = ['#' num2str(length(bytes1)) bytes1];

bytes2  = num2str(length(binblockData2)*4);
header2 = ['#' num2str(length(bytes2)) bytes2];
%% open AWG70K instrument
% fclose(instrfind);
instr = visa(visa_vendor,visa_address);
pause(1);
buffer = waveformLength1 * 8;
set(instr,'OutputBufferSize',buffer);
% set(instr,'ByteOrder','littleEndian');
fopen(instr);
% query identification information  to ensure the AWG70K has been opend
id = query(instr, '*IDN?');
disp(id);
% reset AWG70K to factory defaults
fprintf(instr,'AWGControl:STOP:IMMediate');
fprintf(instr,'*RST');
fprintf(instr,'*CLS');
% Wait for the operation to complete
fprintf(instr,'*OPC?');

% set DAC resolution
fprintf(instr,'SOURCE1:DAC:Resolution 8');

%% Write data to AWG
createWaveform1 = sprintf('WLISt:WAVeform:NEW "%s", %d',waveformName1,waveformLength1);
fwrite(instr,createWaveform1);
% fwrite(instr,['WLISt:WAVeform:NEW "MATLABSignal", ' num2str(waveformLength)]);
% Wait for the operation to complete
fprintf(instr,'*OPC?');
% set the waveform marker data
waveformMarker1 = sprintf('WLISt:WAVeform:MARKer:DATA "%s", %s',waveformName1,markHeader1);
fwrite(instr,waveformMarker1);
% fwrite(instr,['WLISt:WAVeform:MARKer:DATA "MATLABSignal", ' markHeader]);
fwrite(instr,Marker1,'uint8');
% End of input
EOI = 10;
fwrite(instr,EOI);
% Wait for the operation to complete
fprintf(instr,'*OPC?');
% set the waveform data
waveformData1 = sprintf('WLISt:WAVeform:DATA "%s", %s',waveformName1,header1);
fwrite(instr,waveformData1);
% fwrite(instr,['WLISt:WAVeform:DATA "MATLABSignal", ' header]);
fwrite(instr,binblockData1,'single');
% End of input
EOI = 10;
fwrite(instr,EOI);
% Wait for the operation to complete
fprintf(instr,'*OPC?');

% normalize a waveform in the waveform list
% waveformNormalize1 = sprintf('WLISt:WAVeform:NORMalize "%s",FSCale',waveformName1);
% fwrite(instr,waveformNormalize1);
% fprintf(instr,'WLISt:WAVeform:NORMalize "MATLABSignal",FSCale');

%% Set parameters and enable output
% Set output on channel 1
assignWaveformCH1 = sprintf('SOURce1:WAVeform "%s"',waveformName1);
fwrite(instr,assignWaveformCH1);
% fprintf(instr,'SOURce1:WAVeform "MATLABSignal"');
% Set the sample rate
fprintf(instr,['CLOCK:SRATe ' num2str(AWGrate)]);
% Enable output on channel 1
fprintf(instr,'OUTPut1:STATe ON');
% Set the run mode to continuous
fprintf(instr,'AWGControl:RMODe CONTinuous');
% set the AWG operation state
%fprintf(instr,'AWGControl:RUN:IMMediate');
% Wait for the operation to complete
fprintf(instr,'*OPC?');

% set DAC resolution
fprintf(instr,'SOURCE2:DAC:Resolution 8');
pause(0.5);
%% Write data to AWG
createWaveform2 = sprintf('WLISt:WAVeform:NEW "%s", %d',waveformName2,waveformLength2);
fwrite(instr,createWaveform2);
% fwrite(instr,['WLISt:WAVeform:NEW "MATLABSignal", ' num2str(waveformLength)]);
% Wait for the operation to complete
fprintf(instr,'*OPC?');
% set the waveform marker data
waveformMarker2 = sprintf('WLISt:WAVeform:MARKer:DATA "%s", %s',waveformName2,markHeader2);
fwrite(instr,waveformMarker2);
% fwrite(instr,['WLISt:WAVeform:MARKer:DATA "MATLABSignal", ' markHeader]);
fwrite(instr,Marker2,'uint8');
% End of input
EOI = 10;
fwrite(instr,EOI);
% Wait for the operation to complete
fprintf(instr,'*OPC?');
% set the waveform data
waveformData2 = sprintf('WLISt:WAVeform:DATA "%s", %s',waveformName2,header2);
fwrite(instr,waveformData2);
% fwrite(instr,['WLISt:WAVeform:DATA "MATLABSignal", ' header]);
fwrite(instr,binblockData2,'single');
% End of input
EOI = 10;
fwrite(instr,EOI);
% Wait for the operation to complete
fprintf(instr,'*OPC?');

% normalize a waveform in the waveform list
% waveformNormalize2 = sprintf('WLISt:WAVeform:NORMalize "%s",FSCale',waveformName2);
% fwrite(instr,waveformNormalize2);
% fprintf(instr,'WLISt:WAVeform:NORMalize "MATLABSignal",FSCale');

%% Set parameters and enable output
% Set output on channel 1
assignWaveformCH2 = sprintf('SOURce2:WAVeform "%s"',waveformName2);
fwrite(instr,assignWaveformCH2);
% fprintf(instr,'SOURce1:WAVeform "MATLABSignal"');
% Set the sample rate
fprintf(instr,['CLOCK:SRATe ' num2str(AWGrate)]);
% Enable output on channel 1
fprintf(instr,'OUTPut2:STATe ON');
% Set the run mode to continuous
fprintf(instr,'AWGControl:RMODe CONTinuous');
% set the AWG operation state
fprintf(instr,'AWGControl:RUN:IMMediate');
% Wait for the operation to complete
fprintf(instr,'*OPC?');

