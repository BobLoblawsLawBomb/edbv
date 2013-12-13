function [ index  ] = linkNewPositionWithOldPosition_modified( oldPositions, newPosition, intensityMasks, intensityPositions, of, radius)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    
    mask = false(size(of));

    position = [newPosition(1), newPosition(2)];
    positionWithFactor = position;
    positionWithFactor(3) = radius;
    uint8Mask = insertShape(uint8(mask), 'FilledCircle', positionWithFactor);

    circleMask = im2bw(uint8Mask,0.5);
    
%     figure(11)
%     imshow(circleMask);
    
    clear foundIntensityPoints;
    clear foundIntensityMasks;
    
    l = 1;
    
    iPosSize = size(intensityPositions);
    
%     disp('search points:');
    
    for i = 1 : iPosSize(1)
        
        j = 1;
        
        for k = 1 : iPosSize(2);
            point = intensityPositions(:,:,i,k);
%             disp(point);
            if isPointWithinMask(point, circleMask)
                foundIntensityPoints(:,:,l,j) = point;
                foundIntensityMasks{l,j} = intensityMasks(:,:,i,k);
%                 disp('found point:');
%                 disp(['at ', num2str(l),' ', num2str(j)]);
%                 disp(point);
                j = j + 1;
            end
        end
        
        l = l + 1;
    end
    
    % Falls kein einziger punkt einer OpticalFlow-Maske im suchbereich
    % gefunden wurde wird index =  zurückgegeben, was bedeutet dass 
    
    classindex = 0;
    d = inf;
    
%     disp('schwerpunkte:');
    % Suche Index der klasse für die gefundene Punktwolke, dessen
    % Schwerpunkt am nähesten zum Ursprungspunkt ist
    if exist('foundIntensityPoints') ~= 0
        fIPointsSize = size(foundIntensityPoints);
        for i = 1 : fIPointsSize(1)
%             disp(foundIntensityPoints(:,:,i));
            centroid = calculateCentroid(foundIntensityPoints(:,:,i));
            
            newD = sqrt(double((centroid(1)-newPosition(1))^2 + (centroid(2)-newPosition(2))^2));
            
            if newD < d
                d = newD;
                classindex = i;
            end
        end
    end
    
    % Berechne mittlere geschwindigkeit der beteiligten OpticalFlow-Masken
    s = 0;
    vx = 0;
    vy = 0;
    
    if(classindex ~= 0)
        fIMasksSize = size(foundIntensityMasks);
        for i = 1 : fIMasksSize(2)
            mask = double(foundIntensityMasks{classindex, i});
%             disp(size(mask));
            xv = real(of).*mask;
            yv = imag(of).*mask;
            s = s + sum(sum(mask));
            vx = vx + sum(sum(xv)); %calculate x-average of all points that are within the mask
            vy = vy + sum(sum(yv)); %calculate y-average of all points that are within the mask
%             disp(s);
%             disp(vx);
%             disp(vy);
        end   
        
        vx = vx / s;
        vy = vy / s;
    end
    
    nvx = -vx;
    nvy = -vy;
    
    
    % Verschiebe ursprungspunkt in die entgegengesetzte Richtung des
    % gemittelten Geschwindigkeitsvektor.
    
    calculatedOldPosition = [newPosition(1) + nvx, newPosition(2) + nvy ];
    
%     disp('calculatedOldPosition');
%     disp(calculatedOldPosition);
    
    %Spanne kreis um calculatedOldPosition 
    
    mask2 = false(size(of));

    position2 = [calculatedOldPosition(1), calculatedOldPosition(2)];
    position2WithFactor = position2;
    position2WithFactor(3) = radius;
    uint8Mask = insertShape(uint8(mask2), 'FilledCircle', position2WithFactor);

    circleMask2 = im2bw(uint8Mask,0.5);
    
   %Suche darin nach eventuell vorhandenen oldPositions und speichere deren
   %indices
%    disp('search relevant old positions');
   
   clear relevantOldPositionIndices;
   
   j = 1;
   
   for i = 1 : length(oldPositions)
       if isPointWithinMask(oldPositions(:,:,i), circleMask2)
          relevantOldPositionIndices(j) = i;
          j = j + 1;
       end
   end
   
   %Suche aus den relevanten oldPositions den Punkt mit dem geringsten
   %Abstand zu calculatedOldPosition und gibt dessen index zurück
   %Falls keine oldPosition im umkreis exisitiert wird 0 zurückgegeben, was
   %bedeutet ein neues element wurde entdeckt
   
   index = 0;
   
   if exist('relevantOldPositionIndices') ~= 0
       d = inf;
       for i = 1 : length(relevantOldPositionIndices)
           oldPositionIndex = relevantOldPositionIndices(i);
           
           newD = sqrt((double(calculatedOldPosition(1)) - double(oldPositions(:,1,oldPositionIndex)))^2 + (double(calculatedOldPosition(2)) - double(oldPositions(:,2,oldPositionIndex)))^2);
           
           if newD < d
               d = newD;
               index = oldPositionIndex;
           end
       end
   end
   
end

