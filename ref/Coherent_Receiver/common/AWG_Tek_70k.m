classdef AWG_Tek_70k < GenericInstrument
	properties
		Samprate = 50e9;
		Clockrate = 12.5e9;
		Phase = 0;
		SequenceDelay = 0;
		Amplitude = 0.25;
		TriggerLevel = 0.5;
		AdjustClock = false;
		
		NTransfer = 8 * 8192;
	end
	methods
		function I = AWG_Tek_70k( Type, Vendor, Address )
			I.Type = Type;
			I.Vendor = Vendor;
			I.Address = Address;
		end
		
		function Initialize( I, varargin )
			% Initialize instrument
			I.GenericInitialization;
			
			% Specific instrument properties
			set( I.g, ...
				'OutputBufferSize', 65535 * 65535, ...
				'Timeout', 30 );
			
			% Start communication
			fopen( I.g );
			I.Send( '*CLS' );
			
			% Options specifically for this experiment
			%I.Send( 'TRIGger:MODE SYNChronous', true ); % Trigger mode
			
			% Check if further initialization is required
			if length( varargin ) == 0
				return;
			end
			
			% Parse inputs for additional setups
			p = inputParser;
			addOptional( p, 'Samprate', I.Samprate, @isnumeric );
			addOptional( p, 'Clockrate', I.Clockrate, @isnumeric );
			addOptional( p, 'Phase', I.Phase, @isnumeric );
			addOptional( p, 'Amplitude', I.Amplitude, @isnumeric );
			addOptional( p, 'AdjustClock', false );
			addOptional( p, 'TriggerLevel', I.TriggerLevel );
			
			opt = parse( p, varargin{:} );
			
			% Copy parameters to object properties
			for n = 1:length( p.Parameters )
				I.( p.Parameters{ n } ) = p.Results.( p.Parameters{ n } );
			end;
			
			% Set configurations
			I.setAmplitude;
% 			I.setSamplingFrequency;
			I.setPhase;
% 			I.setTriggerLevel;
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Adjust amplitude
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function setAmplitude( I, amp )
			%%%%%%%%%%%%%
			% Amplitude %
			%%%%%%%%%%%%%
			if nargin == 2
				I.Amplitude = amp;
			else
				amp = I.Amplitude;
			end;
			I.Send( ...
				sprintf( 'SOURCE:VOLTAGE:AMPLITUDE %.3f', amp ) );
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Adjust sampling frequency
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function setSamplingFrequency( I, adjust, useExternal )
			if nargin < 3
				useExternal = 1;
			end;
			
			%%%%%%%%%%%%%%%%%
			% Sampling rate %
			%%%%%%%%%%%%%%%%%
			multiplierRate = I.Samprate / I.Clockrate;
			if rem( multiplierRate, 1 ) ~= 0
				error( 'Invalid ratio of sampling rate and clock rate' );
			end;
			% Set clock source
			if useExternal
				I.Send( 'CLOCk:SOURce EXTernal', true );
				
				% Set multiplier
				I.Send( ...
					sprintf( 'CLOCk:ECLock:MULTiplier %d', multiplierRate ), false );
				% Set clock frequency
				I.Send( ...
					sprintf( 'CLOCk:EClock:FREQuency %.3e', I.Clockrate ), false );
				% Adjust clock
				if nargin < 2
					adjust = I.AdjustClock;
				else
					I.AdjustClock = adjust;
				end;
				if adjust
					I.Send( 'CLOCk:ECLock:FREQuency:ADJust', true );
				end;
			else
				I.Send( 'CLOCk:SOURce INTernal', true );
				I.Send( sprintf( 'CLOCk:SRATe %.4e', I.Samprate ), true );
			end;
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Adjust phase
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function setPhase( I, phase )
			if nargin < 2
				phase = I.Phase;
			else
				I.Phase = phase;
			end
			I.Send( sprintf( 'CLOCK:PHASE:ADJUST %d', phase ), true );
		end;
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Adjust trigger level
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function setTriggerLevel( I, level )
			if nargin < 2
				level = I.TriggerLevel;
			else
				I.TriggerLevel = level;
			end
			I.Send( sprintf( 'TRIGger:LEVel %.3e', level ), true );
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Load waveform
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function name = UploadWaveform( I, waveform, name, mk1, mk2 )
			nsamples = length( waveform );
			if nargin < 3
				% Generate random name
				name = 'wave';
				mk1 = [];
				mk2 = [];
			elseif nargin < 4
				mk1 = [];
				mk2 = [];
			elseif nargin < 5
				mk2 = [];
			end;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Evaluate name of the waveform
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Get size of the waveform list
			FoundWave = false;
			nwaves = str2num( I.Query( 'WLISt:SIZE?' ) );
			if nwaves > 0
				% Cycle waveforms to check if the name exists
				testname = sprintf( '"%s"', name );
				for n = 1:nwaves
					curwavename = I.Query( sprintf( 'WLISt:NAME? %d', n ) );
					if strcmp( curwavename, testname )
						% Found an equal name. Check if wave in use
						I.Send( sprintf( 'WLISt:WAVEFORM:DELETE %s', curwavename ), true );
% 						FoundWave = true;
						break;
					end;
				end;
			end;
% 			if ~FoundWave
				% Create new wave
				I.Send( sprintf( 'WLISt:WAVEFORM:NEW "%s",%d', name, nsamples ), true );
				pause(1);
% 			end;
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Load waveform
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Introduce sequence delay
			waveform = circshift( waveform, [ 0, round( I.SequenceDelay * I.Samprate ) ] );
			% Transfer data in segments
			dataPos = 1;
			nTransfer = 0;
			NTRANSFER = I.NTransfer;
			if I.Debug
				fprintf( 'Transfering data in 16384 byte segments...\n' );
			end;
			for pos = 1:NTRANSFER:nsamples;
				if I.Debug
					fprintf( '%.0f%\n', pos / nsamples * 100 );
				end;
				dataStart = pos;
				dataEnd = pos + NTRANSFER - 1;
				if dataEnd > nsamples
					dataEnd = nsamples;
				end;
				dataLen = dataEnd - dataStart + 1;
				TrCommand = sprintf( 'WLISt:WAVEFORM:DATA "%s",%d,%d,', ...
					name, ...
					dataStart - 1, ...
					dataLen );
				if I.Debug
					fprintf( '>> %s\n', TrCommand );
				end;
				% Finally, send data
				binblockwrite( I.g, waveform( dataStart:dataEnd ), ...
					'float32', TrCommand );
				pause( 0.25 );
				% Check errors
				resp = I.Query( 'SYSTEM:ERROR?' );
				if resp(1) ~= '0'
					disp( resp );
					error( 'Error sending data to AWG' );
				end;
			end;
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Load marker1
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Check if marker data exists
			if ~isempty( mk1 ) || ~isempty( mk2 )
				mkdata = zeros( 1, length( waveform ), 'uint8' );
				% Generate binary data
				if ~isempty( mk1 )
					mkdata = 64 * mk1;
				end;
				if ~isempty( mk2 )
					mkdata = mkdata + mk2;
				end;
				
				% Transfer marker data in 16384 byte segments
				dataPos = 1;
				nTransfer = 0;
				NTRANSFER = 8 * I.NTransfer;
				if I.Debug
					fprintf( 'Transfering marker data in 16384 byte segments...\n' );
				end;
				
				for pos = 1:NTRANSFER:length( mkdata );
					
					dataStart = pos;
					dataEnd = pos + NTRANSFER - 1;
					if dataEnd > length( mkdata )
						dataEnd = length( mkdata );
					end;
					dataLen = dataEnd - dataStart + 1;
					TrCommand = sprintf( 'WLISt:WAVEFORM:MARKER:DATA "%s",%d,%d,', ...
						name, ...
						dataStart - 1, ...
						dataLen );
					if I.Debug
						fprintf( '%s >> %s\n', I.Address, TrCommand );
					end;
					% Finally, send data
					binblockwrite( I.g, mkdata( dataStart:dataEnd ), ...
						'uint8', TrCommand );
					pause( 0.25 );
					% Check errors
					resp = I.Query( 'SYSTEM:ERROR?' );
					if resp(1) ~= '0'
						error( 'Error sending data to AWG' );
					end;
					
				end;
			end;
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Set waveform
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function SetWaveform( I, name )
			% Associate a waveform with the output
			I.Send( sprintf( 'SOURCE%d:WAVEFORM "%s"', ...
				1, name ), true );
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Start AWG
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function Start( I )
			
			
			% Check if outputs are on
			outState = I.Query( 'OUTPUT1?' );
			if strcmpi( outState, '0' )
				I.Send( sprintf( 'OUTPUT%d:STATE ON', 1 ), true );
			end
			I.Send( 'AWGCONTROL:RUN:IMMEDIATE', true );
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Stop AWG
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function Stop( I )
			I.Send( 'AWGCONTROL:STOP:IMMEDIATE', true );
		end
	end
end