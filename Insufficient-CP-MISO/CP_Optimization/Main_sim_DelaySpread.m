clc
clear
tic
% close all
% rng(1997); % For reprodubility
% poolobj=parpool('HPCServerProfile1',200)
%%%%%%%%%%%%%% Parameter Initialization for Simulation %%%%%%%%%%%%%%%%
AntennaConfig(1,:) = [1 1];  % [Nt Nr]
Numbits = 4;

%%% SNR and Noise
SNRlist = 0:72;
SINR_th = 15; % dB:: [9 for bpsk] [12 for 4-QAM] [15 for 16-QAM]
NoiseList = zeros(1, length(SNRlist));

%%% parameters
CP_max = 72;
delay_spread = [10, 30, 50, 100, 300, 500]*1e-9;
CP = 0:CP_max;
S_rate = 120e3*1024; % sampling rate = SCS*nCarr
Outage = [10, 1, 0.1, 0.01]; % precent
contourvecdB = OutageCurve(Outage, SINR_th, Numbits); % outage level-curve

%%% Variables
Opt_vals = zeros(length(contourvecdB), 4, length(delay_spread)); %%% according to optimization output
for i = 1:length(Outage)
    for j = 1:length(delay_spread)
        DS_taps = DS_sampling(delay_spread(j), S_rate);
    
        Nt = AntennaConfig(1, 1);
        Nr = AntennaConfig(1, 2);
    
        %%% Sim. Initialization
        [OFDMParams, ChanParams, BSParams, UEParams] = ...
        InitializeParams(SNRlist, Nt, Nr, Numbits, CP_max, ...
        delay_spread(j), CP(1));
    
        [optim_SE] = ...
                CP_Optimization(SNRlist, CP_max, ...
                OFDMParams, contourvecdB(i), DS_taps);
        Opt_vals(i, :, j) = optim_SE;
    end
end

toc

% delete(poolobj)