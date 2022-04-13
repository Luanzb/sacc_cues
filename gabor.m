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
phase = 0;

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles = 8;
freq = numCycles / gaborDimPix;

% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5.
% For full details see:
% https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/9174
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.3;
g.gabortex = CreateProceduralGabor(infos.win, gaborDimPix, gaborDimPix, [],...
    backgroundOffset, disableNorm, preContrastMultiplier);

% Randomise the phase of the Gabors and make a properties matrix.
g.propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
end
