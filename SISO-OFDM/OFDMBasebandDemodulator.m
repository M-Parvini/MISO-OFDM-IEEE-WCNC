function [Ber, OFDMDemod] = ...
    OFDMBasebandDemodulator(Rxnoisy, dataBitsIn, OFDM, Chan, BS)

Nt = BS.nAntenna;
% OFDM demodulation --> Cp removal and FFT

OFDMDemod = 1/sqrt(OFDM.nfft)*fft(Rxnoisy(OFDM.cpLen+1:end, 1), OFDM.nfft);
OFDMDemod = OFDMDemod./Chan.CFR;
dataBitsOut = qamdemod(OFDMDemod,2^OFDM.bps,'gray',OutputType='bit', UnitAveragePower=true);

%%% total error vector
errVecTotal=abs(dataBitsIn(:)-dataBitsOut(:));
Ber.AllCarriers = nnz(errVecTotal)/length(dataBitsIn(:));

