function bervec = BER_fading(bit, SINR, Divorder)
% Function for calculating the bit error rate of M-QAM
% Ref: Digital communication over fading channels, Authors: Marvin K Simon,
% Mohamed-Slim Alouini.

%% single channel reception
% M = 2^bit;
% bervec = zeros(1, length(SINR));
% coeff = (sqrt(M)-1)/(sqrt(M));
% for i=1:length(SINR)
%     SNR = SINR(i);
%     ber = 2*coeff*(1-sqrt((1.5*SNR)/(M-1+1.5*SNR)))-coeff^2*...
%         (1-sqrt((1.5*SNR)/(M-1+1.5*SNR))*((4/pi)* ...
%         atan(sqrt((M-1+1.5*SNR)/(1.5*SNR)))));
%     bervec(1,i) = ber/bit;
% end

%% Matlab BER-fading Analogous
bervec = zeros(1, length(SINR));
for i=1:length(SINR)
    SINR_s = SINR(i);
    SINR_b = SINR_s/bit;
    bervec(1,i) = ber_cal(SINR_b, bit, Divorder);
end
end

function BER = ber_cal(SINR_b, bit, Divorder)
    M = 2^bit;

    switch bit
        case 1
            BER = berfading(10*log10(SINR_b), 'psk', M, Divorder);
        otherwise
            BER = berfading(10*log10(SINR_b), 'qam', M, Divorder);
    end
end



