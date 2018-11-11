function Load2AWG( Signal, phases, sequenceDelays )
if nargin < 2
	phases = [ 75 0 17 12 ];
	sequenceDelays = [ 0, 6.21e-9, -0.3e-9, -1.91e-9 ];
elseif nargin < 3
	sequenceDelays = [ 0, 6.21e-9, -0.3e-9, -1.91e-9 ];
end;

% Clear all instruments
GenericInstrument.ClearAll;

% Create AWG objects
awgs(1) = AWG_Tek_70k( 'visa', 'agilent', 'TCPIP0::192.168.123.83::inst0::INSTR' );
awgs(2) = AWG_Tek_70k( 'visa', 'agilent', 'TCPIP0::192.168.123.84::inst0::INSTR' );
% awgs(1) = AWG_Tek_70k( 'tcpip', '192.168.123.83', 4000 );
% awgs(2) = AWG_Tek_70k( 'tcpip', '192.168.123.84', 4000 );
for n = 1:2
	awgs(n).Debug = 1;
end;

% Create AFG object
afg = AFG_Tek_3k( 'visa', 'agilent', 'TCPIP0::192.168.123.62::inst0::INSTR' );

% Initialize and setup AWGs
try
    % Initialize AFG
	afg.Initialize;
    
	% Stop AFG
	afg.Stop(1);
    
	% Initialize AWGs
	awgs(1).Initialize( 'Phase', 0, ...
		'Amplitude', 0.25, 'Samprate', Signal.awgRs, 'Clockrate', Signal.awgRs / 4 );
	awgs(1).setSamplingFrequency( 0, 0 );
	awgs(1).Send( 'CLOCk:OUTPut:STATe ON', true );
    pause(2)
	awgs(2).Initialize( 'Phase', 0, ...
		'Amplitude', 0.25, 'Samprate', Signal.awgRs, 'Clockrate', Signal.awgRs / 4, 'AdjustClock', true );
	
	for n = 1:2
		awgs(n).SequenceDelay = sequenceDelays( n );
	end;
	
	
	
	
	% Stop AWGs
	for n = 1:2
		awgs( n ).Stop;
	end;
	
	% Upload waveforms and markers
	for n = 1:2
		marker = zeros( 1, size( Signal.awgsig, 2 ) );
		if n == 2
			Ns = 4 * lcm( Signal.Rs, awgs( n ).Samprate ) / Signal.Rs;
			for m = 1:Ns
				marker( m:( 2 * Ns ):end ) = 1;
			end;
		elseif n == 1
			marker( 1:round( length( marker ) / 2 ) ) = 1;
		end
		waveform_name{n} = awgs( n ).UploadWaveform( Signal.awgsig( n, : ), 'swave', marker );
	end;
	
	
	
	% Assign new waveforms
	for n = 1:2
		awgs( n ).SetWaveform( waveform_name{ n } );
	end;
	
	% Start AWGs
	for n = 1:2
		awgs( n ).Start;
	end;
	% Readjust phases
	for n = 1:2
		awgs(n).setPhase( phases(n) );
	end;
	% Wait a bit to finish everything
	pause(5);
	
	% Start AFG
	afg.Start(1);
	
	pause(1);
	
	
	
catch e
	GenericInstrument.ReleaseAll( awgs );
	afg.Release;
	delete( awgs );
	delete( afg );
	rethrow(e);
end
GenericInstrument.ReleaseAll( awgs );
afg.Release;
delete( awgs );
delete( afg );