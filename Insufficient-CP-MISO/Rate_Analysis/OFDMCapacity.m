function Rate = OFDMCapacity(OFDM, qamTx, eqSym)

Ncp = OFDM.cpLen;
N = OFDM.nfft;

%%% Noise + ISI power
PISI = abs(qamTx-eqSym).^2;
PUseful = abs(eqSym).^2;

RatePerSymbol = log2(1+PUseful./PISI);
Rate = (1/(N+Ncp))*sum(RatePerSymbol);