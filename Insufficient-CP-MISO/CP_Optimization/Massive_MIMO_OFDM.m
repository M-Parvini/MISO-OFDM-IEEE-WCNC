function results = Massive_MIMO_OFDM(OFDM, Chan, BS, UE)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MASSIVE MIMO
% Beam Squint Effect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Baseband Modulator
% OFDM Modulator
Nt = BS.nAntenna;
Nr = UE.nAntenna;

[qamTx, dataBitsIn, pilots] = OFDMBasebandModulator(OFDM, Chan);

%% MISO channel modeling
[pathGains, mimoChannelObj] = MimoChannel(Chan, OFDM, BS, UE);
Chan.CIR = reshape(squeeze(pathGains), [], Nt);
Chan.CFR = fft(Chan.CIR, OFDM.nfft, 1);

%% Precoding MRT
%%% The precoder keeps the unit power constraint
UniCoeff = 1/sqrt(Nt);
OFDM.qamTx = UniCoeff...
             *(conj(Chan.CFR)./abs(Chan.CFR)).*repmat(qamTx, [1, Nt]);

%%% No precoding
% OFDM.qamTx = 1/sqrt(Nt)*repmat(qamTx, [1, Nt]);

%% IFFT + CP addition
OFDM.modulated = sqrt(OFDM.nfft)*ifft(OFDM.qamTx,OFDM.nfft);
OFDM.Tx = [OFDM.modulated(OFDM.nfft-OFDM.cpLen+1:end,:); OFDM.modulated];

%% Transmission through the channel
[OFDM.Rx, ~] = mimoChannelObj(OFDM.Tx);

%% Simulation loop over the SNRs
results.Ber = 0;
results.PU = 0;
results.PISI = 0;
results.NoisePower = 0;

SigPwr = sum(mean(abs(OFDM.qamTx).^2));

for SNRId = 1:length(OFDM.SNRdBList)
    % operating SNR value
    OFDM.SNRdB = OFDM.SNRdBList(SNRId);
    
    % ISI and Useful power calculation
    Powers = Insufficient_CP_ISI_Useful_Powers(OFDM, Chan, BS, UE);

    if Chan.Noise
        noiseComplexSig = 1/sqrt(2)*(randn(size(OFDM.Rx)) + 1i*randn(size(OFDM.Rx)));
        noisePwr = SigPwr/(db2pow(OFDM.SNRdB));
        Chan.noisePwr = noisePwr;
    else
        noiseComplexSig = 0;
        noisePwr = 0;
    end
    %%% Noise addition
    OFDM.Rxnoisy = OFDM.Rx + sqrt(Nt)*noiseComplexSig*sqrt(noisePwr);

    % OFDM Demodulator and Equalizer
    % 1/sqrt(Nt) is added to scale down the constellation. Therefore the
    % BER plots are aligned correctly
    [Ber, eqSym] = OFDMBasebandDemodulator(sqrt(Nt)*OFDM.Rxnoisy, dataBitsIn, OFDM, Chan, BS);
    
    % Saving the values
    results.Ber(SNRId) = Ber.AllCarriers;  
    results.PU(SNRId) = Powers.P_Useful;
    results.PISI(SNRId) = Powers.P_Interference;
    results.NoisePower(SNRId) = noisePwr;
    
    % Scatter plot of received symbols
    if 0
    scatterplot(eqSym(:))
    end
end

end