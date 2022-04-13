
function newRect = CenterRectOnPoint(rectt,x,y)
% newRect = CenterRectOnPoint(rect,x,y


% CenterRectOnPoint offsets the rect to center it around an x and y position.
% The center of the rect is reported by RectCenter.
%
% See also PsychRects, RectCenter

% 9/13/99      Allen Ingling wrote it
% 10/6/99  dgp With permission from Allen, changed name from "PinRect", which
%              conflicts with Apple's very different PinRect QuickDraw function,
%              to CenterRectOnPoint. Simplified code.
% 8/22/19 mk   Resolve ambiguity around rect = 4x4 matrix.

if size(rectt,1) == 4 && size(rectt,2) == 4
  [cX,cY] = RectCenter(rectt');
  cX = cX';
  cY = cY';
else
  [cX,cY] = RectCenter(rectt);
end

newRect = OffsetRect(rectt,x-cX,y-cY);
