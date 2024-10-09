function [Results_OP] = ...
CP_Optimization(SNRbit, CP_max, OFDMparams, contourvecdB, tau)
% Function to evaluate the minimum required CP + SNR value 
% Alpha --> Bisection variables
% Results_OP --> final results. First dimension represents respectively,
% the optimum CP length, SNR, weights sum of CP and SNR, and the SINR
% values.

%%% weights of the optimization problem
w1=0.5;
w2=1-w1;

%%% Optimization variables
N = OFDMparams.nfft;
M_max = CP_max;
contourvec = db2pow(contourvecdB);
Results_OP = zeros(4, length(contourvec));

n=1;
for i=1:length(contourvec)
    %%% Bisection variables
    alpha1 = 0.1;
    alpha2 = 1;
    while abs(alpha2-alpha1)>=0.01
        %%% Weighted sum method for solving Multi-objective optimization probelm
        % optimization problem start
        alphaprime = (alpha1+alpha2)/2;
        
        cvx_begin
        variables M S
        gamma_th = contourvec(i);
    
        maxsnr = contourvecdB(i) + alphaprime;
        maxtapnum = CP_max;  
        L=CP_max;
    
        %% ISI power from Euler-Mac approximation
        P_ISI = 1/N*((tau+1+1/(2*tau))*exp(-(M+1)/tau)+...
                    (M+1-L-tau+(L-M-1)/(2*tau))*exp(-(L-1)/tau));
    
        %%% optimization problem
        minimize w1*M+w2*S
        subject to 
            -1+P_ISI*(gamma_th+1)+gamma_th*inv_pos(10^(S/10)) <= 0;
             S(n) <= maxsnr;
            -S(n) <= -1;   % to avoid making the inv_pos to infinity!
             M(n) <= maxtapnum;
            -M(n) <= -1;
        cvx_end
    
        %%% Saving the results
        slack_out = feasibility(N, M_max, M);
        if slack_out>=alphaprime
            alpha1=alphaprime;
        else
            alpha2=alphaprime;
        end
    end
    Results_OP(1, i) = S;
    Results_OP(2, i) = M;
    Results_OP(3, i) = w1*M/CP_max+w2*S/SNRbit(end);
    Results_OP(4, i) = pow2db((1-P_ISI)/(P_ISI+1/(10^(S/10))));
end
end
function slack_out = feasibility(N, M_max, M)
    
    slack_out = 10*log10(N+M_max)-10*log10(N+M);

end