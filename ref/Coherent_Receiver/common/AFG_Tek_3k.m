classdef AFG_Tek_3k < GenericInstrument
	properties
	end
	
	methods
		function I = AFG_Tek_3k( Type, Vendor, Address )
			I.Type = Type;
			I.Vendor = Vendor;
			I.Address = Address;
		end
		
		function Initialize( I, varargin )
			% Initialize instrument
			I.GenericInitialization;
			
			% Specific instrument properties
			set( I.g, ...
				'Timeout', 30 );
			
			% Start communication
			fopen( I.g ); pause(0.1);
			I.Send( '*CLS' );
			
		end
		
		function QuickStart( I, channel )
			try
				I.Initialize;
				I.Start( channel );
				I.Release;
			catch e
				I.Release;
				rethrow( e );
			end;
		end;
		
		function QuickStop( I, channel )
			try
				I.Initialize;
				I.Stop( channel );
				I.Release;
			catch e
				I.Release;
				rethrow( e );
			end;
		end;
		
		
		function Start( I, channel )
			if isempty( find( channel == [ 1 2 ] ) )
				error( 'Invalid channel number' );
			end;
			I.Send( sprintf( 'OUTPut%d:STATe ON', channel ) );
		end;
		
		function Stop( I, channel )
			if isempty( find( channel == [ 1 2 ] ) )
				error( 'Invalid channel number' );
			end;
			I.Send( sprintf( 'OUTPut%d:STATe OFF', channel ) );
		end
		
	end
end