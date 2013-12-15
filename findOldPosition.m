function [index, vx, vy, vmask, smask] = findOldPosition( oldPositions, newPosition, oldClasses, newClass, intensityMasks, intensityPositions, of, mask_search_radius, position_search_radius, compIgnore)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    %TODO:
    %Bei geschwindigkeit Suchkreis in die Länge zeihen (in bewegungsrichtung)
    %Bei streuung (verwende dynamisches Histogramm), Suchkreis in die
    %Breite ziehen (normal auf die bewegungsrichtung)
    
    ymaskseachoffset = 0; %muss scheinbar etwas weiter unten (positiver) als possearchoffset sein
    ypossearchoffset = 0; % -2 % -4
    
    mask = false(size(of));

    position = [newPosition(1), newPosition(2) + ymaskseachoffset];
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
%     disp(iPosSize(4));
    
    for i = 1 : iPosSize(3)
        
        j = 1;
        
        for k = 1 : iPosSize(4)
            
%             disp([num2str(i),' ',num2str(k),' ',num2str(iPosSize(1)),' ',num2str(iPosSize(2))]);
            point = intensityPositions(:,:,i,k);
%             disp([num2str(i),' ',num2str(k),' ',num2str(point(1)),' ',num2str(point(2))]);
            
            if point(1) == -1 && point(2) == -1
                continue
            end
            
%             figure(40)
%             dispCircleMask = double(repmat(circleMask, [1 1 3]));
%             dispCircleMask(point(1), point(2), 1) = 1;
%             dispCircleMask(point(1), point(2), 2) = 0;
%             dispCircleMask(point(1), point(2), 3) = 0;
%             imshow(dispCircleMask);
            
            if isPointWithinMask(point, circleMask)
                foundIntensityPoints(:,:,l,j) = point;
                foundIntensityMasks{l,j} = intensityMasks(:,:,i,k);
%                 disp([num2str(i),' ',num2str(k),' ',num2str(point(1)),' ',num2str(point(2))]);
%                 disp('found point:');
%                 disp(['at ', num2str(l),' ', num2str(j)]);
%                 disp(point);
                j = j + 1;
            end
        end
        
        l = l + 1;
    end
    
%     disp('end search points:');
    
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
        vx = -(vx / s)*70;% * (0.5 + (va/(1 + (va^3)))*2); %skalierung die anfangs stark steigt und bald abfaellt
        vy = -(vy / s)*70;% * (0.5 + (va/(1 + (va^3)))*2);
%         vx = -(vx / s)*200 * (0.5 + (va/(0.5 + (va^4)))*2); %skalierung die anfangs stark steigt und bald abfaellt
%         vy = -(vy / s)*200 * (0.5 + (va/(0.5 + (va^4)))*2);
%         vx = -(vx / s)*100 * (0.5 + ((va*4)/(0.25 + (va)))*(1/exp(va^4))); %skalierung die anfangs stark steigt und bald abfaellt
%         vy = -(vy / s)*100 * (0.5 + ((va*4)/(0.25 + (va)))*(1/exp(va^4)));
    end
    
%     if va ~= 0
%         disp([num2str(vx), ' ',num2str(vy), ' = ', num2str(va)]);
%     end
    
    %testhalber ohne verschiebung
    nvx = vx;
    nvy = vy;
    
    % Verschiebe ursprungspunkt in die entgegengesetzte Richtung des
    % gemittelten Geschwindigkeitsvektor.
    
    calculatedOldPosition = [double(newPosition(1)) + nvx, double(newPosition(2)) + nvy ];
    
%     disp('calculatedOldPosition');
%     disp(calculatedOldPosition);
    
    %Spanne kreis um calculatedOldPosition 
    
    mask2 = false(size(of));

    position2 = [calculatedOldPosition(1), calculatedOldPosition(2) + ypossearchoffset];
    position2WithFactor = position2;
    %TODO seach_radius mit geschwindigkeit skalieren, damit er falls keine
    %of-maske vorhanden ist nicht fälschlicherweise eine verbindung zu
    %einer nahen anderen komponente festlegt
    position2WithFactor(3) = position_search_radius + 50*(va/(180 + (va^1.6)));%+ 50*(va/(200 + (va^1.8)))[hat gut funktioniert];%+ 2*(va/(0.5 + (va^3)));% + 1*(va/3); %+ 1*(va/3);
    uint8Mask = insertShape(uint8(mask2), 'FilledCircle', position2WithFactor);
    
    if va > 4
        disp(['GESCHWINDIGKEIT_VA: ',num2str(va)]);
    end
    
    circleMask2 = im2bw(uint8Mask,0.5);
    vmask = circleMask2; %for debugging
    
   %Suche darin nach eventuell vorhandenen oldPositions und speichere deren
   %indices
%    disp('search relevant old positions');
   
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
   
%    disp(['calculated: ', num2str(calculatedOldPosition(1)), '  ', num2str(calculatedOldPosition(2))]);
   
   index = 0;
   
   if exist('relevantOldPositionIndices', 'var') == 1
       d = inf;
       calcX = double(calculatedOldPosition(1));
       calcY = double(calculatedOldPosition(2));
       for i = 1 : length(relevantOldPositionIndices)
           oldPositionIndex = relevantOldPositionIndices(i);
           oldX = double(oldPositions(:,2,oldPositionIndex));
           oldY = double(oldPositions(:,1,oldPositionIndex));
           
%            disp(['relevant: ', num2str(oldX), '  ', num2str(oldY)]);
           
           newD = sqrt((calcX - oldX)^2 + (calcY - oldY)^2);
           
           if newD < d
               d = newD;
               index = oldPositionIndex;
           end
       end
%        disp(['picked: ', num2str(oldPositions(:,2,index)), '  ', num2str(oldPositions(:,1,index))]);
   end
   
end

