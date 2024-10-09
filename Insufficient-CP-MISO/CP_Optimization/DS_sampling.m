function taps = DS_sampling(DS, Samp)
% calculating the number of total channel taps required to absorb at least 
% 99 percent of the energy of the channel which is approax. 3 RMS delay
% spread

taps = DS/(1/Samp);
if taps == 0
    taps=1;
end
