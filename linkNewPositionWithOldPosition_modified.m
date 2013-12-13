function [index, vx, vy, vmask, smask] = linkNewPositionWithOldPosition_modified( oldPositions, newPosition, intensityMasks, intensityPositions, of, mask_search_radius, position_search_radius)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    
    mask = false(size(of));

    position = [newPosition(1), newPosition(2)];
    positionWithFactor = position;
    positionWithFactor(3) = mask_search_radius;
    uint8Mask = insertShape(uint8(mask), 'FilledCircle', positionWithFactor);

    circleMask = im2bw(uint8Mask, 0.5);
    
    smask = circleMask;
    
%     figure(11)
%     imshow(circleMask);
    
    clear foundIntensityPoints;
    clear foundIntensityMasks;
    
    l = 1;
    
    iPosSize = size(intensityPositions);
    
%     ipvis = uint8(repmat(zeros(size(of)),[1 1 3]));
%     for i = 1 : iPosSize(3)
%         for k = 1 : iPosSize(4)
%             point = intensityPositions(:,:,i,k);
% %             disp(intensityPositions(:,:,i,k));
%             if point(1) == -1 && point(2) == -1
%                 continue
%             end
%             ipvis(point(1), point(2), 1) = 0;
%             ipvis(point(1), point(2), 2) = 255;
%             ipvis(point(1), point(2), 3) = 0;
%         end
%     end
%     figure(30);
%     imshow(ipvis);
    
%     disp(intensityPositions);
%     disp(iPosSize);
%     disp('search points:');
    
    for i = 1 : iPosSize(3)
        
        j = 1;
        
        for k = 1 : iPosSize(4)
            
%             disp([num2str(i),' ',num2str(k),' ',num2str(iPosSize(1)),' ',num2str(iPosSize(2))]);
            point = intensityPositions(:,:,i,k);
            
            if point(1) == -1 && point(2) == -1
                continue
            end
            
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
    if exist('foundIntensityPoints', 'var') == 1
        fIPointsSize = size(foundIntensityPoints);
%         disp(fIPointsSize);
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
    va = 0;
    
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
        
        %skalierung der geschwindigkeit, weil der wert sonst so klein ist,
        %das keine verschiebung erfolgt
        va = abs(vx + vy*i);
        vx = -(vx / s)*200 * (0.5 + (va/(1 + (va^3)))*2); %skalierung die anfangs stark steigt und bald abfaellt
        vy = -(vy / s)*200 * (0.5 + (va/(1 + (va^3)))*2);
%         vx = -(vx / s)*200 * (0.5 + (va/(0.5 + (va^4)))*2); %skalierung die anfangs stark steigt und bald abfaellt
%         vy = -(vy / s)*200 * (0.5 + (va/(0.5 + (va^4)))*2);
%         vx = -(vx / s)*100 * (0.5 + ((va*4)/(0.25 + (va)))*(1/exp(va^4))); %skalierung die anfangs stark steigt und bald abfaellt
%         vy = -(vy / s)*100 * (0.5 + ((va*4)/(0.25 + (va)))*(1/exp(va^4)));
    end
    
%     if va ~= 0
%         disp([num2str(vx), ' ',num2str(vy), ' = ', num2str(va)]);
%     end
    
    nvx = vx;
    nvy = vy;
    
    % Verschiebe ursprungspunkt in die entgegengesetzte Richtung des
    % gemittelten Geschwindigkeitsvektor.
    
    calculatedOldPosition = [newPosition(1) + nvx, newPosition(2) + nvy ];
    
%     disp('calculatedOldPosition');
%     disp(calculatedOldPosition);
    
    %Spanne kreis um calculatedOldPosition 
    
    mask2 = false(size(of));

    position2 = [calculatedOldPosition(1), calculatedOldPosition(2) + 2];
    position2WithFactor = position2;
    position2WithFactor(3) = position_search_radius + 1*(va/(0.5 + (va^3)))*2;% + 1*(va/3);
    uint8Mask = insertShape(uint8(mask2), 'FilledCircle', position2WithFactor);

    circleMask2 = im2bw(uint8Mask,0.5);
    vmask = circleMask2; %for debugging
    
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
   
   if exist('relevantOldPositionIndices', 'var') == 1
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

