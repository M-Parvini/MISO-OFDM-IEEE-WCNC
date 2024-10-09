function y = reNormalize(x)
% Renormalization to 1
Powersum = sum(x);
y = (1/Powersum)*x;
% y = pow2db(y);