function [g] = gabor(infos)
%--------------------
% Gabor information
%--------------------
g = struct;

% Dimension of the region where will draw the Gabor in pixels
gaborDimPix = infos.rect(4) / 2;

% Sigma of Gaussian
sigma = gaborDimPix / 6; % valor original � 7

% Obvious Parameters
%orientation = [];
contrast = 1;
aspectRatio = 1.0;

val = (0:0.00557:2)'; % cria 360 valores entre 1 e 2
phase = zeros(168,1);

for gg = 1:168
    val2 = randi(length(val)); % escolhe um valor aleatorio entre 1 e 360
    card = val(val2); % na posicao val2, a variavel card recebera o valor de val
    ph = pi/card;
    phase(gg,1) = ph*2*pi;
end

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles = 5.5; % dividir numcycles pelo tamanho do est[imulo em dva me mostra a freq espacial desse est[imulo em angulo de visao
freq = numCycles / gaborDimPix; % me da a freq espacial em pixels

% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5.
% For full details see:
% https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/9174
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;
g.gabortex = CreateProceduralGabor(infos.win, gaborDimPix, gaborDimPix, [],...
    backgroundOffset, disableNorm, preContrastMultiplier);

for bb = 1:168
    % Randomise the phase of the Gabors and make a properties matrix.
    g(bb).propertiesMat = [phase(bb,1), freq, sigma, contrast, aspectRatio, 0, 0, 0];
end

end
