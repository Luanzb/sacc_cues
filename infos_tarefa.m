
sca; close all; clear;
PsychDefaultSetup(2);
  

infos = struct;

[participant] = inputsubject;

ResponsePixx('Close');

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

infos.ntrials              = 100; % n�mero de tentativas
infos.screen_num           = 0;

% infos.pausas               = (100:100:900); % 5 pausas em uma sessão 
% infos.pausas2              = (101:100:901);% 
infos.pausas               = (10:10:90); % 5 pausas em uma sessão 
infos.pausas2              = (11:10:91);% 

infos.time                 = [0.025  0.5  1  0  0.0167]; 
infos.fix_dur_t            = 0.5;  % Duration of fixation at ROI to start trial in secs
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
dva3     = 0.5;      % tam da pista
dva4     = 8;         % excentricidade do alvo em relação ao ponto de fixação.
dva5     = 2; %2.5;       % excent. dos pholders em relação ao centro do eixo y.
dva6     = 0.6;       % ponto de fixacao externo em preto
dva7     = 6; %5.5;        % excent. placeholder mais perto
dva8     = 10; %10.5;       % excent. placeholder mais distante
[a1]     = dva2pix(dist, width,  res,  dva);
[a2]     = dva2pix(dist, width,  res,  dva2);
[a3]     = dva2pix(dist, width,  res,  dva3);
[a4]     = dva2pix(dist, width,  res,  dva4);
[a5]     = dva2pix(dist, height, res2, dva5);
[a6]     = dva2pix(dist, width,  res,  dva6);
[a7]     = dva2pix(dist, width,  res,  dva7);
[a8]     = dva2pix(dist, width,  res,  dva8);

infos.roi_fixwinsize_dva = 4; % Set fixation ROI
infos.roi_fixwinsize_pix = dva2pix(dist,width,res,infos.roi_fixwinsize_dva);


% define posição de apresentação dos estímulos
rectt        = [0 0 a1 a1];
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


infos.fpointcolor   = [1 0 0];           % o PF irá receber� cor vermelha.
infos.pholdercolor  = infos.black;   % infos.white/5;     % placeholders receber�o cor cinza. 
infos.dotSize       = a2;                % tam do pf e placeholders
infos.dotSize2      = a6;


infos.fpointcoord = [infos.xcenter, infos.ycenter];   % Coordenadas do pf
infos.pholdercoordL = [x3,  x3a, x3,  x3a; y2, y2, y1, y1];  % coordenadas pista lado esquerdo
infos.pholdercoordR = [x4,  x4a, x4,  x4a; y2, y2, y1, y1];  % coord pista lado direito
                    
          
%%
                  % CONF. GERAIS PARA PISTA, ALVO NOISE E SOA
%%
infos.flags    = 1;   % permite que as vari�veis abaixo sejam modificadas 
infos.filtmode = -2;  % Noise: valores negativos deixam o noise com o blur.
infos.galpha   = 0.4;   % 1 equivale a 100% opaco; 0 equivale a 100% tranparente.


mat = [...
    %pista            lado alvo     orient alvo  
   % perifsac = 1     esq = 1       45 = 1
   %                  dir = 2       315 = 2
 
          1             1             1            
          1             1             2            
          1             2             1           
          1             2             2                                           
];


   % pista            lado alvo     orient alvo  
   %                  esq = 1       45 = 1
   % perifcovert = 2  dir = 2       315 = 2
   
mat1 = [  2             1             1                       
          2             1             2                    
          2             2             1                         
          2             2             2                                   
];
% add 119 vezes a matriz mat dentro dela mesma, gerando uma sessão com 960
% tentativas.
mat          =[mat;repmat(mat,124,1)];
matrix = mat(randperm(size(mat,1)),:); % aleatoriza as linhas

mat1          =[mat1;repmat(mat1,124,1)];
matrixx = mat1(randperm(size(mat1,1)),:); % aleatoriza as linhas

infos.matrix = [matrix;matrixx];

infos.refreshR   = Screen('FrameRate',infos.screenNumber);

if infos.refreshR== 120

    infos.loops  = 168; 
    infos.nrows  = 168;
    infos.fponly = [3 4];
    
    tg_onset     = 99:3:144;       % define em q loops o alvo será apresentado 
    ordem        = randi(16,infos.ntrials,1);% cria 960 val. aleató. entre 16-1.
    
    SOAs         = zeros(infos.ntrials,1);   % vetor que sera preenchido abaixo
    offset_target = zeros(infos.ntrials,1);
    ordem2       = zeros(infos.ntrials,1);
    
    for i = 1:length(ordem)        % define inicio d apresen. do alvo por tentativa
        SOAs(i)  = tg_onset(ordem(i));
    end
    
    
    for p = 1:length(ordem)
        ordem2(p,1) = ordem(p) + 5; 
    end
    
    for z = 1:length(ordem)
        offset_target(z) = SOAs(z) + 2;
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
        cue_onset(t)  = infos.SOA(t,1)-infos.SOA(t,3);
        cue_offset(t) = cue_onset(t) + 12; % esse 12 equivale a 100 ms de apresentacao.
    end  
   
    infos.cue_onoff = [cue_onset  cue_offset];
    % infos.cue_onoff(:,1) = tempo inicial de apresentacao da pista para todas as tentativas
    % infos.cue_onoff(:,2) = tempo final de apresentacao da pista
    
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
    SOAs              = zeros(960,1); 
    for i             = 1:length(ordem)
        SOAs(i)       = tg_onset(ordem(i));
    end
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

infos.pista_esquerda = zeros(infos.ntrials,1);
infos.pista_direita  = zeros(infos.ntrials,1);
infos.Alvo           = infos.matrix(:,3);   

% target orientation
degree_targetccw = 8.09;  % counterclockwise condition | shifted to the left
degree_targetcw = 360 - degree_targetccw;  % clockwise condition | shifted to the right


% define o tipo de pista, lado e orienta��o do alvo para a respectiva
% tentativa.
for q = 1:infos.ntrials
    
    % pista periférica sac
    if infos.matrix(q,1) == 1
        infos.leftcuesize(q)  =  a2; 
        infos.rightcuesize(q) =  a2;
        
        % alvo na esquerda
        if infos.matrix(q,2) == 1
            if infos.matrix(q,3) == 1 % define orient do alvo
                 infos.orienttarget(q,1) = degree_targetccw;
                 infos.orienttarget(q,2) = 0; 
            else
                 infos.orienttarget(q,1) = degree_targetcw;
                 infos.orienttarget(q,2) = 0; 
            end  
        else %alvo na direita  
            if infos.matrix(q,3) == 1 % define orient do alvo
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = degree_targetccw; 
            else
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = degree_targetcw; 
            end
        end
   
        
    elseif infos.matrix(q,1) == 2 % pista periférica covert
        
        % pista e alvo na esquerda
        if infos.matrix(q,2) == 1
            infos.leftcuesize(q)    = a3;
            infos.rightcuesize(q)   = a2; 
            infos.pista_esquerda(q) = 1;
            
            if infos.matrix(q,3) == 1
                 infos.orienttarget(q,1) = degree_targetccw;
                 infos.orienttarget(q,2) = 0; 
            else
                 infos.orienttarget(q,1) = degree_targetcw;
                 infos.orienttarget(q,2) = 0; 
            end
        % pista e alvo na direita
        else
             infos.leftcuesize(q)   = a2;
             infos.rightcuesize(q)  = a3;
             infos.pista_direita(q) = 1;
            
           if infos.matrix(q,3) == 1
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = degree_targetccw; 
           else
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = degree_targetcw; 
           end
        end
        
   
        
    end
    

end

matrix = infos.matrix(1:600,:);

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

