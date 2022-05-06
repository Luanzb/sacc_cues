
% PF = @PAL_CumulativeNormal;
% PF = @PAL_Logistic;
% PF = @PAL_Weibull;
PF = @PAL_Gumbel;
% PF = @PAL_Quick;
% PF = @PAL_logQuick;
% PF = @PAL_HyperbolicSecant;

slope = 1 % slope "real" da PF
logslope = log10(slope)     % slope pro prior do psi

% thresh = 5;
% range = 1:1:45;

thresh = 0.05;
range = 0:.005:.1;

guess = 0.5;
lapse = 0.02;

fit = PF([thresh slope guess lapse], range);
plot(range, fit, 'color', [0 .5 .5], 'linewidth',2)

%%%% mudar pra gumbel
%%%% usar algo tipo linspace(log10(0.02), log10(0.4), grain)

%%%% testar deixar a slope como parametro marginal