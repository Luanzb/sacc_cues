function [participant] = inputsubject


col_tr = questdlg('', ...
        '', ...
        'Coleta', 'Treino','Staircase', '');
    
    switch col_tr

        case 'Coleta'

             argindlg = inputdlg({...
            'Número do voluntário',...
            'Gênero (M/F/NB)',...
            'Idade',...
            'Olho dominante (E/D)',...
            'Sessão',...
            'Mediana SRT',...
            'Limiar'},...
            '',1);

            participant = struct;
            participant.exp = 1;
            participant.tempo = 0;
            participant.tempo2 = 0;
            participant.tempo3 = 0;
            participant.coleta = 1;
            
            participant.strnum = argindlg{1}; %salva str
            if isempty(participant.strnum)
                participant.strnum = '0';
            end

            participant.dnum = str2double(participant.strnum); %str --> numero voluntario
            participant.gender = upper(argindlg{2});
            if isempty(participant.gender)
                participant.gender = 'EMPTY';
            end

            participant.strage = argindlg{3};
            participant.dage = str2double(argindlg{3});
            if isempty(participant.strage)
                participant.dage = 0;
            end

            participant.eye = upper(argindlg{4});
            if isempty(participant.eye)
                participant.strnum = 'EMPTY';
            end
            
             participant.strses = argindlg{5};
            if isempty(participant.strses)
                participant.strnum = '1';
            end
            
            participant.median = str2double(argindlg{6});
            participant.med = str2double(argindlg{6});
            if isempty(participant.median)
                participant.med = 200;
            end
            
            participant.limiar = str2double(argindlg{7});
            participant.lim = str2double(argindlg{7});
            if isempty(participant.limiar)
                participant.lim = 30;
            end


            train_answer = questdlg('Coletar respostas?', ...
                '', ...
                'Sim', 'Não','');
            switch train_answer
                case 'Sim'
                    participant.giveresp = true;
                case 'Não'
                    participant.giveresp = false;
            end 
            
            
            
        case 'Treino'
            
            tr = questdlg('Dificuldade?', ...
                     '', ...
                     'Fácil', 'Normal','');
            participant.exp = 2;
            switch tr
                case 'Fácil'
                    participant.tr = true;
                    participant.tempo = 0.2;
                    participant.tempo2 = 0.5;
                    participant.tempo3 = 0.7;
                    participant.giveresp = false;
                    participant.limiar = 40;
                case 'Normal'
                    participant.tr = false;
                    participant.tempo = 0;
                    participant.tempo2 = 0;
                    participant.giveresp = true;
                    participant.limiar = 40;
            end
            
            
            
        case 'Staircase'
            
             argindlg = inputdlg({...
            'Número do voluntário',...
            'Sessão',...
            '1-up/(n)-down(1/2/3), Psi(4) or Pest(5)',...
            'Limiar',...
            'Olho dominante (E/D)'},...
            '',1);
        
            

            participant = struct;
                        
            participant.coleta = 0;
            participant.strnum = argindlg{1}; %salva str
            if isempty(participant.strnum)
                participant.strnum = '0';
            end


            participant.strses = argindlg{2};
            if isempty(participant.strses)
                participant.strnum = '1';
            end

            participant.method = argindlg{3};
            participant.method = str2double(participant.method);
            
            
             participant.limiar = str2double(argindlg{4});
            if isempty(participant.limiar)
                participant.limiar = 30;
            end
            
             participant.eye = upper(argindlg{5});
            if isempty(participant.eye)
                participant.strnum = 'EMPTY';
            end
            
            train_answer = questdlg('Coletar respostas?', ...
                '', ...
                'Sim', 'Não','');
            switch train_answer
                case 'Sim'
                    participant.giveresp = true;
                case 'Não'
                    participant.giveresp = false;
            end 
            
            
            staircase = questdlg('Primeiro Staircase?', ...
                '', ...
                'Sim', 'Não','');
            switch staircase
                case 'Sim'
                    participant.limiar = str2double(argindlg{4});
                    if isempty(participant.limiar)
                        participant.limiar = 15;
                    end
                    participant.step_size_down = 2.5;
                case 'Não'
                    participant.step_size_down = 1;
                    participant.limiar = str2double(argindlg{4});
            end 
            
    end

    
    
   
    
end
