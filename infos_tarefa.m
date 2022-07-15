sca; close all; clear all; clc;
PsychDefaultSetup(2); 

addpath(genpath('/mnt/projetos/sacc_cues/'))   
addpath(genpath('/home/activis/Documents/GitHub/sacc_cues/'))   
addpath(genpath('/home/activis/Documents/MATLAB/'))   
% cd /home/activis/Documents/GitHub/sacc_cues/   

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

infos.screen_num           = 0;


if participant.exp == 1
    infos.ntrials              = 960;
    infos.pausas               = (48:48:912); % 19 pausas em uma sessão 
    infos.pausas2              = (49:48:913);% 
    infos.ord                  = 5; 
    infos.ord2                 = 20;
    
else
    
    if participant.tr == false
        infos.ntrials              = 48; %48 % n�mero de tentativas
        infos.pausas               = (12:12:36); % 3 pausas em uma sessão 
        infos.pausas2                = (13:12:37);% 
        infos.ord                  = 1; 
        infos.ord2                 = 4;
    else
        infos.ntrials              = 2;   
        infos.ord                  = 1;
        infos.ord2                  = 4;
    end
    
end

                                                                                                                                                       
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

infos.coordL = CenterRectOnPoint(rectt,x1,y0);   % posição gabor/noise na esquerda
infos.coordR = CenterRectOnPoint(rectt,x2,y0);  % pos gabor/noise direita


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


mat1 = [...
    %pista            lado alvo     orient alvo  
   % perifsac = 1     esq = 1       45 = 1
   %                  dir = 2       315 = 2
          1             1             1            
          1             1             2            
          1             2             1           
          1             2             2                                           
];


mat2 = [...
    %pista            lado alvo     orient alvo  
   %                  esq = 1       45 = 1
   % perifcovert = 2  dir = 2       315 = 2
 
          2             1             1            
          2             1             2            
          2             2             1           
          2             2             2                                           
];

mat3 = [... 
   % pista            lado alvo     orient alvo  
   % centralsac = 3   esq = 1       45 = 1
   %                  dir = 2       315 = 2
   
          3             1             1                       
          3             1             2                    
          3             2             1                         
          3             2             2                                   
];

mat4 = [... 
   % pista            lado alvo     orient alvo  
   %                  esq = 1       45 = 1
   % centralcovert = 4  dir = 2       315 = 2
   
          4             1             1                       
          4             1             2                    
          4             2             1                         
          4             2             2                                   
];


if participant.exp == 1
    rows = 11;
    ll = 48;
    lk = 960;
else
    rows = 2;
    ll = 12;
    lk = 48;
end

% add 24 vezes a matriz mat dentro dela mesma, gerando uma sessão com 960
% tentativas.
mat1          =[mat1;repmat(mat1,rows,1)]; %2
matrix1 = mat1(randperm(size(mat1,1)),:); % aleatoriza as linhas

mat2          =[mat2;repmat(mat2,rows,1)];
matrix2 = mat2(randperm(size(mat2,1)),:); % aleatoriza as linhas

mat3          =[mat3;repmat(mat3,rows,1)];
matrix3 = mat3(randperm(size(mat3,1)),:); % aleatoriza as linhas

mat4          =[mat4;repmat(mat4,rows,1)];
matrix4 = mat4(randperm(size(mat4,1)),:); % aleatoriza as linhas

ordem = [1 2 3 4];
ordem_blocos1 = repelem(ordem,infos.ord)';
ordem_blocos = ordem_blocos1(randperm(size(ordem_blocos1,1)),:);


linha = 1;
linhaa = ll; 

infos.matrix = zeros(lk,3); 

for blocos = 1:infos.ord2
    
        
        if     ordem_blocos(blocos) == 1
                infos.matrix(linha:linhaa,:) = matrix1;
        elseif ordem_blocos(blocos) == 2
                infos.matrix(linha:linhaa,:) = matrix2;
        elseif ordem_blocos(blocos) == 3
                infos.matrix(linha:linhaa,:) = matrix3;        
        elseif ordem_blocos(blocos) == 4
                infos.matrix(linha:linhaa,:) = matrix4;    
        end
  
        linha = linha + ll; 
        linhaa = linhaa + ll; 
    
end


if participant.exp == 2 % treino
    if participant.tr == true % condicao facil
         mat1 = [...
          1             2             2];
      
   mat3 = [... 
          3             1             1];
 
    mat = [mat1;mat3];
    infos.matrix = mat(randperm(size(mat,1)),:); % aleatoriza as linhas
    end
end


infos.refreshR   = Screen('FrameRate',infos.screenNumber);

if infos.refreshR== 120

    infos.loops  = 168; 
    infos.nrows  = 168;
    infos.fponly = [3 4];
    
    if participant.exp == 1
        if participant.median >= 200    

            tg_onset     = 90:3:144;       % define em q loops o alvo será apresentado 
            ordem        = randi(19,infos.ntrials,1);% cria 960 val. aleató. entre 19-1.
                                                     % SOA + longo: 175 (+ 25 alvo)
        elseif participant.median >= 175 && participant.median < 200

            tg_onset     = 90:3:141;       % define em q loops o alvo será apresentado 
            ordem        = randi(16,infos.ntrials,1);% cria 960 val. aleató. entre 16-1.  
                                                     % SOA + longo: 150 (+ 25 alvo)
        elseif participant.median >= 140 && participant.median < 175 

            tg_onset     = 90:3:138;       % define em q loops o alvo será apresentado 
            ordem        = randi(13,infos.ntrials,1);% cria 960 val. aleató. entre 13-1.  
                                                     % SOA + longo: 125 (+ 25 alvo)
        end
        
    else
        
        tg_onset     = 90:3:144;       % define Respem q loops o alvo será apresentado 
        ordem        = randi(19,infos.ntrials,1);% cria 960 val. aleató. entre 19-1.
                                                 % SOA + longo: 175 (+ 25 alvo)
    end

    
    SOAs         = zeros(infos.ntrials,1);   % vetor que sera preenchido abaixo
    offset_target = zeros(infos.ntrials,1);
    ordem2       = zeros(infos.ntrials,1);
    
    for i = 1:length(ordem)        % define inicio d apresen. do alvo por tentativa
        SOAs(i)  = tg_onset(ordem(i));
    end
    
    
    for p = 1:length(ordem)
        ordem2(p,1) = ordem(p) + 2; 
    end
    
    for z = 1:length(ordem)
        offset_target(z) = SOAs(z) + 2;
    end
    
    
    infos.SOA = [SOAs  ordem  ordem2 offset_target];  
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
    infos.startgap = zeros(400,1);
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
degree_targetccw = participant.limiar;  % counterclockwise condition | shifted to the left
degree_targetcw = 360 - degree_targetccw;  % clockwise condition | shifted to the right

infos.cue_size = a3; 
% define o tipo de pista, lado e orienta��o do alvo para a respectiva
% tentativa.
for q = 1:infos.ntrials
    
    % pista periférica sac
    if infos.matrix(q,1) == 1
        
        % alvo na esquerda
        if infos.matrix(q,2) == 1
            infos.leftcuesize(q)    = a3;
            infos.rightcuesize(q)   = a2; 
            infos.pista_esquerda(q) = 1;
            
            if infos.matrix(q,3) == 1 % define orient do alvo
                 infos.orienttarget(q,1) = degree_targetccw;
                 infos.orienttarget(q,2) = 0; 
            else
                 infos.orienttarget(q,1) = degree_targetcw;
                 infos.orienttarget(q,2) = 0; 
            end  
        else %alvo na direita  
             infos.leftcuesize(q)   = a2;
             infos.rightcuesize(q)  = a3;
             infos.pista_direita(q) = 1;
             
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
        
   elseif infos.matrix(q,1) == 3 % pista central sacada
        
        % pista e alvo na esquerda
        if infos.matrix(q,2) == 1
            infos.leftcuesize(q)    = a2;
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
             infos.rightcuesize(q)  = a2;
             infos.pista_direita(q) = 1;
            
           if infos.matrix(q,3) == 1
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = degree_targetccw; 
           else
                 infos.orienttarget(q,1) = 0;
                 infos.orienttarget(q,2) = degree_targetcw; 
           end
        end
        
     elseif infos.matrix(q,1) == 4 % pista central encoberta
        
        % pista e alvo na esquerda
        if infos.matrix(q,2) == 1
            infos.leftcuesize(q)    = a2;
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
             infos.rightcuesize(q)  = a2;
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

matrix = infos.matrix(1:infos.ntrials,:);
SOA = infos.SOA(1:infos.ntrials,:);

[g]           = gabor(infos);
[aperture]    = FastMaskedNoiseDemo(infos, g);
[disctexture] = disc(infos);

if participant.exp == 1
    [timestamps,Response,noise_gabor,fix,targ]    = exp_cues(g,infos, aperture, disctexture, participant);
else
    if participant.tr == false
        [Response,targ] = exp_cues_treino(g,infos, aperture, disctexture,participant);
    else
        exp_cues_treino_facil(g,infos, aperture, disctexture);
    end
end

if participant.exp == 1 % Coleta de dados no exp
    
    participant.eyefilename = 'express.edf'; 
    participant.filename = sprintf('Sacc_sub%s_ses%s_%s',participant.strnum,participant.strses,datestr(now,'yyyymmdd-HHMM'));       
    disp('Saving data files........')
    save(fullfile(sprintf('/mnt/projetos/sacc_cues/data/Subject%s/',participant.strnum),...
        [participant.filename,'.mat']),'participant','Response','timestamps', 'matrix', 'SOA');

       if exist(participant.eyefilename,'file')
             movefile(participant.eyefilename,sprintf('/mnt/projetos/sacc_cues/data/Subject%s/eyetracking/%s.edf',participant.strnum,participant.filename));
       else
             error('Eye-tracker data file not found!');
       end

    disp('All done!');
    
    
    if participant.coleta == 1
        [subject_mean] = analysis_eye_SRT(participant);
        mean_SRT = subject_mean
    end
    
    
end

 

