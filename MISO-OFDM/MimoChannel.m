function [pathGains, mimoChannelObj] = MimoChannel(Chan, OFDM, BS, UE)
Fs = OFDM.BW;
pdpDelay = Chan.pathDelays;
pdpPowDb = Chan.pathGains;
Nt = BS.nAntenna;
Nr = UE.nAntenna;
% 
% %%% Re-alignment
% % align channel taps to sampling grid
% tapDelayVec=[0:ceil(1e-5+pdpDelay(end)*Fs)]/Fs;
% pdpPowLin=10.^(pdpPowDb/10);
% activeTap=0;
% 
% %     pdpDelayAligned=zeros(1,length(pdpDelay));
% %     pdpPowAligned=zeros(1,length(pdpPowDb));
% idxAligned=zeros(1,length(tapDelayVec)-1);
% 
% for tapIndex=1:length(tapDelayVec)-1
%   ind=find((pdpDelay>=tapDelayVec(tapIndex) & pdpDelay<tapDelayVec(tapIndex+1))==1);
%   if ~isempty(ind)
%     activeTap=activeTap+1;
%     pdpDelayAligned(activeTap)=tapDelayVec(tapIndex);
%     pdpPowAligned(activeTap)=sum(pdpPowLin(ind));
%     idxAligned(:,tapIndex)=tapIndex;
%   end
% end
% pdpPowDbAligned=10*log10(pdpPowAligned);
% 
% %%%
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