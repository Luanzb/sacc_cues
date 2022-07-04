sca; close all; clear;
PsychDefaultSetup(2);

% cd /mnt/projetos/
cd /home/activis/Documents/GitHub/sacc_cues/
addpath(genpath('/home/activis/Documents/GitHub/sacc_cues/'))   
addpath(genpath('/home/activis/Documents/MATLAB/'))   

infos = struct;
participant = inputsubject;

ResponsePixx('Close');

%% CONFIGURAÇÕES GERAIS

Screen('Preference', 'SkipSyncTests', 1); % 
Screen('Preference', 'TextRenderer');
Screen('Preference', 'Verbosity', 0);

infos.ntrials = 60;
infos.pausas = (160:160:800); % pausas em uma sessão
infos.pausas2 = (161:160:801);
infos.fix_dur_t = 0.3;  % Duration of fixation at ROI to start trial in secs

infos.screenNumber = max(Screen('Screens'));
infos.white = WhiteIndex(infos.screenNumber);
infos.black = BlackIndex(infos.screenNumber);
infos.grey = infos.white / 2;
[infos.width,infos.height] = Screen('DisplaySize', infos.screenNumber);

[infos.win, infos.rect] = PsychImaging('OpenWindow', infos.screenNumber, infos.grey,[],32,2,[],[]);
infos.ifi = Screen('GetFlipInterval', infos.win);
[infos.xcenter, infos.ycenter] = RectCenter(infos.rect);
Screen('TextFont', infos.win, 'Times');
Screen('TextSize', infos.win, 30); 
Priority(MaxPriority(infos.win));

%% STIM SIZE AND LOCATION
    
% define tamanho dos estímulos
dist = 57; % cm da tela
width = infos.width / 10;
height = infos.height / 10;
res = infos.rect(3);
res2 = infos.rect(4);
dva = 2.2;        % tam do gabor/noise
dva2 = 0.3;       % tam do ponto de fixação e placeholders
dva3 = 0.5;      % tam da pista
dva4 = 8;         % excentricidade do alvo em relação ao ponto de fixação.
dva5 = 2; %2.5;       % excent. dos pholders em relação ao centro do eixo y.
dva6 = 0.6;       % ponto de fixacao externo em preto
dva7 = 6; %5.5;        % excent. placeholder mais perto
dva8 = 10; %10.5;       % excent. placeholder mais distante
[a1] = dva2pix(dist, width,  res,  dva);
[a2] = dva2pix(dist, width,  res,  dva2);
[a3] = dva2pix(dist, width,  res,  dva3);
[a4] = dva2pix(dist, width,  res,  dva4);
[a5] = dva2pix(dist, height, res2, dva5);
[a6] = dva2pix(dist, width,  res,  dva6);
[a7] = dva2pix(dist, width,  res,  dva7);
[a8] = dva2pix(dist, width,  res,  dva8);

infos.roi_fixwinsize_dva = 4; % Set fixation ROI
infos.roi_fixwinsize_pix = dva2pix(dist,width,res,infos.roi_fixwinsize_dva);

% define posição de apresentação dos estímulos
rect_stim = [0 0 a1 a1];
x0 = infos.xcenter;
x1 = infos.xcenter - a4;
x2 = infos.xcenter + a4;
y0 = infos.ycenter;
y1 = infos.ycenter - a5;
y2 = infos.ycenter + a5;

x3  = infos.xcenter - a7; % pholder perto esquerda
x3a = infos.xcenter - a8; % pholder distante esquerda
x4  = infos.xcenter + a7; % pholder perto direita
x4a = infos.xcenter + a8; % pholder distante direita

infos.coordL = CenterRectOnPoint(rect_stim,x1,y0);   % posição gabor/noise na esquerda
infos.coordR = CenterRectOnPoint(rect_stim,x2,y0);  % pos gabor/noise direita

infos.fpointcolor = [1 0 0];           % o PF irá receber cor vermelha.
infos.pholdercolor = infos.black;       % placeholders receberao cor cinza. 
infos.dotSize = a2;                % tam do pf e placeholders
infos.dotSize2 = a6;

infos.fpointcoord = [infos.xcenter, infos.ycenter];   % Coordenadas do pf
infos.pholdercoordL = [x3,  x3a, x3,  x3a; y2, y2, y1, y1];  % coordenadas pista lado esquerdo
infos.pholdercoordR = [x4,  x4a, x4,  x4a; y2, y2, y1, y1];  % coord pista lado direito
                          
infos.flags = 1;   % permite que as variaveis abaixo sejam modificadas 
infos.filtmode = -2;  % noise: valores negativos deixam o noise com o blur
infos.galpha = 0.4; % 1;   % 1 equivale a 100% opaco; 0 equivale a 100% tranparente.

infos.orientation = [0 0]; % orientacao dos gabores

%% STIM TIMING
                                 
infos.refreshR = Screen('FrameRate',infos.screenNumber);

if infos.refreshR == 120

    infos.loops = 168; 
    infos.nrows = 168;
    infos.fponly = [3 4];
   
    tg_onset = 90:3:144;    % define em quais loops o alvo será apresentado 
    ordem = randi(19,infos.ntrials,1);  % cria valores aleatorios entre 19-1
   
    SOAs = zeros(infos.ntrials,1);
    tg_offset = zeros(infos.ntrials,1);
    ordem2 = zeros(infos.ntrials,1);
    
    for i = 1:length(ordem) 
        SOAs(i) = tg_onset(ordem(i));
    end
    
    for p = 1:length(ordem)
        ordem2(p,1) = ordem(p) + 2; 
    end
    
    for z = 1:length(ordem)
        tg_offset(z) = SOAs(z) + 2;
    end
    
    infos.SOA = [SOAs  ordem  ordem2 tg_offset];  
    % infos.SOA(:,1) = inicio de apresentacao do alvo
    % infos.SOA(:,2) = ordem de inicio de apresentacao do alvo 
    % infos.SOA(:,3) = valor que devera ser subtraido para definir o momento de 
    % apresentacao da pista
    % infos.SOA(:,4) = final de apresentacao do alvo
                
    cue_onset = zeros(infos.ntrials,1);
    cue_offset = zeros(infos.ntrials,1);
    
    for t = 1:length(ordem)
        cue_onset(t) = infos.SOA(t,1)-infos.SOA(t,3);
        cue_offset(t) = cue_onset(t) + 12; % esse 12 equivale a 100 ms de apresentacao.
    end
    
    infos.cue_onoff = [cue_onset  cue_offset];
    % infos.cue_onoff(:,1) = tempo inicial de apresentacao da pista para todas as tentativas
    % infos.cue_onoff(:,2) = tempo final de apresentacao da pista
    
    infos.startgap = zeros(infos.ntrials,1);
    for w = 1:length(ordem)
        infos.startgap(w) = infos.cue_onoff(w,1) - 24; % n do loop inicial de apresentação do gap em cada tentativa
    end    
    
    ng = [1,1,1,0,0,0]';
    infos.show_noise_gabor = [ng;repmat(ng,27,1)];   
end

% damnit = zeros(60,1);
% 
% for dd = 1:60
%    if infos.show_noise_gabor(infos.SOA(dd,1)) == 1
%        damnit(dd) = 1;
%    end
% end

%% STAIRCASES INFO

infos.UD_step_size_down = participant.step_size_down; % first staircase: 2.5 | second staircase: 1      
infos.UD_step_size_up = infos.UD_step_size_down;
infos.UD_stop_criterion = 'trials';   
infos.UD_stop_rule = infos.ntrials;
infos.UD_start_value = participant.limiar;    
infos.UD_xmax = 30;
infos.UD_xmin = 0;

grain = 200;
infos.PEST_prior_alpha_range = linspace(infos.UD_xmin,infos.UD_xmax,grain);
infos.PEST_PF = @PAL_Gumbel;
infos.PEST_xmax = infos.UD_xmax;
infos.PEST_xmin = infos.UD_xmin;
infos.PEST_mean_mode = 'mean';
infos.PEST_beta = 2;
infos.PEST_gamma = 0.5;
infos.PEST_lambda = 0.02;
infos.PEST_stop_criterion = 'trials';   
infos.PEST_stop_rule = infos.ntrials;

infos.PSI_prior_alpha_range = linspace(1,45,grain);
infos.PSI_prior_beta_range = linspace(log10(0.02),log10(0.4),grain);
infos.PSI_prior_gamma = 0.5;
infos.PSI_prior_lambda = 0.02;
infos.PSI_stop_rule = infos.ntrials;
infos.PSI_PF = @PAL_Gumbel;
infos.PSI_stim_range = 0:1:45;
infos.PSI_marginalize = [-1 -2 -3 4];   % marginal parameters (1: threshold, 2: slope, 3: guess, 4: lapse) 
                
infos.trials = repmat([[1 2 a3 1];...
                       [1 2 a3 2];...
                       [2 2 a3 1];...
                       [2 2 a3 2]],infos.ntrials/4,1);
infos.trials = infos.trials(randperm(size(infos.trials,1)),:);

%(:,1) = side of cue (1=left; 2=right)
%(:,2) = type of cue (1=central; 2=peri)
%(:,3) = size of cue (a2=central size; a3=peri size)
%(:,4) = direction of target orientation (1=clockwise;2=counterclock)

%% RUN!

[g] = gabor(infos);
[aperture] = FastMaskedNoiseDemo(infos, g);
[disctexture] = disc(infos);
[timestamps, response, AM, trls, targ] = exp_cues_stair(g, infos, aperture, disctexture, participant);

if participant.method == 1  % 1-up/1-down
    method_name = '1up1down';
elseif participant.method == 2  % 1-up/2-down
    method_name = '1up2down';
elseif participant.method == 3  % 1-up/3-down
    method_name = '1up3down';
elseif participant.method == 4  % psi
    method_name = 'psi';
elseif participant.method == 5  % pest   
    method_name = 'pest';
end

participant.eyefilename = 'express.edf'; 
participant.filename = sprintf('Sacc_cues_%s_sub%s_ses%s_%s',method_name,participant.strnum,participant.strses,datestr(now,'yyyymmdd-HHMM'));       
disp('Saving data files........')
save(fullfile(sprintf('/mnt/projetos/sacc_cues/data/Subject%s/',participant.strnum),...
    [participant.filename,'.mat']),'participant','infos','trls','response','timestamps','AM');
        
   if exist(participant.eyefilename,'file')
         movefile(participant.eyefilename,sprintf('/mnt/projetos/sacc_cues/data/Subject%s/eyetracking/%s.edf',participant.strnum,participant.filename));
   else
         error('Eye-tracker data file not found!');
   end
        
disp('All done!');

analysis_stair(participant,AM);