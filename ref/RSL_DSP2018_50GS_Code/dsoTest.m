addpath(genpath('./common'))
Scope = Scope_Tek_70k( 'visa', 'agilent', 'TCPIP0::192.168.2.101::INSTR' );
Signal.scopesig = int8( Scope.getQuickTrace.' );