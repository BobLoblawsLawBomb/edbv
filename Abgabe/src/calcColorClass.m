function [ result, intens] = calcColorClass( component )
%   Klassifiziert eine Komponente als eine bestimmte Farbe.
%
%   --- INPUT ---
%
%   component
%    Farbbild bei dem alle Bereiche die nicht betrachtet werden sollen auf
%    0 gesetzt, also ausmaskiert worden sind.
%    Zu sehen sein, soll im idealfall nur die Komponente deren Farbe
%    bestimmt werden soll.
%
%   --- OUTPUT ---
%
%   result
%    Ein index der mit dem entsprechenden colorIndex aus einem subtyp von
%    AbstractBucket übereinstimmt. Gibt an in welche Klasse die Komponente
%    eingeteilt wurde.
%
%   intens
%    Ein Wert der angibt wie hoch die varianz über den Hue-Bereich ist,
%    also wie genau die Farben der Komponenten mit einer Position am
%    Hue-Bereich übereinstimmen.
%    Falls dieser Wert 0 ist, wurde keine Farbe erkannt.
%
%
%   @author Andreas Mursch-Radlgruber
% ---------------------------------------------

    debug = false;

    bucketList = {  WhiteBucket(), BlackBucket(), GreenBucket(), PinkBucket(), BlueBucket(), BrownBucket(), YellowBucket(), RedBucket()};
    
    %Zur einfacheren nachjustierung bei der Parametrisierung
    %Könnte auch als input genutzt werden um manuelle Anpassungen bei 
    %videos durch den Benutzer zu ermöglichen.
    hueoffset = 0.025;
    satoffset = -0.025;
    valoffset = 0.05;
    
    %nested function zum ermitteln des buckets basierend auf hue
    function retbucket = getBucket(sidx, bestHue)
        dists = ones([8, 1]);
        for n = sidx : 8
            bucket = bucketList{n};
            buckethue = bucket.meanhue;
            dists(n) = abs(buckethue - bestHue);
            if dists(n) > 0.5
                dists(n) = 1 - dist(n);
            end
        end
        [C,I] = min(dists);
        retbucket = bucketList{I};
    end

    %Nested Function zum checken ob eine Hue im maximalen bereich um den 
    %hue-wert eines buckets ist.
    function within = withinDistance(bestHue, bucket)
        dist = abs(bucket.meanhue - bestHue);
        if dist > 0.5
            dist = 1 - dist;
        end
        if(dist < bucket.huedist)
            within = true;
        else
            within = false;
        end
    end
    
    % cropping the component-matrix to the relevant portion reduces the
    % performance hit by about 95% or 2000 milliseconds (!!) in a testcase 
    % with a typical amount of components.
    %   execution time without cropping: 2200ms
    %   execution time with cropping: 100ms
    
    bbox = regionprops(im2bw(component,0.000001), 'BoundingBox');
    x = uint32(bbox(1).BoundingBox(1));
    y = uint32(bbox(1).BoundingBox(2));
    w = uint32(bbox(1).BoundingBox(3));
    h = uint32(bbox(1).BoundingBox(4));
    croppedComponent = component(y:y+h-1, x:x+w-1, :);
    
    % Grobe Vorgehensweise
    % - Überschüssiges Grün entfernen
    % - dynamic hue-histogram, besten hue wert ermitteln
    % - diesen besten (durchschnitts) hue-wert über distanz zu
    %   bucket-ideal-hue-werten vergleichen
    % - Einfach durchschnittswerte von sättigung und intensität verwenden.
    
    % RGB in HSV Farbraum konvertieren und offsets anwenden.
    hsv_of_comp = rgb2hsv(croppedComponent);
    hue = hsv_of_comp(:,:,1) + hueoffset; 
    sat = hsv_of_comp(:,:,2) + satoffset;
    val = hsv_of_comp(:,:,3) + valoffset;
    
    %vorsichtig gruenen boden entfernen. 
    %Achtung: gruene kugel muss erhalten bleiben
    hue(hue > 0.25 & hue < 0.39 & val > 0.25 & sat > 0.5) = NaN;
    sat(hue > 0.25 & hue < 0.39 & val > 0.25 & sat > 0.5) = NaN;
    val(hue > 0.25 & hue < 0.39 & val > 0.25 & sat > 0.5) = NaN;

    %Falls erhaltener Bereich zu gering ist, ist es wahrscheinlich ein
    %artefakt
    huearea = numel(hue)-sum(isnan(hue(:)));
    if(huearea < 10)
        if(debug)
            disp(['NOTHING (to small) ',num2str(huearea),' < 10']);
        end
        result = bucketList{2};
        intens = 0;
        return;
    end
    
    %LAB Farbraum ermitteln
    hue2 = hue;
    sat2 = sat;
    val2 = val;
    
    hue2(isnan(hue)) = 0;
    sat2(isnan(hue)) = 0;
    val2(isnan(hue)) = 0;
    
    color_data = double(repmat(zeros(size(croppedComponent)), [1 1 3]));
    color_data(:,:,1) = hue2;
    color_data(:,:,2) = sat2;
    color_data(:,:,3) = val2;
    
    colorTransform = makecform('srgb2lab');
    lab_of_comp = applycform(hsv2rgb(color_data), colorTransform);
    
    L = lab_of_comp(:,:,1)/100;
%     A = lab_of_comp(:,:,2)/100;
    B = lab_of_comp(:,:,3)/100;
    
    %Durchschnittliche Sättigung und Intensität bestimmen
    meansat = nanmean(nanmean(sat));
    meanval = nanmean(nanmean(val));
    
    %Summe sehr heller Werte bestimmen.
    highlightsum = sum(sum(L(L>0.9)));
    
    %Analysieren der Hue-Werte
    [hueUniqueList, hueCountList, count, bestHue, var, mcount] = dynamicHistogram(hue, 0.1, 0, 0, 1);
    intens = 1 - var;
    
    if(debug)
        disp(['before b/w:	', num2str(bestHue), '	', num2str(meansat), '	', num2str(meanval), '	', num2str(var), '	', num2str(huearea), '	', num2str(mcount)]);
    end
    
    %Pruefen ob die Kugel weiß ist (Mit hilfe der Lightness des LAB Farbraums)
    if(highlightsum > 8)% && meanval > 0.45 && meansat < 0.65)% && var < 0.075)
        if(mean(mean(B(B>0))) < 0.4)
            if(debug)
                disp('WHITE');
                disp(highlightsum);
                disp(['yellow ',num2str(mean(mean(B(B>0))))]);
            end
            result = bucketList{1};
            return;
        end
    end
    
    %Pruefen ob die Kugel schwarz ist
    if( meanval < 0.33 && meansat > 0.5)% && var < 0.075)
        if(debug)
            disp('BLACK');
        end
        result = bucketList{2};
        return;
    end
    
    %Prüfen der neuen Hue-Werte
    result = getBucket(3, bestHue);
    
    if result.colorIndex == GreenBucket.colorIndex && withinDistance(bestHue, GreenBucket())
        %Checken ob es sich nicht vielleicht doch um andere Buckets handelt
        %wegen Grün/Blau ähnlichkeit
        if ~(withinDistance(bestHue, BlueBucket()) && var > 0.025)
            if meanval > 0.365
                if(debug)
                    disp('GREEN');
                    disp(['green:	', num2str(bestHue), '	', num2str(meansat), '	', num2str(meanval), '	', num2str(var), '	', num2str(huearea), '	', num2str(mcount)]);
                end
                return;
            end
        end
    end
    
    %Da es sich nichtmehr um eine weiße oder schwarze Kugel handeln kann,
    %können entsprechende Werte entfernt werden
    %da es sich nichtmehr um eine gruene Kugel handeln kann, kann alles
    %gruene grob entfernt werden.
    % black | white | green
    hue((val < 0.25 | val > 0.7 & sat < 0.35) | (hue > 0.21 & hue < 0.45)) = NaN;
    sat((val < 0.25 | val > 0.7 & sat < 0.35) | (hue > 0.21 & hue < 0.45)) = NaN;
    val((val < 0.25 | val > 0.7 & sat < 0.35) | (hue > 0.21 & hue < 0.45)) = NaN;
    
    %Analysieren der neuen Hue-Werte
    [hueUniqueList, hueCountList, count, bestHue, var, mcount] = dynamicHistogram(hue, 0.1, 0, 0, 1);
    intens = 1 - var;
    
    %Durchschnittswerte für neue sättingung und intensitäts werte berechnen
    meansat = nanmean(nanmean(sat));
    meanval = nanmean(nanmean(val));
    
    if(debug)
        disp(['after b/w:	', num2str(bestHue), '	', num2str(meansat), '	', num2str(meanval), '	', num2str(var), '	', num2str(huearea), '	', num2str(mcount)]);
    end
    
    %Falls nichts mehr übrig ist, wurde keine farbe erkannt.
    if isnan(mcount) || length(bestHue) == 0
        if(debug)
            disp('NOTHING (no hue)');
        end
        result = bucketList{2};
        intens = 0;
        return;
    end
    
    %Prüfen der neuen Hue-Werte
    result = getBucket(4, bestHue);
    
    %Rot/Pink ähnlichkeit behandeln
    if result.colorIndex == PinkBucket.colorIndex
        if meansat > 0.61
            result = RedBucket();
        end
    elseif result.colorIndex == RedBucket.colorIndex
        if meansat < 0.61
            result = PinkBucket();
        end
    end
    
    %Gelb/Braun/Rot ähnlichkeit behandeln
    if result.colorIndex == YellowBucket.colorIndex
        if withinDistance(bestHue, RedBucket())
            result = RedBucket();
        elseif meanval < 0.52
            result = BrownBucket();
        end
    elseif result.colorIndex == BrownBucket.colorIndex
        if withinDistance(bestHue, RedBucket())
            result = RedBucket();
        elseif meanval > 0.52
            result = YellowBucket();
        end
    end
    
    %TODO: Rot/Gelb/Braun behandeln, im falle das Rot erkannt wird
    
    %TODO: Blau/Grün im falle dass Blau erkannt wird behandeln
    
end

