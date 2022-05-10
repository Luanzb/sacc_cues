function [participant] = inputsubject_treino


  
    tr = questdlg('Dificuldade?', ...
        '', ...
        'Facil', 'Normal','');
    switch tr
        case 'Facil'
            participant.tr = true;
            participant.tempo = 0.2;
            participant.tempo2 = 0.5;
        case 'Normal'
            participant.tr = false;
            participant.tempo = 0;
            participant.tempo2 = 0;
    end
    
    
end
