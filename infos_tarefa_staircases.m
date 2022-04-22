sca; close all; clear;
PsychDefaultSetup(2);

infos = struct;

[participant] = inputsubject;

%%
%                      INFORMAÇÕES SOBRE O TECLADO
%%
KbName('UnifyKeyNames');
infos.escapeKey = KbName('ESCAPE');
infos.leftKey   = KbName('LeftArrow');
infos.rightKey  = KbName('RightArrow');
infos.s         = KbName('S');
infos.n         = KbName('N');

%%
%                     CONFIGURAÇÕES GERAIS DA TELA
%%

Screen('Preference', 'SkipSyncTests', 1); % 
Screen('Preference', 'TextRenderer');
Screen('Preference', 'Verbosity', 0);

infos.ntrials              = 640; % n�mero de tentativas
infos.screen_num           = 0;
infos.pausas               = (160:160:800); % 5 pausas em uma sessão (5:5:25);%
infos.pausas2              = (161:160:801);  % (6:5:26);%
infos.time                 = [0.025  0.5  1  0  0.0167]; 
infos.fix_dur_t            = 0.3;  % Duration of fixation at ROI to start trial in secs
infos.screenNumber         = max(Screen('Screens'));
infos.white                = WhiteIndex(infos.screenNumber);
infos.black                = BlackIndex(infos.screenNumber);
infos.grey                 = infos.white / 2;
[infos.width,infos.height] = Screen('DisplaySize', infos.screenNumber);
[infos.win, infos.rect]    = PsychImaging('OpenWindow',infos.screenNumber,...
                             infos.grey,[],32,2,[],[]);%, kPsychNeed32BPCFloat);
infos.ifi                  = Screen('GetFlipInterval', infos.win);

Screen('TextFont', infos.win, 'Times');
Screen('TextSize', infos.win, 30); 

% as vari�veis em conchetes receber�o a coordenada do centro do eixo x e y
% da tela, respectivamente.
[infos.xcenter, infos.ycenter] = RectCenter(infos.rect);

Priority(MaxPriority(infos.win));
%%
      % CONFIG. GERAIS E COORDENADAS PARA FP, PLACEHOLDERS E PISTA
%%

% define tamanho dos estímulos
dist     = 57; % cm da tela
width    = infos.width / 10;
height   = infos.height / 10;
res      = infos.rect(3);
res2     = infos.rect(4);
dva      = 2.2;       % tam do gabor/noise
dva2     = 0.3;       % tam do ponto de fixação e placeholders
dva3     = 0.63;      % tam da pista
dva4     = 8;         % excentricidade do alvo em relação ao ponto de fixação.
dva5     = 2.5;       % excent. dos pholders em relação ao centro do eixo y.
dva6     = 0.6;       % ponto de fixacao externo em preto
[a1]     = dva2pix(dist, width,  res,  dva);
[a2]     = dva2pix(dist, width,  res,  dva2);
[a3]     = dva2pix(dist, width,  res,  dva3);
[a4]     = dva2pix(dist, width,  res,  dva4);
[a5]     = dva2pix(dist, height, res2, dva5);
[a6]     = dva2pix(dist, width,  res,  dva6);


infos.roi_fixwinsize_dva = 4; % Set fixation ROI
infos.roi_fixwinsize_pix = dva2pix(dist,width,res,infos.roi_fixwinsize_dva);


% define posição de apresentação dos estímulos
rectt        = [0 0 a1 a1];
x            = infos.xcenter - a4;
x2           = infos.xcenter + a4;
y            = infos.ycenter;
y1           = infos.ycenter - a5;
y2           = infos.ycenter + a5;
infos.coordL = CenterRectOnPoint(rectt,x,y);   % posição gabor/noise na esquerda
infos.coordR = CenterRectOnPoint(rectt,x2,y);  % pos gabor/noise direita


infos.fpointcolor   = [1 0 0];           % o PF irá receber� cor vermelha.
infos.pholdercolor  = infos.black;   % infos.white/5;     % placeholders receber�o cor cinza. 
infos.dotSize       = a2;                % tam do pf e placeholders
infos.dotSize2      = a6;


infos.fpointcoord   = [infos.xcenter,...
                       infos.ycenter];   % Coordenadas do pf.
infos.pholdercoord  = [x,  x,  x2, x2 
                       y2, y1, y2, y1];  % coord placeholders.
infos.pholdercoordL = [x,  x;  y2, y1];  % coordenadas pista lado esquerdo
infos.pholdercoordR = [x2, x2; y2, y1];  % coord pista lado direito
                    
          
%%
                  % CONF. GERAIS PARA PISTA, ALVO NOISE E SOA
%%
infos.flags    = 1;   % permite que as vari�veis abaixo sejam modificadas 
infos.filtmode = -2;  % Noise: valores negativos deixam o noise com o blur.
infos.galpha   = 1;   % 1 equivale a 100% opaco; 0 equivale a 100% tranparente.

mat = [...
     %pista          lado alvo     orient alvo  
     %central = 1    esq = 1       45 = 1
     %perif = 2     dir = 2       315 = 2
          1             1             1            
          1             1             2            
          1             2             1           
          1             2             2                  
        
          2             1             1                       
          2             1             2                    
          2             2             1                         
          2             2             2                                   
];

% add 119 vezes a matriz mat dentro dela mesma, gerando uma sessão com 960
% tentativas.
mat          =[mat;repmat(mat,119,1)];
infos.matrix = mat(randperm(size(mat,1)),:); % aleatoriza as linhas

cont  = 0;
cont2 = 0;

for ww = 1:6
    cont = cont + 1;
    if rem(cont,2) == 1
        
        for w = 1:160
            cont2 = cont2 + 1;
            infos.matrix(cont2,1) = 1; % pista central
        end
    else
        for w = 1:160
            cont2 = cont2 + 1;
            infos.matrix(cont2,1) = 2; % pista periferica
        end
    end
    
end

infos.refreshR   = Screen('FrameRate',infos.screenNumber);

if infos.refreshR == 120

    infos.loops  = 168; 
    infos.nrows  = 168;
    infos.fponly = [3 4];
    
    tg_onset     = 129:3:144;       % define em q loops o alvo será apresentado 
    ordem        = randi(6,960,1);  % cria 960 val. aleató. entre 16-1.
    SOAs         = zeros(960,1);    % vetor que sera preenchido abaixo
    offset_target = zeros(960,1);
    ordem2       = zeros(960,1);
    
    for i = 1:length(ordem)        % define inicio d apresen. do alvo por tentativa
        SOAs(i)  = tg_onset(ordem(i));
    end
    
    for p = 1:length(ordem)
        ordem2(p,1) = ordem(p) + 2; 
    end
    
    for z = 1:length(ordem)
        offset_target(z) = SOAs(z) + 2;
    end
    
    infos.SOA    = [SOAs  ordem  ordem2 offset_target];  % essa matriz contem a ordem de inicio 
                                           % de apresentacao do alvo por tentativa 
                                           % (coluna da esquerda) e o valor que devera
                                           % ser subtraido para definir o momento de 
                                           % apresentacao da pista (coluna
                                           % 3). Coluna 4 demarca o final
                                           % de apresentacao do alvo.
            
    
    % essas variaveis receberao o tempo de apresentacao inicial e final da
    % pista. ver loop abaixo.
    cue_onset      = zeros(960,1);
    cue_offset     = zeros(960,1);
    
    for t = 1:length(ordem)
        cue_onset(t)  = infos.SOA(t,1)-infos.SOA(t,3);
        cue_offset(t) = cue_onset(t) + 12; % esse 12 equivale a 100 ms de apresentacao.
    end  
    % matriz contendo o tempo inicial e final de apresentacao da pista para
    % todas as tentativas de uma sessao
    infos.cue_onoff = [cue_onset  cue_offset];
    
    % variável abaixo receberá o número do loop inicial de apresentação do gap
    % em cada tentativa.
    infos.startgap = zeros(960,1);
    for w = 1:length(ordem)
        infos.startgap(w) = infos.cue_onoff(w,1) - 24; 
    end    
    
    ng = [1,1,1,0,0,0]';
    infos.show_noise_gabor = [ng;repmat(ng,27,1)];
   
else
    
    infos.loops       = 84; 
    infos.nrows       = 84; 
    infos.fponly      = [1 2];
        
    tg_onset          = 51:3:72; 
    ordem             = randi(8,960,1);      
    SOAs              = tg_onset(ordem);  %zeros(960,1); 
%     for i             = 1:length(ordem)
%         SOAs(i)       = tg_onset(ordem(i));
%     end
    infos.SOA         = [SOAs  ordem];      
       
    cue_onset         = zeros(960,1);
    cue_offset        = zeros(960,1);
    for t             = 1:length(ordem)
        cue_onset(t)  = infos.SOA(t,1)-infos.SOA(t,2);
        cue_offset(t) = cue_onset(t) + 6;
    end  
    infos.cue_onoff   = [cue_onset  cue_offset];
    
    infos.startgap    = zeros(960,1);
    for w             = 1:length(ordem)
        infos.startgap(w) = infos.cue_onoff(w,1) - 12; 
    end
    
    ng = [1,0]';
    infos.show_noise_gabor = [ng;repmat(ng,41,1)];
    
end

infos.orientation    = [0 0]; % orienta��o dos gabores
infos.orienttarget   = [];    % recebe a orienta��o do gabor padrao e do 
                              % que ser� o alvo.
infos.leftcuesize    = [];
infos.rightcuesize   = [];

infos.pista_neutra   = zeros(960,1);
infos.pista_esquerda = zeros(960,1);
infos.pista_direita  = zeros(960,1);
infos.Alvo           = infos.matrix(:,3);   

% define o tipo de pista, lado e orienta��o do alvo para a respectiva
% tentativa.
for q = 1:infos.ntrials
    
    % pista central
    if infos.matrix(q,1) == 1
        infos.leftcuesize(q)  =  a2;  % a3;
        infos.rightcuesize(q) =  a2;  % a3;
        infos.pista_neutra(q) = 1;
        
        % alvo na esquerda
        if infos.matrix(q,2) == 1
            if infos.matrix(q,3) == 1 % define orient do alvo
                 infos.orienttarget(q,1) = 7; % 45;
                 infos.orienttarget(q,2) = 0; 
            else
                 infos.orienttarget(q,1) = 353;   % 315;
                 infos.orienttarget(q,2) = 0; 
            end  
        else %alvo na direita  
            if infos.matrix(q,3) == 1 % define orient do alvo
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) =  7;  % 45; 
            else
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = 353;  % 315; 
            end
        end
     
    else % pista perif�rica    
        
        % pista e alvo na esquerda
        if infos.matrix(q,2) == 1
            infos.leftcuesize(q)    = a3;
            infos.rightcuesize(q)   = a2; 
            infos.pista_esquerda(q) = 1;
            
            if infos.matrix(q,3) == 1
                 infos.orienttarget(q,1) = 7;  %45;
                 infos.orienttarget(q,2) = 0; 
            else
                 infos.orienttarget(q,1) = 353;  % 315;
                 infos.orienttarget(q,2) = 0; 
            end
        % pista e alvo na direita
        else
             infos.leftcuesize(q)   = a2;
             infos.rightcuesize(q)  = a3;
             infos.pista_direita(q) = 1;
            
           if infos.matrix(q,3) == 1
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = 7;  % 45; 
           else
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = 353;  % 315; 
           end
        end    
    end  
end

matrix = infos.matrix(1:640,:);

%% staircase info

infos.ntrials_staircase = 50;

infos.UD_step_size_down = 1;       
infos.UD_step_size_up = 1;
infos.UD_stop_criterion = 'trials';   
infos.UD_stop_rule = infos.ntrials_staircase;
infos.UD_start_value = 45;
infos.UD_xmax = 90;
infod.UD_xmin = 0;

grain = 241;
infos.PEST_prior_alpha_range = linspace(infos.UD_xmix,infos.UD_xmax,grain);
infos.PEST_PF = @PAL_Logistic;
infos.PEST_xmax = infos.UD_xmax;
infos.PEST_xmin = infos.UD_xmix;
infos.PEST_mean_mode = 'mean';
infos.PEST_beta = 2;
infos.PEST_gamma = 0.5;
infos.PEST_lambda = 0.02;
infos.PEST_stop_criterion = 'trials';   
infos.PEST_stop_rule = infos.ntrials_staircase;

infos.PSI_prior_alpha_range = linspace(infos.UD_xmix,infos.UD_xmax,grain);
infos.PSI_prior_beta_range = 2;
infos.PSI_prior_gamma = 0.5;
infos.PSI_prior_lambda = 0.02;
infos.PSI_stop_rule = infos.ntrials_staircase;
infos.PSI_PF = @PAL_Logistic;
infos.PSI_stim_range = linspace(infos.UD_xmix,infos.UD_xmax,grain);
infos.PSI_marginalize = [-1 -2 -3 -4];   % marginal parameters (1: threshold, 2: slope, 3: guess, 4: lapse) 
                
c1 = repmat([1 1 a2 1],infos.ntrials_staircase,1);
c2 = repmat([2 1 a2 2],infos.ntrials_staircase,1);                
c3 = repmat([3 2 a3 1],infos.ntrials_staircase,1);
c4 = repmat([4 2 a3 2],infos.ntrials_staircase,1);
infos.trials = [c1; c2; c3; c4];

%(:,1) = condition number
%(:,2) = type of cue (1=central; 2=peri)
%(:,3) = size of cue (1=central size; 2=peri size)
%(:,4) = direction of target orientation (1=clockwise;2=counterclock)

%%
[g]           = gabor(infos);
[aperture]    = FastMaskedNoiseDemo(infos, g);
[disctexture] = disc(infos);
[timestamps,Response]    = exp_cues(g,infos, aperture, disctexture, participant);

participant.eyefilename = 'express.edf'; 
participant.filename = sprintf('Sacc_sub%s_ses%s_%s',participant.strnum,participant.strses,datestr(now,'yyyymmdd-HHMM'));       
disp('Saving data files........')
save(fullfile(sprintf('/mnt/projetos/sacc_cues/data/Subject%s/',participant.strnum),...
    [participant.filename,'.mat']),'participant','Response','timestamps', 'matrix');


        
   if exist(participant.eyefilename,'file')
         movefile(participant.eyefilename,sprintf('/mnt/projetos/sacc_cues/data/Subject%s/eyetracking/%s.edf',participant.strnum,participant.filename));
   else
         error('Eye-tracker data file not found!');
   end
        
disp('All done!');

