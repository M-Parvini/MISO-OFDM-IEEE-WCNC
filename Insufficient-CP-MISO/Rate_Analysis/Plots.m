%%% SE vs SNR plot for different delay spreads
figure
CPpercent = round(100*CP/(CPMax+1024), 1);
for cp = 1:length(CP)
    txt = ['CP = ', num2str(CPpercent(cp)), '\%'];
    Plt1(cp)=plot(SNRlistBit, mean(squeeze(Rate(1,1, cp,:,:)),2), '-', DisplayName=txt);
    hold on
end
for cp = 1:length(CP)-1
    txt = ['CP = ', num2str(CPpercent(cp)), '\%'];
    Plt1(5+cp)=plot(SNRlistBit, mean(squeeze(Rate(1,2, cp,:,:)),2), '--', DisplayName=txt);
    hold on
end
grid
box on
legend(Plt1(1:end), Interpreter='latex')
xlabel('SNR [dB]', Interpreter='latex')
ylabel('Spectral efficiency [bps/Hz]', Interpreter='latex')
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
yaxisproperties= get(gca, 'YAxis');
yaxisproperties.TickLabelInterpreter = 'latex';   % tex for y-axis

%%% SE vs Antennas plot for different CPs
%%% Rate = zeros(length(TxAntenna), length(delay_spread), length(CP), length(SNRlist), NumSim);

figure
CPpercent = round(100*CP/(CPMax+1024), 1);
for cp = 1:length(CP)
    txt = ['CP = ', num2str(CPpercent(cp)), '\%'];
    Plt1(cp)=plot(TxAntenna, mean(squeeze(Rate(:,1, cp,6,:)),2), '-', DisplayName=txt);
    hold on
end

for cp = 1:length(CP)-1
    txt = ['CP = ', num2str(CPpercent(cp)), '\%'];
    Plt1(5+cp)=plot(TxAntenna, mean(squeeze(Rate(:,2, cp,6,:)),2), '--', DisplayName=txt);
    hold on
end
grid
box on
legend(Plt1(1:end), Interpreter='latex')
xlabel('SNR [dB]', Interpreter='latex')
ylabel('Spectral efficiency [bps/Hz]', Interpreter='latex')
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
yaxisproperties= get(gca, 'YAxis');
yaxisproperties.TickLabelInterpreter = 'latex';   % tex for y-axis
