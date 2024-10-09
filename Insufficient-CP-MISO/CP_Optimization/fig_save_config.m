%% adjust figure size
set(0,'DefaultAxesFontSize',8); %Eight point Times is suitable typeface for an IEEE paper. Same as figure caption size
set(0,'DefaultFigureColor','w')
set(0,'defaulttextinterpreter','tex') %Allows us to use LaTeX maths notation
set(0, 'DefaultAxesFontName', 'times');
% figure  %Let's make a simple time series plot of notional data
set(gcf, 'Units','centimeters')
%Set figure total dimension
set(gcf, 'Position',[0 0 8.89 6]) %Absolute print dimensions of figure. 8.89cm is essential here as it is the linewidth of a column in IEEE format
%Height can be adusted as suits, but try and be consistent amongst figures for neatness
%[pos_from_left, pos_from_bottom, fig_width, fig_height]

%% pdf conversion (1)
set(gcf,'Units','inches');
screenposition = get(gcf,'Position');
set(gcf,...
    'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize',[screenposition(3:4)]);
print -dpdf -painters figname

%% pdf conversion (2)
ax = gca;
exportgraphics(ax,'aa.pdf','Resolution',1200)