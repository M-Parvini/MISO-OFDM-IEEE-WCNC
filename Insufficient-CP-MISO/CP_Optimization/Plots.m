%% ber versus SNR
figure
for k=1:12:length(CP)
    txt1 = ['CP= ', num2str(CP(k))];
    semilogy(SNRlist, BerStat(k, :), 'k', 'DisplayName',txt1, 'LineWidth',1)
    hold on
end
hold off
xlabel('SNR (dB)', 'interpreter', 'latex')
ylabel('Bit error rate', 'interpreter', 'latex')
grid on
legend show

%% SINR 3D plot
figure
S = 1/S_rate*1e6;  % \mu.s
x = SNRlist;
y = CP*S;
[snr,cp] = meshgrid(x,y);
Z = SINRStat;
Z = 10*log10(Z);
mesh(snr,cp,Z);
hold on
% first contour for multi-objective
% [C,h] = contour3(snr,cp,Z,contourvecdB, 'r--', 'ShowText','on');
% clabel(C,h,'Interpreter', 'latex','FontSize', 4, 'LineWidth', 0.5, ...
%     'labelspacing', 200)
xlabel('SNR [dB]', 'interpreter', 'latex')
ylabel('CP duration [$\mu s$]', 'interpreter', 'latex')
zlabel('SINR [dB]', 'interpreter', 'latex')

%% minimum CP+SNR (Plot 1 and 2)
figure
hold on
S = 1/S_rate*1e6;  % \mu.s
% contourvecdB = round(contourvecdB);
Conv_op = zeros(2, length(contourvecdB)); % conventional OFDM design operating point
Conv_op(1,:) = contourvecdB;
Conv_op(2,:) = 100*(CP(end))/(1024+77)*ones(1, length(contourvecdB));
x = SNRlist;
% y = CP*S;
y = 100*CP/(1024+76);
[snr,cp] = meshgrid(x,y);
Z = SINRStat;
Z = 10*log10(Z);
% first contour for multi-objective
[C,h] = contour3(snr,cp,Z,[contourvecdB], 'k--', 'ShowText','off');
xlabel('SNR [dB]', 'interpreter', 'latex')
ylabel('CP overhead [$\%$]', 'interpreter', 'latex')
clabel(C,h,'Interpreter', 'latex','FontSize', 4, 'LineWidth', 0.5, ...
    'labelspacing', 1400)
grid on
% ylim([0 0.61])
xlim([30 72])
txt = 'Conv. OFDM';
p(1)=plot(Conv_op(1,:), Conv_op(2,:), 'ro--','MarkerFaceColor', 'r', 'DisplayName',txt);

txt = 'Optim. OFDM';
p(2)=plot(squeeze(optim_SE(1,:)), ...
    squeeze(optim_SE(2,:))*100/(1024+77), 'ko--', ...
    'MarkerFaceColor', 'k', 'DisplayName',txt);
hold on

X = [Conv_op(1,:),fliplr(Conv_op(1,:))];
Y = [Conv_op(2,:), fliplr(squeeze(optim_SE(2,:))*100/(1024+77))];
fill(X,Y,[0.92 0.92 0.92]);
legend(p(1:end), interpreter='latex')
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
yaxisproperties= get(gca, 'YAxis');
yaxisproperties.TickLabelInterpreter = 'latex';   % tex for y-axis
box on