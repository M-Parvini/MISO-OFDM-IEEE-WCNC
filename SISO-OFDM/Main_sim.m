clc
clear
% close all
% rng(1997); % For reprodubility
% poolobj=parpool('HPCServerProfile1',200)
%%%%%%%%%%%%%% Parameter Initialization for Simulation %%%%%%%%%%%%%%%%
NumSim = 1000;
AntennaConfig(1,:) = [1 1];  % [Nt Nr]
SNRlist = 0:10:40;
SNRlistBit = SNRlist - 10*log10(4);
ResultsBer = zeros([size(AntennaConfig, 1), NumSim, length(SNRlist)]);

for antenna = 1:size(AntennaConfig, 1)
    Nt = AntennaConfig(antenna, 1);
    Nr = AntennaConfig(antenna, 2);
    [OFDMParams, ChanParams, BSParams, UEParams] = ...
            InitializeParams(SNRlist, Nt, Nr);
    for SimId = 1:NumSim
        %%% Simulation Cycle
        results = ...
            Massive_MIMO_OFDM(OFDMParams, ChanParams, BSParams, UEParams, SimId);
        if mod(SimId,100) == 0
           fprintf(':')
        end
        ResultsBer(antenna, SimId, :) = results.Ber;

    end
end

%% All the Carriers
figure
for antenna = 1:size(AntennaConfig, 1)
    txt = ['[',num2str(AntennaConfig(antenna,:)),']'];
    p(antenna) = semilogy(SNRlistBit, ...
        mean(squeeze(ResultsBer(antenna, :,:)),1), 'DisplayName', txt);
    hold on
end
legend(p(1:end))
grid
title('BER')

% delete(poolobj)