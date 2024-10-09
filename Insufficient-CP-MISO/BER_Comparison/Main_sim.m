clc
clear
tic
% close all
% rng(1997); % For reprodubility
% poolobj=parpool('HPCServerProfile1',200)
%%%%%%%%%%%%%% Parameter Initialization for Simulation %%%%%%%%%%%%%%%%
NumSim = 1000;
Antenna = [1 1];  % [Nt Nr]
Nt = Antenna(1);
Nr = Antenna(2);

%%% SNR and Noise
SNRlist = 10:5:50;
SNRlistBit = SNRlist-pow2db(4);
CP = [10, 20, 30, 40, 50];
NoiseList = zeros(length(CP), length(SNRlist), NumSim);

%%% Variables
BerSim = zeros(length(CP), length(SNRlist), NumSim);
BerStat = zeros(length(CP), length(SNRlist));
PU_stat = zeros(length(CP), length(SNRlist), NumSim);
ISI_stat = zeros(length(CP), length(SNRlist), NumSim);
SINRStat = zeros(length(CP), length(SNRlist));

for cp = 1:length(CP)
    [OFDMParams, ChanParams, BSParams, UEParams] = ...
            InitializeParams(SNRlist, Nt, Nr, CP(cp));
    parfor SimId = 1:NumSim
        %%% Simulation Cycle
        results = ...
            Massive_MIMO_OFDM(OFDMParams, ChanParams, BSParams, UEParams, SimId);
        if mod(SimId,100) == 0
           fprintf(':')
        end
        %%% Saving the values
        BerSim(cp, :, SimId) = results.Ber;
        PU_stat(cp, :, SimId) = results.PU;
        ISI_stat(cp, :, SimId) = results.PISI;
        NoiseList(cp, :, SimId) = results.NoisePower;
    end
end

save('results')
%%% SINR calculation
toc

%% BER
for cp = 1:length(CP)
    Total_Useful_Power = mean(squeeze(PU_stat(cp,:,:)),2)*Nt;
    Total_ISI_Power = mean(squeeze(ISI_stat(cp,:,:)),2)*Nt;
    SINRStat(cp, :) = Total_Useful_Power./(Total_ISI_Power+mean(squeeze(NoiseList(cp,:,:)),2));
    BerStat(cp, :) = BER_fading(OFDMParams.bps, SINRStat(cp, :), Nt);
end
figure
for cp = 1:length(CP)
    txt1 = ['Simulated, CP = ', num2str(CP(cp))];
    semilogy(SNRlistBit, mean(squeeze(BerSim(cp,:,:)),2), '-', DisplayName=txt1);
    hold on
    txt2 = ['Statistical, CP = ', num2str(CP(cp))];
    semilogy(SNRlistBit, BerStat(cp,:), '--', DisplayName=txt2);
end
legend show
grid
title('BER')

% delete(poolobj)