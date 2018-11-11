classdef Scope_Tek_70k < GenericRTScope
	properties
		scope;
		tag;
	end
	methods
		function I = Scope_Tek_70k( Type, Vendor, Address )
			I.Type = Type;
			I.Vendor = Vendor;
			I.Address = Address;
		end
		
		function Initialize( I, varargin )
			% Initialize instrument
			I.GenericInitialization;
			
			
			% Other characteristics
			% timeout
			set( I.g, 'Timeout', 30 );
			% Input buffer
			set( I.g, 'Inputbuffersize', 1024*1024*64 );
			
			% Start communication
			fopen( I.g );
			
			% clear
			I.Send( '*CLS' );
			% Headers off
			I.Send( ':HEADER OFF;');
			% Clear the whole status structure and registers.
			I.Send( '*CLS;');
			I.Send( 'DESE 255;');
			I.Send( '*ESE 61;');
			I.Send( '*SRE 48;');
			I.Send( ':MEASU:REFL:METH PERC;');
			I.Send( ':DAT:ENC RIB;');
			I.Send( ':DAT:STAR 1;');
			I.Send( ':DATA:STOP 400000000;');
			I.Send( '*DDT #211:TRIG FORC;');
			I.Send( 'VERB OFF;');
			
		end
		
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Get a trace quickly
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function trace = getQuickTrace( I, varargin )
			try
				I.Initialize;
				if ~isempty( varargin )
					I.setScale( varargin{1} );
				end
				trace = I.getTrace( varargin{:} );
				I.Release;
			catch e
				I.Release;
				rethrow( e );
			end;
		end;
		
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Get a trace
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function trace = getTrace( I, varargin )
			
			% Capture waveform
			I.Send( ':ACQuire:STOPAfter SEQUENCE;');
			I.Send( ':ACQUIRE:STATE 1;' );
			I.Query( '*OPC?' );
			
			% Transfer waveforms with CURVe command
			I.Send( ':WFMOutpre:BYT_N 1;');
			% Tkdpo7k.cpp tkdpo7k_Get_Curve_Data_Multiple() contents
			% Chan 1
			I.Send( ':DATA:SOUrce CH1;');
			I.Send( 'CURVe?');
			curveChan1 = binblockread(I.g, 'int8');
% 			% Chan 2
			I.Send( ':DATA:SOUrce CH2;');
			I.Send( 'CURVe?');
			curveChan2 = binblockread(I.g, 'int8');
			% Chan 3
			I.Send( ':DATA:SOUrce CH3;');
			I.Send( 'CURVe?');
			curveChan3 = binblockread(I.g, 'int8');
			% Chan 4
			I.Send( ':DATA:SOUrce CH4;');
			I.Send( 'CURVe?');
			curveChan4 = binblockread(I.g, 'int8');
			
			% Compose output variable
			%trace = [complex(curveChan1.', -curveChan2.'); complex(curveChan3.', -curveChan4.')];
			trace = [curveChan1, curveChan2, curveChan3, curveChan4];
			%trace = [curveChan1, curveChan3];
			% Update sampling rate
			I.updateSampleRate;
		end;
		
		
		function updateSampleRate( I )
			I.scoperate = str2num( I.Query( 'HORizontal:MODE:SAMPLERate?' ) );
		end;
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Set skew
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function setSkew( I, skew )
			
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Set skew
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function setScale( I, scale )
			% Set scale
			I.Send( sprintf( 'HORIZONTAL:MODE:SCALE %.0e', scale ) );
			I.Query( '*OPC?' );
		end
	end
end