function results = Massive_MIMO_OFDM(OFDM, Chan, BS, UE, SimId)
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
% 1/sqrt(Nt) is to scale down the power between the antennas
UniCoeff = 1/sqrt(Nt);
OFDM.qamTx = UniCoeff...
             *(conj(Chan.CFR)./abs(Chan.CFR)).*repmat(qamTx, [1, Nt]);
%% IFFT + CP addition
OFDM.modulated = sqrt(OFDM.nfft)*ifft(OFDM.qamTx,OFDM.nfft);
OFDM.Tx = [OFDM.modulated(OFDM.nfft-OFDM.cpLen+1:end,:); OFDM.modulated];

%% Transmission through the channel
[OFDM.Rx, ~] = mimoChannelObj(OFDM.Tx);

%% Simulation loop over the SNRs
results.Ber = 0;
SigPwr = sum(mean(abs(OFDM.qamTx).^2));
% SigPwr = 1;

for SNRId = 1:length(OFDM.SNRdBList)
    % operating SNR value
    OFDM.SNRdB = OFDM.SNRdBList(SNRId);
    
    if Chan.Noise
        noiseComplexSig = 1/sqrt(2)*(randn(size(OFDM.Rx)) + 1i*randn(size(OFDM.Rx)));
        noisePwr = SigPwr/(db2pow(OFDM.SNRdB));
        Chan.noisePwr = noisePwr;
    else
        noiseComplexSig = 0;
        noisePwr = 0;
    end
    %%% Noise addition
    Channel_coeff = sum(abs(Chan.CFR), 2);
    Noisecoeff = [Channel_coeff(OFDM.nfft-OFDM.cpLen+1:end,:); Channel_coeff];
    OFDM.Rxnoisy = OFDM.Rx + sqrt(Noisecoeff).*noiseComplexSig*sqrt(noisePwr);
  
    % OFDM Demodulator and Equalizer
    % 1/sqrt(Nt) is added to scale down the constellation. Therefore the
    % BER plots are aligned correctly
    [Ber, eqSym] = OFDMBasebandDemodulator(sqrt(Nt)*OFDM.Rxnoisy, dataBitsIn, OFDM, Chan, BS);
    
    % Saving the current BER value
    results.Ber(SNRId) = Ber.AllCarriers;  
    
    % Scatter plot of received symbols
    if 0
    scatterplot(eqSym(:))
    end
end

end