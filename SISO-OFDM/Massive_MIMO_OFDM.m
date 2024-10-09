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
OFDM.qamTx = repmat(qamTx, [1, Nt]);

%% IFFT + CP addition
OFDM.modulated = sqrt(OFDM.nfft)*ifft(OFDM.qamTx,OFDM.nfft);
OFDM.Tx = [OFDM.modulated(OFDM.nfft-OFDM.cpLen+1:end,:); OFDM.modulated];

%% Transmission through the channel
[OFDM.Rx, ~] = mimoChannelObj(OFDM.Tx);

%% Simulation loop over the SNRs
results.Ber = 0;
SigPwr = mean(abs(OFDM.Tx .^2));

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
    OFDM.Rxnoisy = OFDM.Rx + noiseComplexSig*sqrt(noisePwr);
  
    % OFDM Demodulator and Equalizer
    [Ber, eqSym] = OFDMBasebandDemodulator(OFDM.Rxnoisy, dataBitsIn, OFDM, Chan, BS);
    
    % Saving the current BER value
    results.Ber(SNRId) = Ber.AllCarriers;    
    % Scatter plot of received symbols
    if 0
    scatterplot(eqSym(:))
    end
end

end