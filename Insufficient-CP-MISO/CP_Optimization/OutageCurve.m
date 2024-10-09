function curves = OutageCurve(Outage_var, SINR_th, bitsPerSymb)

Outage_var = Outage_var./100;
curves = pow2db(db2pow(SINR_th)./(-1*log(1-Outage_var)));
curves = curves + 10*log10(bitsPerSymb); % Eb/N0 --> Es/N0