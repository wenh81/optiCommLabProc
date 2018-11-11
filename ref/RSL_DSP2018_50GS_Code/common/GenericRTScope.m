classdef GenericRTScope < GenericInstrument
	properties
		scoperate
	end
	methods( Abstract = true )
		trace = getQuickTrace( I );
		trace = getTrace( I, updateskew );
		setSkew( I, skew );
	end
end