function [disctexture] = disc(infos)
PsychDefaultSetup(2);

vsize = 500; % esse valor no script principal não é usado, pois são usadas 
             % as coordenadas da função 'FastMaskedNoiseDemo' para definir 
             % o local de apresentação, bem como o tamanho do circulo.
             
radius = vsize / 2;

sigma = 90;  % mesmo valor aplicado ao gabor. 

smoothMetod = 2; % o valor 2 inverte o smooth. Ou seja, no meio do circulo
                 % vai ficar transparente e o edge do circulo é que sofrerá o
                 % smooth. Se colocar o valor 1, o centro do circulo será
                 % preenchido. 
                 
disctexture = CreateProceduralSmoothedDisc(infos.win, vsize,...
    vsize, [], radius, sigma, true, smoothMetod);
end

