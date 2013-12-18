function [index, vx, vy, vmask, smask] = findOldPosition(oldPositions, newPosition, oldClasses, newClass, intensityMasks, intensityPositions, of, mask_search_radius, position_search_radius, compIgnore)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------
    
    ymaskseachoffset = 0;
    ypossearchoffset = 0;
    
    mask = false(size(of));

    position = [newPosition(1), newPosition(2) + ymaskseachoffset];
    positionWithFactor = position;
    positionWithFactor(3) = mask_search_radius;
    uint8Mask = insertShape(uint8(mask), 'FilledCircle', positionWithFactor);

    circleMask = im2bw(uint8Mask, 0.5);
    
    smask = circleMask;
    
    clear foundIntensityPoints;
    clear foundIntensityMasks;
    
    l = 1;
    
    iPosSize = size(intensityPositions);
    
    for i = 1 : iPosSize(3)
        
        j = 1;
        
        for k = 1 : iPosSize(4)
            
            point = intensityPositions(:,:,i,k);
            
            if point(1) == -1 && point(2) == -1
                continue
            end
            
            if isPointWithinMask(point, circleMask)
                foundIntensityPoints(:,:,l,j) = point;
                foundIntensityMasks{l,j} = intensityMasks(:,:,i,k);
                
                j = j + 1;
            end
        end
        
        l = l + 1;
    end
    
    % Falls kein einziger punkt einer OpticalFlow-Maske im suchbereich
    % gefunden wurde wird index =  zurückgegeben, was bedeutet dass 
    
    classindex = 0;
    d = inf;
    
    % Suche Index der klasse für die gefundene Punktwolke, dessen
    % Schwerpunkt am nähesten zum Ursprungspunkt ist
    if exist('foundIntensityPoints', 'var') == 1
        fIPointsSize = size(foundIntensityPoints);
        for i = 1 : fIPointsSize(1)
            centroid = mean(foundIntensityPoints(:,:,i),1);
            
            newD = sqrt(double((centroid(1)-newPosition(1))^2 + (centroid(2)-newPosition(2))^2));
            
            if newD < d
                d = newD;
                classindex = i;
            end
        end
    end
    
    %Wichtig: Auch wenn keine OF-Maske gefunden hat, sollte er trotzdem in
    %der umgebung suchen, falls es sich um einen fehler handelt oder kleine
    %verschiebungen passieren, es kann leicht sein dass OF-Masken übersehen
    %werden, vor allem bei cluster-bildungen
    
    % Berechne mittlere geschwindigkeit der beteiligten OpticalFlow-Masken
    s = 0;
    vx = 0;
    vy = 0;
    va = 0;
    
    if(classindex ~= 0)
        fIMasksSize = size(foundIntensityMasks);
        for i = 1 : fIMasksSize(2)
            mask = double(foundIntensityMasks{classindex, i});
            xv = real(of).*mask;
            yv = imag(of).*mask;
            s = s + sum(sum(mask));
            vx = vx + sum(sum(xv)); %calculate x-average of all points that are within the mask
            vy = vy + sum(sum(yv)); %calculate y-average of all points that are within the mask
        end   
        
        %skalierung der geschwindigkeit, weil der wert sonst so klein ist,
        %das keine verschiebung erfolgt
        va = abs(vx + vy*i);
        vx = -(vx / s)*70;% * (0.5 + (va/(1 + (va^3)))*2); %skalierung die anfangs stark steigt und bald abfaellt
        vy = -(vy / s)*70;% * (0.5 + (va/(1 + (va^3)))*2);
    end
    
    % Verschiebe ursprungspunkt in die entgegengesetzte Richtung des
    % gemittelten Geschwindigkeitsvektor.
    
%     calculatedOldPosition = [double(newPosition(1)) + nvx, double(newPosition(2)) + nvy ];
    
    vel_stretch = 1 + 15*((va*0.65)/(20 + (va^1.75)));%1 + 15*((va*0.5)/(20 + (va^1.6)));%1 + 15*((va*0.43)/(20 + (va^1.3)));%1 + 50*(va/(180 + (va^1.6)));
    var_stretch = 1 + 15*((va*0.5)/(20 + (va^1.6)))*0.1;

    nvx = (vx/70)*vel_stretch;
    nvy = (vy/70)*vel_stretch;
    
    calculatedOldPosition = [double(newPosition(1)) + nvx, double(newPosition(2)) + nvy ];
    
%     disp(['before: ', num2str((double(newPosition(1)) + nvx)),' ', num2str((double(newPosition(2)) + nvy))]);
%     disp(['after: ', num2str(calculatedOldPosition(1)),' ', num2str(calculatedOldPosition(2))]);
    disp(['diff: ', num2str(calculatedOldPosition(1)-(double(newPosition(1)) + vx)),' ', num2str(calculatedOldPosition(2)-(double(newPosition(2)) + vy))]);
    
    rot = 360 - radtodeg(atan2(nvy, nvx));
    pos = [newPosition(1), newPosition(2) + ypossearchoffset ];
    
    radius = position_search_radius;
    
    circleMask2 = createSearchArea(pos, rot, radius, vel_stretch, var_stretch);
    
    vmask = circleMask2; %for debugging
    
   %Suche darin nach eventuell vorhandenen oldPositions und speichere deren
   %indices
   
   clear relevantOldPositionIndices;
   
   j = 1;
   
   oldPositionSize = size(oldPositions);
   for i = 1 : oldPositionSize(3)
       if compIgnore(i) == 0
           if isPointWithinMask(oldPositions(:,:,i), circleMask2)
              relevantOldPositionIndices(j) = i;
              j = j + 1;
           end
       end
   end
   
   %Suche aus den relevanten oldPositions den Punkt mit dem geringsten
   %Abstand zu calculatedOldPosition und gibt dessen index zurück
   %Falls keine oldPosition im umkreis exisitiert wird 0 zurückgegeben, was
   %bedeutet ein neues element wurde entdeckt
   
   index = 0;
   
   if exist('relevantOldPositionIndices', 'var') == 1
       d = inf;
       calcX = double(calculatedOldPosition(1));
       calcY = double(calculatedOldPosition(2));
       for i = 1 : length(relevantOldPositionIndices)
           oldPositionIndex = relevantOldPositionIndices(i);
           oldX = double(oldPositions(:,2,oldPositionIndex));
           oldY = double(oldPositions(:,1,oldPositionIndex));
           
           newD = sqrt((calcX - oldX)^2 + (calcY - oldY)^2);
           
           if newD < d
               d = newD;
               index = oldPositionIndex;
           end
       end
   end
   
   function [searchMask] = createSearchArea(pos, rot, radius, vel_stretch, var_stretch)
       
        imsize = size(of);
        uint8Mask = im2bw(insertShape(uint8(false(imsize)), 'FilledCircle', [pos(1), pos(2), radius]));
        
        [croppedMask, x, y, cw, ch] = cropMask(uint8Mask);
        
        J = imresize(croppedMask, [double(cw) * var_stretch, double(ch) * vel_stretch]);
        J = imrotate(J, double(rot));
        
        off = double(ch) * vel_stretch - double(ch);
        offx = cos(deg2rad(360-rot)) * off/2;
        offy = sin(deg2rad(360-rot)) * off/2;
        
        [J, tx, ty, tw, th] = cropMask(J);
        
        nx = x + (double(cw) - double(tw))/2 - 1 + double(offx);
        ny = y + (double(ch) - double(th))/2 - 1 + double(offy);
        nw = imsize(2) - (nx + tw);
        nh = imsize(1) - (ny + th);
        
        J = padarray(J, double([ny, nx]), 0, 'pre');
        J = padarray(J, double([nh, nw]), 0, 'post');
        
        imsizeJ = size(J);
        
        if imsizeJ(1) > imsize(1)
            J = J(1:imsize(1),:);
        end
        
        if imsizeJ(2) > imsize(2)
            J = J(:, 1:imsize(2));
        end
        
        searchMask = J;
        
   end

    function [croppedMask, x, y, w, h] = cropMask(mask)
        bbox = regionprops(mask, 'BoundingBox');
        x = uint32(bbox(1).BoundingBox(1));
        y = uint32(bbox(1).BoundingBox(2));
        w = uint32(bbox(1).BoundingBox(3));
        h = uint32(bbox(1).BoundingBox(4));
        croppedMask = mask(y:y+h-1, x:x+w-1, : );
    end
end

