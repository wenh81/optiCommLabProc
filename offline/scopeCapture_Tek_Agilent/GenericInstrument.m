classdef GenericInstrument < handle
	properties
		Debug = 0;
		g;
		Type;
		Vendor;
		Address;
	end
	
	methods (Abstract=true)
		Initialize( I )
	end
	
	methods( Static = true )
		function ClearAll()
			aux = instrfind;
			if ~isempty( aux )
				fclose( aux );
				delete( aux );
			end
		end
		function ReleaseAll( insts )
			for n = 1:length( insts )
				insts(n).Release;
			end;
		end
		function InitializeAll( insts, varargin )
			for n = 1:length( insts )
				insts(n).Initialize( varargin{:} );
			end;
		end
	end
	
	methods
		function dataString = Query( I, query )
			if I.Debug
				fprintf( '%s >> %s\n', I.Address, query );
			end
			fprintf( I.g, query );
			dataString = deblank( fscanf( I.g ) );
			if I.Debug
				fprintf( '%s << %s\n', I.Address, dataString);
			end
		end
		
		function Send( I, query, check )
			if nargin < 3
				check = false;
			end;
			if I.Debug
				fprintf( '%s >> %s\n', I.Address, query );
			end
			fprintf( I.g, query );
			if check
				I.Query( '*OPC?' );
				str = I.Query( 'SYSTem:ERRor?' );
				aux = strsplit( str, ',' );
				try
					auxnum = str2num( aux{1} );
					if auxnum ~= 0
						error( str );
					end;
				catch e
					error( str );
				end;
			end;
		end
		
		
		function Release( I )
			try
                
				fclose( I.g );
			catch e
				disp( e.message );
			end;
			delete( I.g );
			if I.Debug
				disp( sprintf( '%s Instrument Release >> OK', I.Address ) );
			end
		end
		
		
		
		function GenericInitialization( I )
			I.g = feval( I.Type, I.Vendor, I.Address );
		end
	end
end