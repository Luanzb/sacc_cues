function [aperture] = FastMaskedNoiseDemo(infos, g)

noise1 = struct;
noise = struct;


    numRects = 1; % Draw one noise patch by default.
    rectSize = 30; % Default patch size is 128 by 128 noisels.
    scale = 2; % Don't up- or downscale patch by default.   
      
    % 'objRect' is a rectangle of the size 'rectSize' by 'rectSize' pixels of
    % our Matlab noise image matrix:
    objRect = SetRect(0,0, rectSize, rectSize);

    % ArrangeRects creates 'numRects' copies of 'objRect', all nicely
    % arranged / distributed in our window of size 'winRect':
    dstRect = ArrangeRects(numRects, objRect, infos.rect);

    % Now we rescale all rects: They are scaled in size by a factor 'scale':
    for i=1:numRects
        % Compute center position [xc,yc] of the i'th rectangle:
        [xc, yc] = RectCenter(dstRect(i,:));
        % Create a new rectangle, centered at the same position, but 'scale'
        % times the size of our pixel noise matrix 'objRect':
        dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
    end


    aperture=Screen('OpenOffscreenwindow', infos.win, infos.grey, objRect, [], 1);
    Screen('FillOval', aperture, [255 255 255 0], objRect);
    
    
    if infos.refreshR == 120
      
         cont = 1;
        
       
         for ii = 1:100 % 56
              noise1(ii,1).noiseimg=imgaussfilt((50*randn(rectSize, rectSize) + 128),4); 
              noise1(ii,2).noiseimg=imgaussfilt((50*randn(rectSize, rectSize) + 128),4);
               
              
              noise(cont,  1).noiseimg = noise1(ii,1).noiseimg;
              noise(cont+1,1).noiseimg = noise1(ii,1).noiseimg;
              noise(cont+2,1).noiseimg = noise1(ii,1).noiseimg;
              
              noise(cont,  2).noiseimg = noise1(ii,2).noiseimg;
              noise(cont+1,2).noiseimg = noise1(ii,2).noiseimg;
              noise(cont+2,2).noiseimg = noise1(ii,2).noiseimg;
              
              cont = cont  + 3;
              
         end         
       
    else
        
       number_noises = 42;
       cont = 0;
        for a = 1:number_noises
            cont = cont + 1;
            if a == 1
                noise(a,1).noiseimg=imgaussfilt((50*randn(rectSize, rectSize) + 128),4); 
                noise(a,2).noiseimg=imgaussfilt((50*randn(rectSize, rectSize) + 128),4);
            else
                noise(cont,1).noiseimg=imgaussfilt((50*randn(rectSize, rectSize) + 128),4);
                noise(cont,2).noiseimg=imgaussfilt((50*randn(rectSize, rectSize) + 128),4);
            end
            cont = cont + 1;
            noise(cont,1).noiseimg = g.gabortex;
            noise(cont,2).noiseimg = g.gabortex;   
        end  
       
    end
    
    
    
    
    save('filename.mat', 'noise');
        
end

    
    