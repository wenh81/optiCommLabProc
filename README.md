# optiCommLabProc
Optical Fiber Communication lab/experiments processing scripts: for directly deteted M-QAM and PAM-M signal

# Include Modules:

1. MATLAB script of offline data capture for TekTronix and Agilent
2. Digital DC block
3. Digital AGC
4. Digital Timing recovery: Mueller and Muller clock recovery algorithm (M&M)
5. Digital re-Sample
6. CMA equalizer for QPSK/4-QAM
7. LMS equalizer
8. Signal lock indicator
9. PPG demapping
10. bit sequence synchronization
11. BER calculation
12. Kramers Kronig Receiver is enable to both of the two offline platform

# Dir introduction 
* analysis
    - analysis script, such as plotting figures and some other test scripts
* config 
    - configuration files
* database 
    - basic data, such as rootpath and prbs data file
* doc 
    - documents
* dsp 
    - digital signal processing modules
* lib 
    - common lib functions
* logs 
    - programme running log files
* math 
    - basic mathematics function
* offline 
    - offline experiment script, including DSO capture script
* offlineData 
    - saved offline data from DSO
* ref 
    - reference code
* results 
    - offline processing results
* scripts 
    - main scripts
* tools 
    - common tool functions
* utility 
    - common utilities

# Usage:
1. change MATLAB work path to optiCommLabProc

2. run setisimenv.m to add simulation path, and runMainOfflinePPG.m will be opened automatically

3. open offline/loadOfflineDataPPG.m for setting offline parameters:

   1. the main parameters allow to change: 

      ```
      % controller
      isCaptureDSO           = 0; % set to 0 for loading data from local driver
      isPltCapturedData      = 1; % plot time domain waveform
      isSaveData             = 0; % is save MATLAB workspace data to driver
      dataLen                = [];  % {number or []}, always let it be []
      ```

4. open config/cfgOfflinePPG.m for DSP parameters configuration
   1. PPG with PRBS23 testing Okay, please choose "prbs23_18" for priority test
   2. Match the baud rate "fBaud" to PPG settings
   3. Some other DSP parameters could be changed in this script


# Information:
Platform version: B002T001
Author: hongbo.zhang83@gmail.com
