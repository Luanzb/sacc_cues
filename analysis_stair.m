%% load data




%% staircases info

condition = 1;
UD_ndown = 1;
UD_xmax = 30;
UD_xmin = 0;
PSI_prior_gamma = 0.5;
PSI_prior_lambda = 0.02;
PSI_PF = @PAL_Logistic;
PSI_stim_range = linspace(UD_xmin,UD_xmax,241);

%% up/down

t = 1:length(AM(condition).x);
title(sprintf('1-Up/%i-Down Staircase',UD_ndown))
plot(t,AM(condition).x,'k');
hold on;
plot(t(AM(condition).response == 1),AM(condition).x(AM(condition).response == 1),'ko', 'MarkeAM(condition)aceColor','k');
plot(t(AM(condition).response == 0),AM(condition).x(AM(condition).response == 0),'ko', 'MarkeAM(condition)aceColor','w');
set(gca,'FontSize',16);
axis([0 max(t)+1 min(AM(condition).x)-(max(AM(condition).x)-min(AM(condition).x))/10 max(AM(condition).x)+(max(AM(condition).x)-min(AM(condition).x))/10]);
xlabel('Trial');
ylabel('Orientation');

thresh_pc = nthroot(0.5, UD_ndown)*100;
thresh_ori = PAL_AMUD_analyzeUD(AM(condition), 'reversals', max(AM(condition).reversal)-3);
thresh_txt = sprintf('thresh %i = %0.2f', thresh_pc, thresh_ori);
text(max(t)-15, thresh_ori-2, thresh_txt);
refline(0, thresh_ori);

fprintf('\n%i threshold as mean of all but last three reversals: %0.2f\n', thresh_pc, thresh_ori);

%% pest

t = 1:length(AM(condition).x);
title('PEST Staircase');
plot(t,AM(condition).x,'k');
hold on;
plot(t(AM(condition).response == 1),AM(condition).x(AM(condition).response == 1),'ko', 'MarkerFaceColor','k');
plot(t(AM(condition).response == 0),AM(condition).x(AM(condition).response == 0),'ko', 'MarkerFaceColor','w');
set(gca,'FontSize',16);
axis([0 max(t)+1 min(AM(condition).x)-(max(AM(condition).x)-min(AM(condition).x))/10 ...
    max(AM(condition).x)+(max(AM(condition).x)-min(AM(condition).x))/10]);
xlabel('Trial');
ylabel('Orientation');

thresh_mean = AM(condition).mean;
thresh_mode = AM(condition).mode;
thresh_sd = AM(condition).sd;

thresh_txt = sprintf('thresh mean = %0.2f', thresh_mean);
text(max(t)-15, thresh_mean-2, thresh_txt);
refline(0, thresh_mean);

fprintf('\rThreshold estimate as mode of posterior: %6.4f',thresh_mode);
fprintf('Threshold estimate as mean of posterior: %6.4f',thresh_mean);
fprintf('Threshold standard error as sd of posterior: %6.4f',thresh_sd);

% message = sprintf('\rThreshold estimate as mode of posterior using unifo');
% message = strcat(message,sprintf('rm prior (i.e., ML estimate): %6.4f' ,AM(condition).modeUniformPrior));
% disp(message);
% message = sprintf('Threshold estimate as mean of posterior using unifo');
% message = strcat(message,sprintf('rm prior: %6.4f' , AM(condition).meanUniformPrior));
% disp(message);
% message = sprintf('Threshold standard error as sd of posterior using uni');
% message = strcat(message,sprintf('form prior: %6.4f' , AM(condition).sdUniformPrior));
% disp(message);

%% psi

ntrials = length(AM(condition).response);
x = AM(condition).x(1:ntrials); 
threshold = AM(condition).threshold(1:ntrials);
se = AM(condition).seThreshold(1:ntrials);
response = AM(condition).response(1:ntrials);
slope = AM(condition).slope(1:ntrials);
slope_fit = 10.^AM(condition).slope(end);
prior_alpha_range = AM(condition).priorAlphaRange;
prior_beta_range = AM(condition).priorBetaRange; 

%%% plot staircase
subplot(4,1,1);
set(gcf,'Units','Normalized','OuterPosition', [0, 0.04, 1, 0.96])
t = 1:length(AM(condition).x);
plot(t, AM(condition).x, 'k');
hold on;
errorbar(t(1:ntrials), threshold, se, '-', 'color',	[0 .7 .7]);
plot(t,AM(condition).x, '-', 'color', [0 .5 .5]);
plot(t(response == 1), x(response == 1), 'o', 'color', [0 .5 .5], 'MarkerFaceColor', [0 .7 .7]);
plot(t(response == 0), x(response == 0), 'o', 'color', [0 .5 .5], 'MarkerFaceColor', 'w');
axis square
xlabel('Tentativa')
ylabel('Orientação')

x_lim = [0 ntrials];
y_lim = [min(PSI_stim_range) max(PSI_stim_range)];
SW = [min(x_lim) min(y_lim)]+[diff(x_lim) diff(y_lim)]*0.05;
xlim(x_lim)
ylim(y_lim)
xticks(0:10:ntrials)
yticks(y_lim(1):5:y_lim(2))
error = se(end);
error_txt = sprintf('Erro (fim) = %0.2f', error);
text(SW(1), SW(2), error_txt);
refline([0 threshold(end)])
line(x_lim, [threshold(end) threshold(end)],'linewidth', 2, 'linestyle', ':', 'color','k');

unique_levels = unique(x);
mean_resp = [1,length(unique_levels)];
n_times = [1,length(unique_levels)];
for i = 1:numel(unique_levels)
    mean_resp(i) = mean(response(x == unique_levels(i)));
    n_times(i) = sum(x == unique_levels(i));
end

%%% plot scatter
subplot(4,1,2);
scatter(unique_levels, mean_resp*100, n_times*10, [0 .5 .5]);
axis square
xlabel('Orientação')
ylabel('Respostas corretas (%)');  

y_lim = [0 100];
x_lim = [min(PSI_stim_range) max(PSI_stim_range)];
ylim(y_lim)
xlim(x_lim)
yticks(0:10:100)
xticks(x_lim(1):5:x_lim(2))
line(x_lim, [50 50],'linewidth', 1, 'linestyle', ':', 'color','k');

%%% plot fit
subplot(4,1,3);
fit = PSI_PF([threshold(end) slope_fit PSI_prior_gamma PSI_prior_lambda], PSI_stim_range);
plot(PSI_stim_range, fit, 'color', [0 .5 .5], 'linewidth',2)
axis square
xlabel('Orientação')
ylabel('Probabilidade detecção (%)');  

x_lim = [min(PSI_stim_range) max(PSI_stim_range)];
y_lim = [0.5 1];
SW = [min(x_lim) min(y_lim)]+[diff(x_lim) diff(y_lim)]*0.05;
NW = [min(x_lim) max(y_lim)]+[diff(x_lim) -diff(y_lim)]*0.05;
xlim(x_lim)
ylim(y_lim)
yticks(0.5:0.1:1)
xticks(x_lim(1):2:x_lim(2))
txt_alpha = sprintf('alfa = %0.2f',threshold(end));
text(NW(1), NW(2), txt_alpha);
txt_slope = sprintf('beta = %0.2f',slope(end));
text(SW(1), SW(2), txt_slope);
[fit, index] = unique(fit);
% thresh80 = interp1(fit, PSI_stim_range(index),0.80);
% txt_thresh80 = sprintf('x80 = %0.2f', thresh80);
% text(SW(1), 0.85, txt_thresh80);
% line(x_lim, [0.8 0.8],'linewidth', 1, 'linestyle', ':', 'color','k');

%%% plot pdf
subplot(4,1,4);
image(prior_beta_range, prior_alpha_range, PAL_Scale0to1(AM(condition).pdf)*64);
axis square
xlabel('Beta');
ylabel('Alfa');

[Dev, pDev, DevSim, converged] = PAL_PFML_GoodnessOfFit(unique_levels, mean_resp.*n_times, n_times, ...
    [threshold(end) 10.^slope(end) PSI_prior_gamma PSI_prior_lambda], [1 1 0 0], 100, PSI_PF);

fit_dev = [Dev pDev];
fit_devsim = DevSim
fit_conv = converged

fprintf('\nThreshold estimate: %6.4f',threshold(end));
fprintf('\nThreshold standard error: %6.4f',error);
fprintf('\nDev pDev: %6.4f %6.4f\n',fit_dev(1), fit_dev(2));

% save(sprintf('/mnt/projetos/fovea/data/S%i/staircase/psidata_%s', participant.isub, participant.filename), 'psidata');
% saveas(gcf, sprintf('/mnt/projetos/fovea/data/S%i/staircase/psidata_%s', participant.isub, participant.filename), 'fig');
%     saveas(gcf, 'C:\Users\Gabi\Desktop\psidata.png');
