clc
clear
tic
% close all
% rng(1997); % For reprodubility
% poolobj=parpool('HPCServerProfile1',200)
%%%%%%%%%%%%%% Parameter Initialization for Simulation %%%%%%%%%%%%%%%%
NumSim = 500;
TxAntenna = [1, 2, 4, 8, 16, 32];  % [Nt Nr]
%%% SNR and Noise
SNRlist = 10:5:50;
delay_spread = [30 300]*1e-9;
SNRlistBit = SNRlist;
CP = [16 25 34 44 77]; % From solving the optimization problem
CPMax = 77;

%%% Variables
Rate = zeros(length(TxAntenna), length(delay_spread), length(CP), length(SNRlist), NumSim);
for nt = 1:length(TxAntenna)
    Nt = TxAntenna(nt);
    Nr = 1;
    for ds = 1:length(delay_spread)
        DS = delay_spread(ds);
        for cp = 1:length(CP)
            [OFDMParams, ChanParams, BSParams, UEParams] = ...
                    InitializeParams(SNRlist, Nt, Nr, CP(cp), CPMax, DS);
            parfor SimId = 1:NumSim
                %%% Simulation Cycle
                results = ...
                    Massive_MIMO_OFDM(OFDMParams, ChanParams, BSParams, UEParams, SimId);
                %%% Saving the values
                Rate(nt, ds, cp, :, SimId) = results.Capacity;
            end
        end
    end
end
save('results')
%%% SINR calculation

%%% Run the plots.m to see the figures

toc
% delete(poolobj)