function [qamTx, dataBitsIn, Pilots] = OFDMBasebandModulator(OFDM, Chan)
% Baseband modulator consisting of QAM and OFDM modulation

%%% Create data bits
dataBitsIn = randi([0,1],[OFDM.nfft*OFDM.bps OFDM.numOFDMSym ...
    OFDM.numStreams]);

%%% QAM mode
QAM_M = 2^OFDM.bps; % Modulation order
qamTx = qammod(dataBitsIn,QAM_M,'gray',...
    InputType="bit", ...
    UnitAveragePower=true);

%%% Create data bits for channel estimation
EstimBits = 2; % QPSK for pilots
Pilots = 0;
if Chan.Estim
    PilotdataBitsIn = randi([0,1],[OFDM.nfft*EstimBits OFDM.numOFDMSym ...
        OFDM.numStreams]);
    
    %%% QPSK mode
    Pilots = qammod(PilotdataBitsIn,2^EstimBits,'gray',...
        InputType="bit", ...
        UnitAveragePower=true);
end

%%% OFDM Modulation
% ofdmOut = ofdmmod(qamTx,OFDM.nfft,OFDM.cpLen)*sqrt(OFDM.nfft);