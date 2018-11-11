%% RE-TIMING - CMA or LMS EQUALIZER to recover subcarrier frequency

if (P.EQ.Enable == 1),

    % RESAMPLE to 2 SPS

    Sig_RxRRC.SPS = 2;

    P.sample_ratio  = Sig_RxRRC.Ns/Sig_RxRRC.SPS; % Sample ratio

    Sig_RxRRC_resampled = Resampler( Sig_RxRRC, P );

   

    Sig_RxRRC_resampled.Ns = Sig_RxRRC_resampled.Fs/Sig_RxRRC_resampled.Fb;

    Sig_RxRRC_resampled.Nt = length(Sig_RxRRC_resampled.Et);

  

    P.FilterLength = FilterLength(ii);

    %%% CMA-LMS EQUALIZER

    if (P.EQ.CMAEq  == 1),  

        P.QAM16_Radii = [sqrt(2) sqrt(10) sqrt(18)]/sqrt(10);

        if P.SuperConvergence == 1

            mu = [5e-3 5e-3 3e-3 2e-3];

        else

            mu = [1e-3];

        end      

        

        for index = 1:length(mu),

            disp(['Simulating CMA-LMS EQ ' num2str(index) ' of ' num2str(length(mu)) ' with ' num2str(mu(index)) ' step-size' ])

            P.mu = mu(index);   

%            equalised = QAM_RDE_fast(SignalOut, P);

            [equalisedCMA, P] = rde_qam16_onePol( Sig_RxRRC_resampled, P );

        end

    else

        equalisedCMA = Sig_RxRRC_resampled;

    end

   

    %%% Compensate the Phase Offset

    if isfield (P,'PhaseRotation') && (P.PhaseRotation.Enable == 1) && (P.EQ.CMAEq  == 1)

        arg1 = imag(log(sum(equalisedCMA.Et(P.SDiscard+2:2:end-P.EDiscard).^4)))/4;

        equalisedCMA.Et = equalisedCMA.Et*exp(-1j*(arg1+pi/4));

    end

   

    %%% DD-LMS equaliser

    if (P.EQ.DDLMSEq == 1),

        if P.SuperConvergence == 1

           mu = [5e-3 3e-3 1e-3 7e-4 5e-4];

        else

           mu = [1e-3 5e-4  1e-4];

        end

        P.Th = 2/sqrt(10);

        equalisedDD = equalisedCMA;

        for index = 1:length(mu),

            disp(['Simulating DD-LMS  EQ ' num2str(index) ' of ' num2str(length(mu)) ' with ' num2str(mu(index)) ' step-size' ])

            P.mu = mu(index);

            [equalisedDD, P] = DD_LMS_16QAM(equalisedDD, P);

        end

%         equalisedDD = temp2;% pass the signal to final equalizer output

    else

        equalisedDD = equalisedCMA;% no DD-LMS equalizer

    end

end%% end Equalizer

 

 

%% PERFORMANCE EVALUATION

%%% EVM Calculation

RXSamples    = equalisedDD.Et(1,P.SDiscard:2:end-P.EDiscard);