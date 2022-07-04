function exp_cues_treino_facil(g,infos, aperture, disctexture)


% Hide mouse cursor
HideCursor(infos.screen_num);





for q = 1:2
    
    
    
    
    if q == 1
        
        dotsize = repmat(infos.dotSize,infos.nrows,2);
        dotsize(infos.cue_onoff(q,1):infos.nrows,1) = infos.leftcuesize(q);
        dotsize(infos.cue_onoff(q,1):infos.nrows,2) = infos.rightcuesize(q);
    else
        dotsize = repmat(infos.dotSize,infos.nrows,2);
        dotsize(infos.cue_onoff(q,1):infos.nrows,1) = infos.leftcuesize(q);
        dotsize(infos.cue_onoff(q,1):infos.nrows,2) = infos.rightcuesize(q);
    end
    
    fp = repmat(WhiteIndex(infos.screenNumber),infos.nrows,1);
    
    orient                       = repmat(infos.orientation,infos.nrows,1);
    orient(infos.SOA(q,1):infos.SOA(q,4),1)     = infos.orienttarget(q,1);
    orient(infos.SOA(q,1):infos.SOA(q,4),2)     = infos.orienttarget(q,2);
    
    dclear                       = zeros(infos.nrows,1);
    dclear(infos.startgap(q))    = 1;
    dclear(infos.cue_onoff(q,1)) = 1;
    dclear(infos.cue_onoff(q,2)) = 1;
    
    
    HideCursor;
    load('filename.mat', 'noise');
    
    %%
    
    if q == 1
        DrawFormattedText(infos.win,'--- Pista Central ---', 'center','center', infos.black);
        Screen('Flip', infos.win);
        WaitSecs(0.5)
        clear buttons
        [~,~,buttons]=GetMouse;
        while ~any(buttons)
            [~,~,buttons]=GetMouse;
        end
        clear buttons
        
    else
        DrawFormattedText(infos.win,'--- Pista Periférica ---', 'center','center', infos.black);
        Screen('Flip', infos.win);
        WaitSecs(0.5)
        clear buttons
        [~,~,buttons]=GetMouse;
        while ~any(buttons)
            [~,~,buttons]=GetMouse;
        end
        clear buttons
        
    end
    
    % Desenha os placeholders e pf na tela por 500 ms
    Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
    Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,infos.white,[],2,1);
    Screen('DrawDots',infos.win,infos.pholdercoordL,infos.dotSize,infos.pholdercolor,[],2,1);
    Screen('DrawDots',infos.win,infos.pholdercoordR,infos.dotSize,infos.pholdercolor,[],2,1);
    Screen('Flip', infos.win);
    WaitSecs(0.5);
    
    clear buttons
    [~,~,buttons]=GetMouse;
    while ~any(buttons)
        [~,~,buttons]=GetMouse;
    end
    clear buttons
    
    
    %%
    for b = 1:6
        
        % 1 segundo apresenta��o placeholders, pf, noise/gabor
        texL=Screen('MakeTexture',infos.win,noise(b,1).noiseimg,[],infos.flags);
        texR=Screen('MakeTexture',infos.win,noise(b,2).noiseimg,[],infos.flags);
        
        % Pista central
        if q == 1
            if  b >= 2
                
                Screen('DrawLine', infos.win, infos.black, infos.xcenter,infos.ycenter ...
                    ,infos.xcenter - 26,infos.ycenter, 4);
                
            end
        end
        Screen('BlendFunction', infos.win, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTextures', infos.win, texL, [],infos.coordL,...
            [],infos.filtmode,infos.galpha, [], []);
        Screen('DrawTextures', infos.win,[aperture disctexture],...
            [], infos.coordL, [], 0, [],infos.grey);
        
        Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTextures', infos.win, texR, [], infos.coordR,[],...
            infos.filtmode, infos.galpha, [], []);
        Screen('DrawTextures', infos.win, [aperture disctexture],...
            [], infos.coordR, [], 0,[],infos.grey);
        
        if q == 2
            if b >= 2
                dotsize(5,1) = infos.cue_size;
            end
        end
        
        Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,fp(1),[],2);
        Screen('DrawDots', infos.win, infos.pholdercoordL, dotsize(5,1),...
            infos.pholdercolor, [], 2, 1);
        Screen('DrawDots', infos.win, infos.pholdercoordR, dotsize(5,2),...
            infos.pholdercolor, [], 2, 1);
        Screen('Flip', infos.win,[]);
        WaitSecs(0.5);
        
        clear buttons
        [~,~,buttons]=GetMouse;
        while ~any(buttons)
            [~,~,buttons]=GetMouse;
        end
        clear buttons
        
        % Pista central
        if q == 1
            if  b >= 2
                
                Screen('DrawLine', infos.win, infos.black, infos.xcenter,infos.ycenter ...
                    ,infos.xcenter - 26,infos.ycenter, 4);
                
            end
        end
        
        
        if q == 2
            if b >= 2
                dotsize(5,1) = infos.cue_size;
            end
        end
        
        if b == 4
            orient = 45;
        else
            orient = 0;
        end
        
        if b <= 4
            texLL = g.gabortex; texRR = g.gabortex;
            Screen('BlendFunction', infos.win, 'GL_ONE', 'GL_ZERO');
            Screen('DrawTextures', infos.win, texLL, [], infos.coordL,...
                orient,0,1,[],[], kPsychDontDoRotation, g(1).propertiesMat');
            
            Screen('DrawTextures', infos.win, texRR, [], infos.coordR,...
                0, 0,1,[],[],kPsychDontDoRotation, g(1).propertiesMat');
            
            Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
            Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,fp(1),[],2);
            
            
            Screen('DrawDots', infos.win, infos.pholdercoordL, dotsize(5,1),...
                infos.pholdercolor, [], 2, 1);
            Screen('DrawDots', infos.win, infos.pholdercoordR, dotsize(5,2),...
                infos.pholdercolor, [], 2, 1);
            Screen('Flip', infos.win,[]);
            WaitSecs(0.5)
            
            
            clear buttons
            [~,~,buttons]=GetMouse;
            while ~any(buttons)
                [~,~,buttons]=GetMouse;
            end
            clear buttons
            
        end
        
        
    end
    
    % Desenha os placeholders e pf na tela
    Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
    Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,infos.white,[],2,1);
    Screen('DrawDots',infos.win,infos.pholdercoordL,infos.dotSize,infos.pholdercolor,[],2,1);
    Screen('DrawDots',infos.win,infos.pholdercoordR,infos.dotSize,infos.pholdercolor,[],2,1);
    Screen('Flip', infos.win);
    WaitSecs(0.5);
    
    clear buttons
    [~,~,buttons]=GetMouse;
    while ~any(buttons)
        [~,~,buttons]=GetMouse;
    end
    clear buttons
    
    
    
end


clear Textures






KbStrokeWait;

Screen('Close', infos.win);
FlushEvents;
ListenChar(0);
ShowCursor;
Priority(0);


% este comando � que vai permitir que voc� receba uma mensagem detalhada
% sobre o erro detectado no script pela fun��o try-catch.
psychrethrow(psychlasterror);





end
