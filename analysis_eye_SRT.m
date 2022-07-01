
function [subject_mean] = analysis_eye_SRT(participant)
% clear all
% 
% close all
addpath /usr/local/MATLAB/toolbox/saccade_detection/
addpath(genpath('/usr/local/MATLAB/toolbox/edfmex/'))

%% 
data_folder = '/mnt/projetos/sacc_cues/';
var = sprintf('data/Subject%i/eyetracking/%s.edf',participant.dnum,participant.filename);
eyedf = edfmex(fullfile([data_folder var]));

if participant.eye == 'D'
    eye = 2;
else
    eye = 1;
end

%% get event times

eyedat = [];

for l = 1:length(eyedf.FEVENT)

    % loop to get events
    
     if strncmp(eyedf.FEVENT(l).message,'array_on',8)
        eyedat(1,l) = eyedf.FEVENT(l).sttime;
     elseif strncmp(eyedf.FEVENT(l).message,'cue_onset',9)
        eyedat(2,l) = eyedf.FEVENT(l).sttime;

    end

end


s.eyemat=eyedat(1,eyedat(1,:)~=0); % begining of trial computer clock
s.eyemat(2,:)=eyedat(2,eyedat(2,:)~=0); % cue on computer clock
s.eyemat(3,:)=eyedat(2,eyedat(2,:)~=0)-s.eyemat(1,:); % cue on trial time


% epoch data based on events

ppd = 36;

s.eyeraw = [];
epoch_size = [-50 210];


for l=1:size(s.eyemat,2)
    
    tt=   find(eyedf.FSAMPLE.time==s.eyemat(eye,l)); % relative array onset
    s.eyeraw(l,1,:)=(eyedf.FSAMPLE.gx(eye,tt-abs(epoch_size(1)): tt+epoch_size(2))-1920/2)/ppd;
    s.eyeraw(l,2,:)=(eyedf.FSAMPLE.gy(eye,tt-abs(epoch_size(1)): tt+epoch_size(2))-1080/2)/ppd;
    s.eyeraw(l,3,:)=eyedf.FSAMPLE.pa(eye,tt-abs(epoch_size(1)): tt+epoch_size(2));

end

s.eyeraw(s.eyeraw(:,1:2,:)>100)=nan;


s.eyemat_label = {'array on computer clock',...
                  'cue on computer clock',...
                  'cue on trial time'};


s.F = eyedf.RECORDINGS(1).sample_rate;
s.time = [epoch_size(1):1000/s.F:epoch_size(2)];
s.chans = {'Eye X','Eye Y','Eye Pupil'};



% save(s.fname,'s')
%% do visual atrifact rejection


%trlrej


%% do saccade detection


%  sac(1:num,1)   onset of saccade
%  sac(1:num,2)   offset of saccade
%  sac(1:num,3)   peak velocity of saccade (vpeak)
%  sac(1:num,4)   horizontal component     (dx)
%  sac(1:num,5)   vertical component       (dy)
%  sac(1:num,6)   horizontal amplitude     (dX)
%  sac(1:num,7)   vertical amplitude       (dY)
%  sac(1:num,8)   saccade magnitude        ()
% clear 
% 
% close all
% clc


MINDUR = 8;        % Minimum duration (number of samples)
VTHRES = 5;        % Velocity threshold
SAMPLING = s.F;    % Sampling rate
VTYPE = 2;         % Velocity types (2 = using moving average)

macrosacvec1 = []; % mudar o número para cada sessão

for l = 1:size(s.eyeraw,1)

    toi=[];%s.time>0 & s.time<s.eyemat(5,l)+200;
    veltemp = vecvel(squeeze(s.eyeraw(l,1:2,:))',SAMPLING,VTYPE);
    sactemp = microsacc(squeeze(s.eyeraw(l,1:2,:))',veltemp,VTHRES,MINDUR);

    if ~isempty(sactemp)
        sactemp(:,8) = sqrt(sactemp(:,7).^2 + sactemp(:,6).^2);
        strange = find(abs(sactemp(:,8)) > 15);
        sactemp(strange,:) = [];
    else sactemp = nan(1,8); 

    end
 
    s.sac{l} = sactemp;
    s.vel{l} = veltemp; 

        if sum(sactemp(:,8)>2) ~= 1 % only keep trials with ONE saccade >2dva
            macrosacvec1(l,:) =nan(1,size(sactemp,2));
        else
            macrosacvec1(l,:) = sactemp(sactemp(:,8)>2,:);
        end   

end


% correct times from epoched
macrosacvec1(:,1:2) = macrosacvec1(:,1:2)-abs(s.time(1));

%% 
s.macrosacvec = [macrosacvec1];

% save(s.fname,'s')


%%

s.macrosacvec(isnan(s.macrosacvec(:,:)))=0; %NANs recebem valor 0.
lat_sac = s.macrosacvec(:,1)/1000; % latencia das sacadas transformada para ms

subject_mean = mean(nonzeros(lat_sac));

end

