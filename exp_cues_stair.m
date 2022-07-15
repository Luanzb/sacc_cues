function [timestamps, response, AM, trls, targ] = exp_cues_stair(g, infos, aperture, disctexture, participant)

FlushEvents;
ListenChar(2);
EyelinkInit(0)

%%% Eyetracking general setup
EyelinkInit(0);
Eyelink('OpenFile', 'express'); % open temporary eyelink file

% Select which events are saved in the EDF file - include everything just in case
Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
% Select which events are available online for gaze-contingent experiments - include everything just in case
Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
% Select which sample data is saved in EDF file or available online - include everything just in case
Eyelink('Command', 'file_sample_data = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');

   if participant.eye == 'D'
        eye_used = 2;
        Eyelink('Command', 'active_eye = RIGHT');
    elseif participant.eye == 'E'
         eye_used = 1;
        Eyelink('Command', 'active_eye = LEFT');
    end
    
el = EyelinkInitDefaults(infos.win);

% Set calibration/validation/drift-check(or drift-correct) size as well as background and target colors
% It is important that this background colour is similar to that of the stimuli to prevent large luminance-based
% pupil size changes (which can cause a drift in the eye movement data)
el.calibrationtargetsize = 2;   % outer target size as percentage of the screen
el.calibrationtargetwidth = 0.3;    % inner target size as percentage of the screen
el.backgroundcolour = infos.grey;     % RGB grey
el.calibrationtargetcolour = [0 0 0];    % RGB black
% Set "Camera Setup" instructions text colour so it is different from background colour
el.msgfontcolour = [0 0 0];     % RGB black

% Use an image file instead of the default calibration bull's eye targets
% (commenting out the following two lines will use default targets)
el.calTargetType = 'image';
el.calImageTargetFilename = [pwd '/' '/mnt/projetos/expresac/images/fixTargetXXX.jpg'];

% Set calibration beeps (0 = sound off, 1 = sound on)
el.targetbeep = 0;  % sound a beep when a target is presented
el.feedbackbeep = 0;  % sound a beep after calibration or drift check/correction

EyelinkUpdateDefaults(el);

Eyelink('Command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, infos.width-1, infos.height-1);
Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, infos.width-1, infos.height-1);

% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV9'); % horizontal-vertical 9-points
% you must send this command with value NO for custom calibration
% you must also reset it to YES for subsequent experiments
Eyelink('command', 'generate_default_targets = NO');
% Modify calibration and validation target locations
Eyelink('command', 'calibration_samples = 10');
Eyelink('command', 'calibration_sequence = 0,1,2,3,4,5,6,7,8,9');
Eyelink('command', 'calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d',...
    960,540, 960,205, 960,875, 442,540, 1478,540, 442,205, 1478,205, 442,875, 1478,875);
Eyelink('command', 'validation_samples = 10');
Eyelink('command', 'validation_sequence = 0,1,2,3,4,5,6,7,8,9');
Eyelink('command', 'validation_targets = %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d',...
    960,540, 960,205, 960,875, 442,540, 1478,540, 442,205, 1478,205, 442,875, 1478,875);

% Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
Eyelink('Command', 'button_function 5 "accept_target_fixation"');
% Hide mouse cursor
HideCursor(infos.screenNumber);
% Start listening for keyboard input and suppress keypresses to Matlab windows
ListenChar(-1);
Eyelink('Command', 'clear_screen 0'); % clear Host PC display from any previus drawing

% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
EyelinkDoTrackerSetup(el);

% Create central square fixation window
fix_window_center = [-infos.roi_fixwinsize_pix -infos.roi_fixwinsize_pix infos.roi_fixwinsize_pix infos.roi_fixwinsize_pix];
fix_window_center = CenterRect(fix_window_center, infos.rect);

% Open ResponsePixx
ResponsePixx('Open');

%%

tempo = 0;

trls = struct;
response = NaN(infos.ntrials,6);
abort = false;

if participant.method == 1  % 1-up/1-down
    
    UD1 = PAL_AMUD_setupUD('up',1,'down',1,...
        'stepSizeDown',infos.UD_step_size_down,...
        'stepSizeUp',infos.UD_step_size_up,...
        'stopCriterion',infos.UD_stop_criterion,...
        'stopRule',infos.UD_stop_rule,...
        'startValue',infos.UD_start_value,...
        'xMax',infos.UD_xmax,...
        'xMin',infos.UD_xmin);
    
elseif participant.method == 2  % 1-up/2-down
    
    UD2 = PAL_AMUD_setupUD('up',1,'down',2,...
        'stepSizeDown',infos.UD_step_size_down,...
        'stepSizeUp',infos.UD_step_size_up,...
        'stopCriterion',infos.UD_stop_criterion,...
        'stopRule',infos.UD_stop_rule,...
        'startValue',infos.UD_start_value,...
        'xMax',infos.UD_xmax,...
        'xMin',infos.UD_xmin);
    
elseif participant.method == 3  % 1-up/3-down
    
    UD3 = PAL_AMUD_setupUD('up',1,'down',3,...
        'stepSizeDown',infos.UD_step_size_down,...
        'stepSizeUp',infos.UD_step_size_up,...
        'stopCriterion',infos.UD_stop_criterion,...
        'stopRule',infos.UD_stop_rule,...
        'startValue',infos.UD_start_value,...
        'xMax',infos.UD_xmax,...
        'xMin',infos.UD_xmin);
    
elseif participant.method == 4  % psi
    
    PSI = PAL_AMPM_setupPM('priorAlphaRange',infos.PSI_prior_alpha_range,...
        'priorBetaRange',infos.PSI_prior_beta_range,...
        'priorGammaRange',infos.PSI_prior_gamma,...
        'priorLambdaRange',infos.PSI_prior_lambda,...
        'numTrials',infos.PSI_stop_rule,...
        'PF',infos.PSI_PF,...
        'stimRange',infos.PSI_stim_range,...
        'marginalize',infos.PSI_marginalize);   % marginal parameters (1: threshold, 2: slope, 3: guess, 4: lapse)
    
elseif participant.method == 5  % pest
    
    PEST = PAL_AMRF_setupRF('priorAlphaRange',infos.PEST_prior_alpha_range,...
        'stopCriterion',infos.PEST_stop_criterion,...
        'stopRule',infos.PEST_stop_rule,...
        'beta',infos.PEST_beta,...
        'gamma',infos.PEST_gamma,...
        'lambda',infos.PEST_lambda,...
        'PF',infos.PEST_PF,...
        'xMin',infos.PEST_xmin,...
        'xMax',infos.PEST_xmax,...
        'meanmode',infos.PEST_mean_mode);
end

try
    
    
    targ = zeros(60,1);
    
    for q = 1:infos.ntrials
        
        
        if infos.show_noise_gabor(infos.SOA(q,1)) == 1
            ble = 0;
            blee = 0;
            
            % define se ou em quantos flips (3 ao todo) o alvo cairia na vez de
            % apresentacao do noise. variavel blee recebe esse valor
            for vrau = 1:3
                if infos.show_noise_gabor(infos.SOA(q,1) + ble) == 1
                    blee = blee + 1;
                end
                ble = ble + 1;
            end
            
        else
            ble = 0;
            blee = 0;
            
            % define se ou em quantos flips (3 ao todo) o alvo cairia na vez de
            % apresentacao do noise. variavel blee recebe esse valor
            for vrau = 1:3
                if infos.show_noise_gabor(infos.SOA(q,1) + ble) == 1
                    blee = blee + 1;
                end
                ble = ble + 1;
            end
            if blee == 1
                blee = 5;
            elseif blee == 2
                blee = 4;
            end
        end
        
        noise_gabor = infos.show_noise_gabor(blee+1:infos.SOA(q,4)+blee);
        sub = 168 - (size(noise_gabor));
        noise_gabor(length(noise_gabor)+1:length(noise_gabor)+sub(1)) = 1;
        
        %%
        fp = repmat(WhiteIndex(infos.screenNumber),infos.nrows,1);
        
        % define stimuli in this trial
        trls.curr_side(q) = infos.trials(q,1); % condition number
        trls.curr_cue_loc(q) = infos.trials(q,2); % type of cue (1=central; 2=peri)
        %     curr_cue_size = infos.trials(q,3); % cue size (a2=central; a3=peri)
        trls.curr_tg_dir(q) = infos.trials(q,4); % direction of target (1=clockwise;2=counterclock)
        
        if participant.method == 1
            trls.delta(q) = UD1.xCurrent; % trls.delta(q) = absolute difference between vertical ori and target ori
        elseif participant.method == 2
            trls.delta(q) = UD2.xCurrent;
        elseif participant.method == 3
            trls.delta(q) = UD3.xCurrent;
        elseif participant.method == 4
            trls.delta(q) = PSI.xCurrent;
        elseif participant.method == 5
            trls.delta(q) = PEST.xCurrent;
        end
        
        % define target orientation
        if trls.curr_tg_dir(q) == 1    % clockwise conditions
            trls.curr_ori(q) = 360-trls.delta(q);   % subtract trls.delta(q) from 360 deg to present ori shifted to the right
        elseif trls.curr_tg_dir(q) == 2   % counterclockwise conditions
            trls.curr_ori(q) = trls.delta(q);
        end
        
        if q > 1
            trls.curr_diff(q) = trls.delta(q) - trls.delta(q-1);
        end
        
        dotsize = repmat(infos.dotSize,infos.nrows,2);
        if infos.trials(q,1) == 1
            dotsize(infos.cue_onoff(q,1):infos.nrows,1) = infos.trials(q,3); % left
        else
            dotsize(infos.cue_onoff(q,1):infos.nrows,2) = infos.trials(q,3); % right
        end
        
        
        orient = repmat(infos.orientation,infos.nrows,1);
        if trls.curr_side(q) == 1   % left
            orient(infos.SOA(q,1):infos.SOA(q,4),1) = trls.curr_ori(q);
        elseif trls.curr_side(q) == 2   % right
            orient(infos.SOA(q,1):infos.SOA(q,4),2) = trls.curr_ori(q);
        end
        
        dclear = zeros(infos.nrows,1);
        dclear(infos.startgap(q)) = 1;
        dclear(infos.cue_onoff(q,1)) = 1;
        dclear(infos.cue_onoff(q,2)) = 1;
        
        %     centralcue = repmat(infos.grey,infos.nrows,1);
        %     centralcue(infos.cue_onoff(q,1):infos.nrows,1) = infos.black;
        
        %%
        HideCursor;
        load('filename.mat', 'noise');
        
        Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode before drawing Host PC graphics and before recording
        
        if q == 1
            text = 'Pisque e olhe para o ponto no centro do circulo \n\n que aparecerá a seguir ENQUANTO aperta a tecla A';
            DrawFormattedText(infos.win, text, 'center', 'center', [0,0,0]);
            Screen('Flip', infos.win);
            WaitSecs(4.5);
            
            EyelinkDoDriftCorrection(el, [infos.xcenter, infos.ycenter]);      % Run eyetracker drift correction
            WaitSecs(1);
        end
        
        if q == 1
            DrawFormattedText(infos.win,...
                sprintf('Bloco único.\n\n ---------------- \n\n Pista PERIFÉRICA \n\n Condição de FIXAÇÃO')...
                ,'center', 'center', infos.black);


            Screen('Flip', infos.win);


            % Wait for button press
            ResponsePixx('StartNow', 1, [0 1 0 0 0], 1);
            while 1
                [buttonStates, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttonStates)
                    if buttonStates(1,2) == 1 % yellow button
                        break;
                    elseif buttonStates(1,4) == 1 % blue button | sai do exp
                        abort = true;
                        break
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

            if abort == true
                break;
            end
        
        end
        Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
        Eyelink('ImageTransfer', '/mnt/projetos/fovea/images/placeholders.bmp', 0, 0, 0, 0, 0, 0);
        Eyelink('StartRecording');
        Eyelink('Command', 'record_status_message "TRIAL %d/%d"', q, infos.ntrials);
        
%         eye_used = Eyelink('EyeAvailable');
%         % Get events from right eye if binocular
%         if eye_used == 2
%             eye_used = 1;
%         end
        
        tic;
        % Desenha os placeholders e pf na tela por 500 ms
        Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,infos.white,[],2,1);
        Screen('DrawDots',infos.win,infos.pholdercoordL,infos.dotSize,infos.pholdercolor,[],2,1);
        Screen('DrawDots',infos.win,infos.pholdercoordR,infos.dotSize,infos.pholdercolor,[],2,1);
        [~, timestamps.fix_on(q)] = Screen('Flip', infos.win, tempo);
        
        % Wait until participant is fixating for infos.fix_dur_t
        while 1
            damn = Eyelink('CheckRecording');
            if(damn ~= 0)
                break;
            end
            
            if Eyelink('NewFloatSampleAvailable') > 0
                
                % get the sample in the form of an event structure
                evt = Eyelink('NewestFloatSample');
                % if we do, get current gaze position from sample
                x_gaze = evt.gx(eye_used); % +1 as we're accessing MATLAB array
                y_gaze = evt.gy(eye_used);
                if inFixWindow(x_gaze,y_gaze,fix_window_center) % If gaze sample is within fixation window (see inFixWindow function below)
                    if (GetSecs - timestamps.fix_on(q)) >= infos.fix_dur_t % If gaze duration >= minimum fixation window time (fxateTime)
                        
                        break; % break while loop to show stimulus
                    end
                elseif ~inFixWindow(x_gaze,y_gaze,fix_window_center) % If gaze sample is not within fixation window
                    [timestamps.fix_on(q)] = GetSecs; % Reset fixation window timer
                end
            end
        end
        
        %     if q > 1
        %         text = sprintf('side = %i / ori = %0.2f / trls.delta = %0.2f / diff = %0.2f', trls.curr_side(q), trls.curr_ori(q), trls.delta(q), trls.delta(q)-trls.delta(q-1));
        %     else
        %         text = sprintf('side = %i / ori = %0.2f / trls.delta = %0.2f', trls.curr_side(q), trls.curr_ori(q), trls.delta(q));
        %     end
        %     DrawFormattedText(infos.win, text, 'center', 'center', [0,0,0]);
        %     Screen('Flip', infos.win);
        %     KbStrokeWait;
        
        Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,infos.white,[],2,1);
        Screen('DrawDots',infos.win,infos.pholdercoordL,infos.dotSize,infos.pholdercolor,[],2,1);
        Screen('DrawDots',infos.win,infos.pholdercoordR,infos.dotSize,infos.pholdercolor,[],2,1);
        [timestamps.start_trial(q)] = Screen('Flip', infos.win, timestamps.fix_on(q));
        Eyelink('Message', sprintf('array_on_%1d', q));
        Eyelink('Command', 'record_status_message "TRIAL %d', q);
        
        ResponsePixx('StartNow', 1, [1 0 1 0 0], 1);
        for b = 1:infos.loops
            
            now = GetSecs();
            
            texL = Screen('MakeTexture',infos.win,noise(b,1).noiseimg,[],infos.flags);
            texR = Screen('MakeTexture',infos.win,noise(b,2).noiseimg,[],infos.flags);
            
            
            %         if trls.curr_cue_loc(q) == 2 && trls.curr_side(q) == 1   % left side
            %
            %             Screen('DrawLine', infos.win, centralcue(b), infos.xcenter,infos.ycenter, ...
            %             infos.xcenter - 26,infos.ycenter, 4);
            %         elseif trls.curr_cue_loc(q) == 2 && trls.curr_side(q) == 2   % right side
            %             Drw dots grande
            %
            %             Screen('DrawLine', infos.win, centralcue(b), infos.xcenter,infos.ycenter, ...
            %             infos.xcenter + 26,infos.ycenter, 4);
            %         end
            
            
            if noise_gabor(b) == 1
                
                Screen('BlendFunction', infos.win, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTextures', infos.win, texL, [],infos.coordL,...
                    [],infos.filtmode,infos.galpha, [], []);
                Screen('DrawTextures', infos.win,[aperture disctexture],...
                    [], infos.coordL, [], 0, [],infos.grey);
                
                Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTextures', infos.win, texR, [], infos.coordR, [],...
                    infos.filtmode, infos.galpha, [], []);
                Screen('DrawTextures', infos.win, [aperture disctexture],...
                    [], infos.coordR, [], 0,[],infos.grey);
                
                
            else
                if b <= infos.SOA(q,4)
                    texLL = g.gabortex; texRR = g.gabortex;
                    Screen('BlendFunction', infos.win, 'GL_ONE', 'GL_ZERO');
                    Screen('DrawTextures', infos.win, texLL, [], infos.coordL,...
                        orient(b,1),0,1,[],[], kPsychDontDoRotation, g(b).propertiesMat');
                    Screen('DrawTextures', infos.win, texRR, [], infos.coordR,...
                        orient(b,2), 0,1,[],[],kPsychDontDoRotation, g(b).propertiesMat');
                    
                    %             else % apos a aprsentacao do alvo, apenas os noises continuam sendo apresentados
                    %
                    %                 Screen('BlendFunction', infos.win, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                    %                 Screen('DrawTextures', infos.win, texL, [],infos.coordL,...
                    %                 [],infos.filtmode,infos.galpha, [], []);
                    %                 Screen('DrawTextures', infos.win,[aperture disctexture],...
                    %                 [], infos.coordL, [], 0, [],infos.grey);
                    %
                    %                 Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    %                 Screen('DrawTextures', infos.win, texR, [], infos.coordR, [],...
                    %                 infos.filtmode, infos.galpha, [], []);
                    %                 Screen('DrawTextures', infos.win, [aperture disctexture],...
                    %                 [], infos.coordR, [], 0,[],infos.grey);
                    %
                end
                
                % verifica se o alvo foi apresentado no flip de gabor.
                if orient(b,1) ~= 0
                    targ(q,1) = 1;
                elseif orient(b,2) ~= 0
                    targ(q,1) = 1;
                end
                
            end
            
            Screen('BlendFunction', infos.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
            Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,fp(b),[],2);
            Screen('DrawDots', infos.win, infos.pholdercoordL, dotsize(b,1),...
                infos.pholdercolor, [], 2, 1);
            Screen('DrawDots', infos.win, infos.pholdercoordR, dotsize(b,2),...
                infos.pholdercolor, [], 2, 1);
            
            % Get stimuli presentation timings and send eyelink timing messages
            if b == infos.startgap(q)
                [timestamps.gap_onset(q)] = Screen('Flip', infos.win, now+tempo, dclear(b));
                Eyelink('Message', sprintf('gap_onset_%1d', q));   % Send Eyelink message of gap onset
                response(q,2) = toc;
            elseif b == infos.cue_onoff(q,1)
                [timestamps.cue_onset(q)] = Screen('Flip', infos.win, now+tempo, dclear(b));
                Eyelink('Message', sprintf('cue_onset_%1d', q));   % Send Eyelink message of cue onset
                response(q,3) = toc;
            elseif b == infos.cue_onoff(q,2)
                [timestamps.cue_offset(q)] = Screen('Flip', infos.win, now+tempo, dclear(b));
                % Eyelink('Message', sprintf('cue_offset_%1d', q));  % Send Eyelink message of cue offset
                response(q,4) = toc;
            elseif b == infos.SOA(q,1)
                [timestamps.target_onset(q)] = Screen('Flip', infos.win, now+tempo, dclear(b));
                Eyelink('Message', sprintf('target_onset_%1d', q));% Send Eyelink message of target onset
                response(q,5) = toc; % inicio apresentacao do alvo
                % WaitSecs(0.5)
            else
                Screen('Flip', infos.win, now+tempo, dclear(b));
            end
            
            response(q,6) = response(q,5) - response(q,3); % SOA
            
        end
        
        %     if trls.curr_side(q) == 1 % alvo e pista na esquerda
        %         fix_window_targ = infos.coordL';
        %     else              % alvo e pista na direita
        %         fix_window_targ = infos.coordR';
        %     end
        %
        %         while 1
        %             damn = Eyelink('CheckRecording');
        %             if(damn ~= 0)
        %                 break;
        %             end
        %
        %             if Eyelink('NewFloatSampleAvailable') > 0
        %                 % get the sample in the form of an event structure
        %                 evt = Eyelink('NewestFloatSample');
        %                 % if we do, get current gaze position from sample
        %                 x_gaze = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
        %                 y_gaze = evt.gy(eye_used+1);
        %                 if inFixWindow(x_gaze,y_gaze,fix_window_targ) % If gaze sample is within fixation window (see inFixWindow function below)
        %                     break; % break while loop to show stimulus
        %                 end
        %             end
        %         end
        
        % Desenha os placeholders e pf na tela
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize2,infos.black,[],2,1);
        Screen('DrawDots',infos.win,infos.fpointcoord,infos.dotSize,infos.white,[],2,1);
        Screen('DrawDots',infos.win,infos.pholdercoordL,infos.dotSize,infos.pholdercolor,[],2,1);
        Screen('DrawDots',infos.win,infos.pholdercoordR,infos.dotSize,infos.pholdercolor,[],2,1);
        Screen('Flip', infos.win, tempo);
        
        if participant.giveresp == true
            % Wait for button press
            %         ResponsePixx('StartNow', 1, [1 0 1 0 0], 1);
            while 1
                [buttonStates, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttonStates)
                    if buttonStates(1,1) == 1 % red button
                        response(q,1) = 1;   % clockwise
                        break;
                    elseif buttonStates(1,3) == 1 % green button
                        response(q,1) = 2;  % counterclockwise
                        break;
                    elseif buttonStates(1,4) == 1 % blue button | sai do exp
                        abort = true;
                        break
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);
        end
        
        % update staircases based on trial's outcome
        if response(q,1) == trls.curr_tg_dir(q)
            outcome = 1;
        else
            outcome = 0;
        end
        
        %     text = sprintf('outcome = %i', outcome);
        %     DrawFormattedText(infos.win, text, 'center', 'center', [0,0,0]);
        %     Screen('Flip', infos.win);
        %     WaitSecs(1);
        
        if participant.method == 1  % 1-up/1-down
            UD1 = PAL_AMUD_updateUD(UD1, outcome);
        elseif participant.method == 2  % 1-up/2-down
            UD2 = PAL_AMUD_updateUD(UD2, outcome);
        elseif participant.method == 3  % 1-up/3-down
            UD3 = PAL_AMUD_updateUD(UD3, outcome);
        elseif participant.method == 4  % psi
            PSI = PAL_AMPM_updatePM(PSI, outcome);
        elseif participant.method == 5  % pest
            PEST = PAL_AMRF_updateRF(PEST, PEST.xCurrent, outcome);
        end
        
        if abort == true
            break;
        end
        
        % ResponsePixx color mapping
        %%% red    [1] = right
        %%% yellow [2] = front
        %%% green  [3] = left
        %%% blue   [4] = bottom
        %%% white  [5] = middle
        
        clear Textures
        
        if abort == true
            break;
        end
        
    end
    
    DrawFormattedText(infos.win,sprintf('Fim'),'center', 'center', infos.black);
    Screen('Flip', infos.win);
    
    if participant.method == 1  % 1-up/1-down
        AM = UD1;
    elseif participant.method == 2  % 1-up/2-down
        AM = UD2;
    elseif participant.method == 3  % 1-up/3-down
        AM = UD3;
    elseif participant.method == 4  % psi
        AM = PSI;
    elseif participant.method == 5  % pest
        AM = PEST;
    end
    
    ResponsePixx('Close');
    Eyelink('CloseFile');
    
    ntimes = 1;
    while ntimes <= 10
        status = Eyelink('ReceiveFile');
        if status > 0
            break
        end
        ntimes = ntimes + 1;
    end
    if status <= 0
        warning('EyeLink data has not been saved properly.');
    else
        fprintf('EyeLink data saved properly on attempt %d.\n',ntimes);
    end
    Eyelink('ShutDown');
    
    KbStrokeWait;
    
    Screen('Close', infos.win);
    FlushEvents;
    ListenChar(0);
    ShowCursor;
    Priority(0);
    
    toc;
catch
    
    psychrethrow(psychlasterror);
    
end

    function fix = inFixWindow(mx,my,fix_window)
        fix = mx > fix_window(1) &&  mx <  fix_window(3) && ...
            my > fix_window(2) && my < fix_window(4) ;
    end

end
