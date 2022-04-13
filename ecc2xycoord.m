function [x,y]=ecc2xycoord(ecc,theta,res)
% function to give xy coordenates of a
% ecc = eccentricity in pixels
% theta = angles in degrees
% res = screen resolution
ecc = 254.25;
theta = 0;
res = [1920 1080];

[xc, yc]=RectCenter([0 0 res]);

for a = 1:length(theta)
        x(a)=xc+round(ecc*cosd(theta(a)));
        y(a)=yc+round(ecc*sind(theta(a)));
end
x(isinf(x))=xc;
y(isinf(y))=yc;
end