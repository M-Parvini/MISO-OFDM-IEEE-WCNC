function [Ber, OFDMDemod] = ...
    OFDMBasebandDemodulator(Rxnoisy, dataBitsIn, OFDM, Chan, BS)

Nt = BS.nAntenna;
% OFDM demodulation --> Cp removal and FFT

OFDMDemod = 1/sqrt(OFDM.nfft)*fft(Rxnoisy(OFDM.cpLen+1:end, 1), OFDM.nfft);
OFDMDemod = OFDMDemod./sum(abs(Chan.CFR), 2);
dataBitsOut = qamdemod(OFDMDemod,2^OFDM.bps,'gray',OutputType='bit', UnitAveragePower=true);

%%% Noise power calculation
% noncombined = qamTx.*Chan.heff;
% noise = noncombined - CombinedRx;
% disp(pow2db(1/mean(abs(noise).^2)))
% BER calculation
% rxBits = int8(dataBitsOut);

%%% total error vector
errVecTotal=abs(dataBitsIn(:)-dataBitsOut(:));
Ber.AllCarriers = nnz(errVecTotal)/length(dataBitsIn(:));

