function [index, vx, vy, vmask, smask] = findOldPosition(oldPositions, newPosition, oldClasses, newClass, intensityMasks, intensityPositions, of, mask_search_radius, position_search_radius, compIgnore)
%   Sucht aus einer liste von Positionen, unter Zuhilfenahme einer Liste von
%   Optical-Flow-Masken und einem OpticalFlow Vektor-Feld, die Position welche 
%   am wahrscheinlichsten die vorgänger Position von newPosition war.
%   Und gibt den index dieser Position im oldPositions Array zurück.
%
%   --- INPUT ---
%
%   oldPositions
%    Liste mit Vorgänger-Positionen. Enthält [x y] einträge.
%
%   newPosition
%    Eine Position [x y], für die eine Vorgänger-Position gesucht werden
%    soll.
%
%   oldClasses (Wird momentan nicht verwendet)
%    Zu jedem Positions-Eintrag in oldPositions eine zugehörige Farbklasse.
%    Indices müssen korrespondieren.
%
%   newClass (Wird momentan nicht verwendet)
%    Die Farbklasse der newPosition.
%   
%   intensityMasks
%    Liste mit Masken die bereiche eingrenzen in denen Bewegungen
%    stattfinden.
%   
%   intensityPositions
%    Liste mit den zugehörigen Positionen (Mittelpunkte) der
%    intensityMasks. Indices müssen korrespondieren.
%
%   of
%    Das Optical-Flow Vektor-Feld.
%
%   mask_search_radius
%    Der Radius um die newPosition innerhalb dessen OpticalFlow Masken als
%    zugehörig zur Position betrachtet werden.
%
%   position_search_radius
%    Der Radius der den Suchbereich, in dem Vorgänger-Positionen aus
%    oldPositions als Kandidaten für Vorgänger der newPosition gewertet
%    werden, grundlegend beeinflusst.
%
%   compIgnore
%    Liste an indices von oldPosition die besagt, dass die oldPositions an
%    den entsprechenden indices nicht berücksichtigt werden sollen.
%   
%   --- OUTPUT ---
%
%   index
%    Der Index aus dem oldPositions Array, von dem behauptet wird, dass er
%    auf die Vorgänger-Position von newPosition verweist.
%    Falls index = 0, bedeutet dass, dass keine Position gefunden wurde,
%    was interpretiert werden kann, als neue Komponente zu der es noch keine 
%    oldPositions gibt.
%
%   vx
%    x-Komponente des gemittelten Geschwindigkeits-Vektor aus dem zugewiesenen 
%    Optical-Flow Bereich für newPosition.
%
%   vy
%    y-Komponente des gemittelten Geschwindigkeits-Vektor aus dem zugewiesenen 
%    Optical-Flow Bereich für newPosition.
%
%   vmask
%    Maske die den Suchbereich für zugehörige Optical-Flow-Masken beinhaltet.
%
%   smask
%    Maske die den Suchbereich für oldPositions beinhaltet.
%
%
%   @author Andreas Mursch-Radlgruber
% ---------------------------------------------
    
    ymaskseachoffset = 0;
    ypossearchoffset = 0;
    
    %Maske für den suchbereich erstellen in dem OpticalFlow-Komponenten
    %gesucht werden sollen, von denen dann ausgegangen werden kann, dass
    %sie einen einfluss auf die geschwindigkeit der Komponente haben.
    
    mask = false(size(of));

    position = [newPosition(1), newPosition(2) + ymaskseachoffset];
    positionWithFactor = position;
    positionWithFactor(3) = mask_search_radius;
    uint8Mask = insertShape(uint8(mask), 'FilledCircle', positionWithFactor);

    circleMask = im2bw(uint8Mask, 0.5);
    
    smask = circleMask;
    
    %Suche relevante Masken indem überprüft wird, ob sich ihr mittelpunkt
    %im suchbereich für of-masken befindet.
    
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
    % gefunden wurde wird in der näheren umgebung der aktuellen position
    % gesucht.
    
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
        
        
        % Verschiebe ursprungspunkt in die entgegengesetzte Richtung des
        % gemittelten Geschwindigkeitsvektor.
        va = abs(vx + vy*i);
        vx = -(vx / s)*70;% * (0.5 + (va/(1 + (va^3)))*2); %skalierung die anfangs stark steigt und bald abfaellt
        vy = -(vy / s)*70;% * (0.5 + (va/(1 + (va^3)))*2);
    end
    
    %Berechne skalierung der Form des elliptischen Suchbereichs in dem 
    %nach der alten Position der Komponente gesucht werden soll
    vel_stretch = 1 + 15*((va*0.65)/(20 + (va^1.75)));%1 + 15*((va*0.5)/(20 + (va^1.6)));%1 + 15*((va*0.43)/(20 + (va^1.3)));%1 + 50*(va/(180 + (va^1.6)));
    var_stretch = 1 + 15*((va*0.5)/(20 + (va^1.6)))*0.1;

    %skalierung der geschwindigkeit, weil der wert sonst so klein ist,
    %das keine verschiebung erfolgt
    nvx = (vx/70)*vel_stretch;
    nvy = (vy/70)*vel_stretch;
    
    %calculatedOldPosition wird verwendet um von gefundenen punkten die
    %entfernung zu dieser vorausgesagten position zu berechnen, der punkt
    %der am nähesten zu dieser Position ist, ist auch am wahrscheinlichsten
    %die vorgänger Komponente
    calculatedOldPosition = [double(newPosition(1)) + nvx, double(newPosition(2)) + nvy ];
    
    %Bewegungrichtung berechnen
    rot = 360 - radtodeg(atan2(nvy, nvx));
    
    pos = [newPosition(1), newPosition(2) + ypossearchoffset ];
    
    radius = position_search_radius;
    
    %Berechne Maske für den elliptischen Suchbereich
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
   %bedeutet, dass ein neues element entdeckt wurde
   
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
   
   %Innere Funktion zum berechnen des elliptischen Suchbereichs.
    function [searchMask] = createSearchArea(pos, rot, radius, vel_stretch, var_stretch)
        %    Berechnet abhängig von den input-parametern eine elliptische
        %    maske welche entgegen der rot-richtung um den vel_stretch faktor - 1
        %    verschoben ist.
        %
        %   --- INPUT ---
        %
        %   pos
        %    Position [x y] an welcher Position im verwendeten Feld die
        %    Maske erstellt werden soll.
        %
        %   rot
        %    Ausrichtung der Ellipse in Grad.
        %
        %   radius
        %    Basis-Radius der Ellipse.
        %
        %   vel_stretch
        %    Faktor um den die Ellipse in die Länge, also in die Richtung
        %    welche durch rot angegeben wird, gedeht werden soll.
        %
        %   var_stretch
        %    Faktor um den die Ellipse in die Breite, also normal zu
        %    Richtung welche durch rot angegeben wird, gedeht werden soll.
        %
        %   --- OUTPUT ---
        %
        %   searchMask
        %    Maske die so groß ist die das verwendete OpticalFlow Feld und
        %    den Bereich maskiert den die durch die input parameter
        %    erzeugte Ellipse abdeckt.
        %
        %
        %   @author Andreas Mursch-Radlgruber
        % ---------------------------------------------
        
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

    %Innere Funktion zum trimmen einer maske auf den relevanten Bereich.
    function [croppedMask, x, y, w, h] = cropMask(mask)
        %   Helperfunktion um eine Maske auf den kleinsten Bereich zu
        %   verkleinern ohne maskeninformationen zu verlieren, also Trimmen
        %   an den Rändern.
        %
        %   --- INPUT ---
        %
        %   mask
        %    Eine 2D binaere Maske
        %
        %   --- OUTPUT ---
        %
        %   croppedMask
        %    Die 2D binaere input Maske, die auf den relevanten Bereich
        %    verkleinert wurde.
        %
        %   x
        %    x komponente der oberen linken ecke der neuen Maske in
        %    relation zur alten.
        %   
        %   y
        %    y komponente der oberen linken ecke der neuen Maske in
        %    relation zur alten.
        %   
        %   w
        %    Breite der neuen Maske.
        %   
        %   h
        %    Böhe der neuen Maske.
        %   
        %   
        %   @author Andreas Mursch-Radlgruber
        % ---------------------------------------------
        
        bbox = regionprops(mask, 'BoundingBox');
        x = uint32(bbox(1).BoundingBox(1));
        y = uint32(bbox(1).BoundingBox(2));
        w = uint32(bbox(1).BoundingBox(3));
        h = uint32(bbox(1).BoundingBox(4));
        croppedMask = mask(y:y+h-1, x:x+w-1, : );
    end
end

