function Powers = Insufficient_CP_ISI_Useful_Powers(OFDM, Chan, BS, UE)

% Written function for calculating the useful power and ISI

% Initial parameters
R_k = db2pow(Chan.pathGains);
L = length(R_k);
N = OFDM.nfft;
M = OFDM.cpLen;
alpha = (N+M-L)/N;
Nt = BS.nAntenna;

% separating the powers
if M>=length(R_k)
    R_k = [R_k, zeros(1, M+1-length(R_k))]; % zero padding
end
H_1 = R_k(1:M+1);
H_2 = R_k(M+2:end);
if isempty(H_2)
    H_2 = 0;
end

% common part of useful and interference power
Comm_power_isi = triu(repmat(H_2, [L-(M+1), 1]));
Comm_power_useful = tril(repmat(H_2, [L-(M+1), 1]));

Comm_power_isi = sum(Comm_power_isi(:));
Comm_power_useful = sum(Comm_power_useful(:));


% Exact power calculations [P_U and P_ISI in paper] [No approaximation]
P_1 = sum(H_1);
P_2 = alpha^2*sum(H_2);
P_3 = (1/N^2)*Comm_power_useful;
P_4 = (2*alpha/N)*Comm_power_useful;
P_ISI = (1/N)*Comm_power_isi;

% summation of the powers [exact, upper bound, lower bound]
% Nt=1;
Powers.P_Useful = 1/Nt*(P_1 + P_2 + P_3 + P_4);
Powers.P_Interference = 1/Nt*P_ISI;

