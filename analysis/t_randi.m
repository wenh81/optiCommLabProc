% test randi prbs provided by matlab
Signal.M     = 4; % QAM modulation order
Signal.nsymb =2 * ( 2^15 - 1); % Tentative number of symbols - The actual number of symbols will be calculated later
Signal.Nsc   = 2; % Number of sub-carriers 2  ### 1 for alignment#### 2 for

seed         = 101;

rng(seed);
txData1      = randi( [ 0, 1 ], Signal.Nsc, Signal.nsymb * log2( Signal.M ) ) ;

rng(seed);
txData2      = randi( [ 0, 1 ], Signal.Nsc, Signal.nsymb * log2( Signal.M ) ) ;

isequal(txData1,txData2)