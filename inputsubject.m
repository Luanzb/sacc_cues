function [participant] = inputsubject

    argindlg = inputdlg({...
        'Número do voluntário',...
        'Gênero (M/F/E)',...
        'Idade',...
        'Sessao'},...
        '',1);
    
    participant = struct;
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
    
    participant.strses = argindlg{4};
    if isempty(participant.strses)
        participant.strnum = '1';
    end
    
    train_answer = questdlg('Coletar respostas?', ...
        '', ...
        'Sim', 'Nao','');
    switch train_answer
        case 'Sim'
            participant.giveresp = true;
        case 'Nao'
            participant.giveresp = false;
    end
    
end
