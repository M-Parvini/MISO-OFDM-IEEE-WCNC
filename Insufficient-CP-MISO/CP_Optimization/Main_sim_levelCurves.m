clc
clear
tic
% close all
% rng(1997); % For reprodubility
% poolobj=parpool('HPCServerProfile1',200)
%%%%%%%%%%%%%% Parameter Initialization for Simulation %%%%%%%%%%%%%%%%
AntennaConfig(1,:) = [1 1];  % [Nt Nr]
Numbits = 4;    % 16 QAM

%%% SNR and Noise
SNRlist = 0:72;
SINR_th = 15; % dB:: [9 for bpsk][12 for 4-QAM][15 for 16-QAM]--> BER:1e-3
NoiseList = zeros(1, length(SNRlist));

%%% parameters
CP_max = 77; % samples => 7% overhead
delay_spread = 60e-9; % RMS delay spread
CP = 0:CP_max;        
S_rate = 120e3*1024; % sampling rate = SCS*nCarr
DS_taps = DS_sampling(delay_spread, S_rate);
Outage = [10, 1, 0.1, 0.01, 0.001];

%%% Level curves based on outage values
contourvecdB = OutageCurve(Outage, SINR_th, Numbits); % Eq. 13

%%% Variables
% Stat ==> statistical
BerStat = zeros(length(CP), length(SNRlist));
SINRStat = zeros(length(CP), length(SNRlist));
PU_stat = zeros(length(CP), length(SNRlist));
ISI_stat = zeros(length(CP), length(SNRlist));

for cp = 1:length(CP)
    Nt = AntennaConfig(1, 1);
    Nr = AntennaConfig(1, 2);
    
    fprintf(['Sim. step:: ', num2str(cp), '\n'])
    %%% Sim. Initialization
    [OFDMParams, ChanParams, BSParams, UEParams] = ...
    InitializeParams(SNRlist, Nt, Nr, Numbits, CP_max, delay_spread, CP(cp));
    
    %%% Simulation Cycle
    results = ...
        Massive_MIMO_OFDM(OFDMParams, ChanParams, BSParams, UEParams);

    %%% Saving the values
    PU_stat(cp, :) = results.PU;
    ISI_stat(cp, :) = results.PISI;
    NoiseList(1, :) = results.NoisePower;

    %%% SINR and BER calculation
    Total_Useful_Power = PU_stat(cp, :)*Nt;
    Total_ISI_Power = ISI_stat(cp, :)*Nt;
    SINRStat(cp, :) = Total_Useful_Power./(Total_ISI_Power + NoiseList(1, :));
    BerStat(cp, :) = BER_fading(Numbits, SINRStat(cp, :), Nt);
    
end

%%% optimization problem to find the minimum required CP and SNR values to
%%% satisfy the outage constraints
[optim_SE] = ...
CP_Optimization(SNRlist, CP_max, OFDMParams, contourvecdB, DS_taps);

%%% After the simulation run the plots.m file to plot
%%% Saving the results::>
save('results')

toc

% delete(poolobj)