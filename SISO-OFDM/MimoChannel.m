function [pathGains, mimoChannelObj] = MimoChannel(Chan, OFDM, BS, UE)
Fs = OFDM.BW;
pdpDelay = Chan.pathDelays;
pdpPowDb = Chan.pathGains;
Nt = BS.nAntenna;
Nr = UE.nAntenna;

mimoChannelObj = comm.MIMOChannel(... % MIMO Multipath Fading Channel
                    'SampleRate',Fs, ...
                    'PathDelays',pdpDelay, ...
                    'AveragePathGains',pdpPowDb, ...
                    'SpatialCorrelationSpecification','None', ...
                    'MaximumDopplerShift',0,...
                    'NumTransmitAntennas',Nt, ...
                    'NumReceiveAntennas',Nr,...
                    'PathGainsOutputPort',true,...
                    'NormalizePathGains',true,...
                    'NormalizeChannelOutputs',true);

chanIn = ones(1,Nt)+1j*ones(1,Nt);
[~,pathGains] = mimoChannelObj(chanIn); % Channel path gains


end