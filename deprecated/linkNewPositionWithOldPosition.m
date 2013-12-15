function [ index  ] = linkNewPositionWithOldPosition( oldPositions, newPosition, intensityMasks, intensityPositions, of, radius)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    mask = false(size(im));

    position = [newPosition(1), newPosition(2)];
    positionWithFactor = position;
    positionWithFactor(3) = radius;
    uint8Mask = insertShape(uint8(mask), 'FilledCircle', positionWithFactor);

    circleMask = im2bw(uint8Mask,0.5);
        
    foundIntensityPoints = zeros;
    foundIntensityMasks = cell();
    
    l = 1;

    
    for i = 1 : length(intensityPositions(:))
        
        j = 1;
        
        for k = 1 : intensityPositions(i,:);
            point = intensityPositions(i,k);
            if isPointWithinMask(point, circleMask)
                foundIntensityPoints(l,j) = point;
                foundIntensityMasks{l,j} = intensityMasks(i,k);
                j = j + 1;
            end
        end
        
        l = l + 1;
    end
    
    index = 0;
    d = inf;
    
    % Suche Index der klasse für die gefundene Punktwolke, dessen
    % Schwerpunkt am nähesten zum Ursprungspunkt ist
    for i = 1 : length(foundIntensityPoints(:))
        
          centroid = calculateCentroid(foundIntensityPoints(i));

          newD = sqrt(double((centroid(1)-newPosition(1))^2 + (centroid(2)-newPosition(2))^2));

          if newD < d
                d = newD;
                index = i;
          end
    end
    
    s = 0;
    vx = 0;
    vy = 0;
    
    if(index ~= 0)
                
        for i = 1 : length(foundIntensityMasks(:))
            mask = double(newMask);

            xv = real(of).*mask;
            yv = imag(of).*mask;
            s = s + sum(sum(mask));
            vx = vx + sum(sum(xv)); %calculate x-average of all points that are within the mask
            vy = vy + sum(sum(yv)); %calculate y-average of all points that are within the mask
        end   
        
        vx = vx  / s;
        vy = vy / s;
    end
    
    nvx = -vx;
    nvy = -vy;
    
    
    % Verschiebe ursprungspunkt in die entgegengesetzte Richtung des
    % gemittelten Geschwindigkeitsvektor.
    
    calculatedOldPosition = [newPosition(1) + nvx, newPosition(2) + nvy ];
    
    
    %Spanne kreis um calculatedOldPosition 
    
    mask2 = false(size(im));

    position2 = [calculatedOldPosition(1), calculatedOldPosition(2)];
    position2WithFactor = position2;
    position2WithFactor(3) = radius;
    uint8Mask = insertShape(uint8(mask2), 'FilledCircle', position2WithFactor);

    circleMask2 = im2bw(uint8Mask,0.5);
    
   %Suche darin nach den übergebenen oldPositions
   foundOldPositions = zeros;
   
   j = 1;
   
   for i = 1 : length(oldPositions(:))
       if isPointWithinMask(oldPositions(i),circleMask2)
          foundOldPositions(j) = oldPositions(i);
          j = j + 1;
       end
   end
   
   %Suche darin den Punkt mit dem geringsten Abstand zu calculatedOldPosition
   
   index = 0;
   d = inf;
    
   for i = 1 : length(oldPositions(:))
         newD = sqrt(double((calculatedOldPosition(1)-oldPositions(i,1))^2 + (calculatedOldPosition(2)-oldPositions(i,2))^2));

         if newD < d
                d = newD;
                index = i;
         end
   end
   
   
end

