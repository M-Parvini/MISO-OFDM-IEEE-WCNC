function [OFDM, Chan, BS, UE] = ...
InitializeParams(SNRdBList, Nt, Nr, cp, CPMax, DS)

OFDM.SNRdB = 0;                 % Signal-to-noise ratio
OFDM.SNRdBList = SNRdBList;     % Signal-to-noise ratio
OFDM.numStreams = 1;            % Number of parallel data streams (Ns)
OFDM.bps = 4;                   % Bits per QAM symbol
OFDM.nfft = 1024;               % FFT length
OFDM.cpLen = cp;                % Cyclic prefix length
OFDM.numOFDMSym = 1;            % Number of OFDM symbols
OFDM.subs = 120e3;              % Subcarrier spacing (B/M)
OFDM.BW = OFDM.nfft*OFDM.subs;  % System Bandwidth
OFDM.NF = 9;                    % Noise figure (not used when SNR is used)

%%% Channel parameters %%%
Chan.delay_spread = DS;    % Delay Spread of the channel
Chan.doppler = 0;
Chan.fc = 2e9;                  % center frequency
Chan.LSpeed = physconst('LightSpeed');
Chan.lambda = Chan.LSpeed/Chan.fc;
Chan.ChannelType = 'Custom';
Chan.LoS = true;
Chan.LoSKfactor = 1;
Chan.numPaths = 0;              % Will be determined after sampling
Chan.pathDelays = [0 3 7 9 11 19 41]*Chan.delay_spread;   % Path Delays
Chan.pathGains = [0 -1 -2 -3 -8 -17.2 -20.8];     % Path Gains
% Chan.pathGains  = pow2db(reNormalize(db2pow(pathGains)));

%%% Exponential power delay profile
L = CPMax;
Tm = (1/OFDM.BW)/Chan.delay_spread;
Chan.pathDelays = (1/OFDM.BW)*([0:L-1]);
% PDP_EXP_norm = exp((-1*Tm)*([0:params.sys.L-1]));
PDP_EXP = Tm*exp((-1*Tm)*([0:L-1]));
PDP_EXP_norm = reNormalize(PDP_EXP);
Chan.pathGains=pow2db(PDP_EXP_norm);
%%%



% Chan.pathGains  = [0 -1 -2 -3 -8 -17.2 -20.8];
Chan.Noise = true; % Check false for Noise free transmission
Chan.Estim = false; % Check false for Perfect channel estimation

%%% BS and UE parameters; LoS angle calculation %%%
BS.nAntenna = Nt;               % Number of transmit antennas (Nt)
UE.nAntenna = Nr;               % Number of receive antennas (Nr)

