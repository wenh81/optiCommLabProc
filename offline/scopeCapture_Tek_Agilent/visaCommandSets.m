% Some Commands:
I.Send( ':HORIZONTAL:MODE:SAMPLERATE 50e9'); % set sample rate,page38
I.Send( ':HORIZONTAL:MODE:SCAle 100e-9');    % set 100ns/div
I.Send( ':HORizontal:MODE:RECOrdlength 20*1e6');   
I.Send( ':CH1:SCALE 100E-03');    % set chx vertical div, 100mv/div

% or send command
fprintf(instr,':CH1:SCALE 300E-03');
I.Send( ':acquire:state run;'); % restore last acquisitions
I.Send( 'ACQUIRE:STOPAFTER RUNSTOP'); % RUNSTOP-continue mode/SEQuence-single
