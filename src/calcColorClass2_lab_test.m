function [ result, intens] = calcColorClass2( component )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   
%   @author Maximilian Irro
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

    debug = true;

    bucketList = {  WhiteBucket(), BlackBucket(), GreenBucket(), PinkBucket(), BlueBucket(), BrownBucket(), YellowBucket(), RedBucket()};
    
    hueoffset = 0.025;
    satoffset = -0.025;
    valoffset = 0;
    
%     function hue = getHue(bucket)
%         hue = bucket.meanhue + hueoffset;
%     end
    
    %nested function zum ermitteln des buckets basierend auf hue
    function retbucket = getBucket(sidx, bestHue)
        dists = ones([8, 1]);
        for n = sidx : 8
            bucket = bucketList{n};
            buckethue = bucket.meanhue;
            dists(n) = abs(buckethue - bestHue);
            if dists(n) > 0.5
                dists(n) = 1 - dist(n);
%                 if(buckethue > bestHue)
%                     buckethue = buckethue - 1;
%                 else
%                     bestHue = bestHue - 1;
%                 end
%                 dists(n) = abs(buckethue - bestHue);
            end
        end
        [C,I] = min(dists);
        retbucket = bucketList{I};
    end

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
    
%     bucketStack = [0,0,0,0,0,0,0,0];
    
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
%     disp(size(component));
%     disp([num2str(x),' ',num2str(y),' ',num2str(w),' ',num2str(h)]);
    croppedComponent = component(y:y+h-1, x:x+w-1, :);
    
    % remove green from the borders
    
    % make dynamic hue-histogram, pick for highest value the bucket
    
    % calculate average over region and check only for averages

%     compMask = im2bw(croppedComponent, 0.000001);
    
    hsv_of_comp = rgb2hsv(croppedComponent);
    hue = hsv_of_comp(:,:,1) + hueoffset; 
    sat = hsv_of_comp(:,:,2) + satoffset;
    val = hsv_of_comp(:,:,3) + valoffset;
    
    %vorsichtig gruenen boden entfernen. 
    %Achtung: gruene kugel muss erhalten bleiben
    hue(hue > 0.25 & hue < 0.39 & val > 0.25 & sat > 0.5) = NaN;
    sat(hue > 0.25 & hue < 0.39 & val > 0.25 & sat > 0.5) = NaN;
    val(hue > 0.25 & hue < 0.39 & val > 0.25 & sat > 0.5) = NaN;

    huearea = numel(hue)-sum(isnan(hue(:)));
    
    if(huearea < 10)
        if(debug)
            disp(['NOTHING (to small) ',num2str(huearea),' < 10']);
        end
        result = bucketList{2};
        intens = 0;
        return;
    end
    
    %ganze schwarzes wegwerfen
%     hue(val <= 0) = NaN;
%     sat(val <= 0) = NaN;
%     val(val <= 0) = NaN;
    
%     figure(74);
%     imshow(component);

    color_data = double(repmat(zeros(size(croppedComponent)), [1 1 3]));
    color_data(:,:,1) = hue;
    color_data(:,:,2) = sat;
    color_data(:,:,3) = val;
    
    color_data = hsv2rgb(color_data);
    
    fig = figure(75);
    set(fig, 'name', 'before');
    imshow(color_data);
    
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
%     lab_of_comp = applycform(hsv2rgb(color_data), colorTransform);
    lab_of_comp = applycform(double(croppedComponent)/255, colorTransform);
    L = lab_of_comp(:,:,1)/100;
    A = lab_of_comp(:,:,2)/100;
    B = lab_of_comp(:,:,3)/100;
    
%     disp(L);
%     
%     fig = figure(77);
%     set(fig, 'name', 'L');
%     imshow(L);
%     fig = figure(78);
%     set(fig, 'name', 'A');
%     imshow(A);
%     fig = figure(79);
%     set(fig, 'name', 'B');
%     imshow(B);
    
    meansat = nanmean(nanmean(sat));
    meanval = nanmean(nanmean(val));
    highlightsum = sum(sum(L(L>0.9)));
    
%     [hueUniqueList, hueCountList, count, bestHue, var, mcount] = dynamicHistogram((A+1)/2, 0.1, 0, NaN, NaN);
    
%     disp(['Light: ', num2str(mean(mean(L(L>0))))]);
%     disp(['Green: ', num2str(mean(mean(A(A<0))))]);
%     disp(['Magenta: ', num2str(mean(mean(A(A>0))))]);
%     disp(['Blue: ', num2str(mean(mean(B(B<0))))]);
%     disp(['Yellow: ', num2str(mean(mean(B(B>0))))]);
%     disp(['Light: ', num2str(mean(mean(L(L~=0))))]);
%     disp(['Green/Magenta: ', num2str(mean(mean(A(A~=0))))]);
%     disp(['Blue/Yellow: ', num2str(mean(mean(B(B~=0))))]);
    
    mL = mean(mean(L(L~=0)));
    mA = mean(mean(A(A~=0)));
    mB = mean(mean(B(B~=0)));

    disp([num2str(mL),'	', num2str(mA),'	', num2str(mB)]);
    
    clear result;
    
    if mL > 0.15
        if mL < 0.25
            if mA < -0.25
                if mB < 0.1
                    %BLACK, BLUE
                elseif mB > 0.2
                    if mB < 0.3
                        %BROWN, GREEN
                    else
                        %BROWN
                        result = BrownBucket();
                    end
                else
                    %GREEN
                    result = GreenBucket();
                end
            elseif mA < -0.1
                if mB < 0.1
                    %BLACK, BLUE
                elseif mB > 0.2
                    %BROWN
                    result = BrownBucket();
                end
            elseif mB > 0.15
                %RED
                result = RedBucket();
            end
        elseif mL < 0.41
            if mA < -0.25
                if mB < 0.1
                    %BLUE
                    result = BlueBucket();
                elseif mB > 0.2
                    if mB < 0.3
                        %BROWN, GREEN
                    else
                        %BROWN
                        result = BrownBucket();
                    end
                elseif mB < 0.3
                    %GREEN
                    result = GreenBucket();
                end
            elseif mA < -0.1
                if mB < 0.1
                    %BLUE
                    result = BlueBucket();
                elseif mB > 0.2
                    %BROWN
                    result = BrownBucket();
                end
            elseif mB > 0.15
                %RED
                result = RedBucket();
            end
        else
            if mL < 0.5
                if mA < -0.25
                    if mB > 0.1 && mB < 0.3
                        %GREEN
                        result = GreenBucket();
                    end
                elseif mA < -0.1
                    if mB < 0.1
                        %BLUE, BROWN
                    elseif mB < 0.2
                        %BROWN
                        result = BrownBucket();
                    end
                elseif mB > 0.15 && mB < 0.35
                    %PINK
                    result = PinkBucket();
                end
            elseif mL < 0.6
                if mA < -0.25
                    if mB > 0.1 && mB < 0.3
                        %GREEN
                        result = GreenBucket();
                    end
                elseif mA < -0.1
                    if mB > 0.2
                        %BROWN
                        result = BrownBucket();
                    end
                elseif mB > 0.15 && mB < 0.35
                    %PINK
                    result = PinkBucket();
                end
            elseif mL > 0.6
                if mA > -0.1
                    if mA < 0
                        if mB > 0.15
                            if mB < 0.35
                                %WHITE, PINK
                            else
                                %YELLOW
                                result = YellowBucket();
                            end
                        elseif mB < 0.35
                            %WHITE
                            result = WhiteBucket();
                        end
                    elseif mB > 0.15 && mB < 0.35
                        %PINK
                        result = PinkBucket();
                    end
                elseif mA < 0
                    if mB < 0.35
                        %WHITE
                        result = WhiteBucket();
                    else
                        %YELLOW
                        result = YellowBucket();
                    end
                end
            end
        end
    else
        if mA < -0.25
            if mB < 0.1
                %BLACK, BLUE
            elseif mB > 0.2
                if mB < 0.3
                    %BROWN, GREEN
                else
                    %BROWN
                    result = BrownBucket();
                end
            else
                %GREEN
                result = GreenBucket();
            end
        elseif mA < -0.1
            if mB < 0.1
                %BLACK, BLUE
            elseif mB > 0.2
                %BROWN
                result = BrownBucket();
            end
        end
    end
    
    if exist('result', 'var') ~= 0
        intens = 1;
        return;
    else
        if(debug)
            disp('NOTHING (no category)');
        end
        result = bucketList{2};
        intens = 0;
        return;
    end
    
    
%     disp(highlightsum);
    
    %Analysieren der Hue-Werte
    [hueUniqueList, hueCountList, count, bestHue, var, mcount] = dynamicHistogram(hue, 0.1, 0, 0, 1);
    intens = 1 - var;
    
    if(debug)
%         disp(['before b/w:	', num2str(bestHue), '	', num2str(meansat), '	', num2str(meanval), '	', num2str(var), '	', num2str(huearea), '	', num2str(mcount)]);
    end
    
    %Pruefen ob die Kugel weiß ist
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
    if(meanval < 0.3 && meansat > 0.5 && var < 0.075)
        if(debug)
            disp('BLACK');
        end
        result = bucketList{2};
        return;
    end
    
    %Analysieren der neuen Hue-Werte
%     [hueUniqueList, hueCountList, count, bestHue, var, mcount] = dynamicHistogram(hue, 0.1, 0, 0, 1);
%     intens = 1 - var;
    
    result = getBucket(3, bestHue);
    
    if result.colorIndex == GreenBucket.colorIndex && withinDistance(bestHue, GreenBucket())
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
%     hue(val < 0.25 | val > 0.9 & sat < 0.35) = NaN;
%     sat(val < 0.25 | val > 0.9 & sat < 0.35) = NaN;
%     val(val < 0.25 | val > 0.9 & sat < 0.35) = NaN;
    
    %da es sich nichtmehr um eine gruene Kugel handeln kann, kann alles
    %gruene grob entfernt werden.
    % black | white | green
    hue((val < 0.25 | val > 0.7 & sat < 0.35) | (hue > 0.21 & hue < 0.45)) = NaN;
    sat((val < 0.25 | val > 0.7 & sat < 0.35) | (hue > 0.21 & hue < 0.45)) = NaN;
    val((val < 0.25 | val > 0.7 & sat < 0.35) | (hue > 0.21 & hue < 0.45)) = NaN;
    
    %Analysieren der neuen Hue-Werte
    [hueUniqueList, hueCountList, count, bestHue, var, mcount] = dynamicHistogram(hue, 0.1, 0, 0, 1);
    intens = 1 - var;
    
%     color_data = double(repmat(zeros(size(croppedComponent)), [1 1 3]));
%     color_data(:,:,1) = hue;
%     color_data(:,:,2) = sat;
%     color_data(:,:,3) = val;
%     
%     color_data = hsv2rgb(color_data);
%     
%     fig = figure(76);
%     set(fig, 'name', 'after');
%     imshow(color_data);
    
    meansat = nanmean(nanmean(sat));
    meanval = nanmean(nanmean(val));
    
    if(debug)
%         disp(['after b/w:	', num2str(bestHue), '	', num2str(meansat), '	', num2str(meanval), '	', num2str(var), '	', num2str(huearea), '	', num2str(mcount)]);
    end
    
%     if max(max(max(color_data))) == 0 || length(bestHue) == 0
    if isnan(mcount) || length(bestHue) == 0
        if(debug)
            disp('NOTHING (no hue)');
        end
        result = bucketList{2};
        intens = 0;
%         if meanval > 0.39 && meansat < 0.4
%             if(debug)
%                 disp('--> WHITE');
%             end
%             result = bucketList{1};
%             result2 = bucketList{1};
%             intens = 1;
%         else
%             result = bucketList{6};
%             result2 = bucketList{6};
%             intens = 0;
%         end
%         if(debug)
%             disp([num2str(bestHue), '   ', num2str(meansat), '   ', num2str(meanval), '   ', num2str(numel(hue)), '   ', num2str(intens)]);
%         end
        return;
    end
    
%     bbox2 = regionprops(im2bw(color_data,0.000001), 'BoundingBox');
%     x = uint32(bbox2(1).BoundingBox(1));
%     y = uint32(bbox2(1).BoundingBox(2));
%     w = uint32(bbox2(1).BoundingBox(3));
%     h = uint32(bbox2(1).BoundingBox(4));
%     croppedComponent = color_data(y:y+h, x:x+w, :);
%     
%     figure(76);
%     imshow(croppedComponent);

    result = getBucket(4, bestHue);
    
    if result.colorIndex == PinkBucket.colorIndex
        if meansat > 0.61
            result = RedBucket();
        end
    elseif result.colorIndex == RedBucket.colorIndex
        if meansat < 0.61
            result = PinkBucket();
        end
    end
    
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
    
%     disp(['winning dist: ', num2str(C)]);
    
%     if(meanval > 0.38 && meansat < 0.4 && intens > 0.8)%bei hohem val und niedrigem sat sollte es white sein
%         if(debug)
%             disp('WHITE');
%             disp([num2str(bestHue), '   ', num2str(meansat), '   ', num2str(meanval), '   ', num2str(numel(hue)), '   ', num2str(intens)]);
%         end
%         result = bucketList{1};
%         result2 = bucketList{1};
%         intens = 1;
%         return;
%     end
%     
%     if(debug)
%         if(result2.colorIndex == WhiteBucket.colorIndex)
%             disp('white');
%         end
%         if(result2.colorIndex == BlackBucket.colorIndex)
%             disp('black');
%         end
%         if(result2.colorIndex == GreenBucket.colorIndex)
%             disp('green');
%         end
%         if(result2.colorIndex == BlueBucket.colorIndex)
%             disp('blue');
%         end
%     end
%     
%     changed = false;
%     
%     if ~changed && result2.colorIndex == YellowBucket.colorIndex %could be brown or red
%         if(debug)
%             disp('yellow');
%         end
%         if meanval < 0.31
%             result2 = RedBucket();
%             if(debug)
%                 disp('--> red');
%             end
%         elseif(meansat > 0.5 && meanval < 0.38)
%             result2 = BrownBucket();
%             if(debug)
%                 disp('--> brown');
%             end
%         end
%         changed = true;
%     end
%     
%     if ~changed && result2.colorIndex == BrownBucket.colorIndex %could be yellow or red
%         if(debug)
%             disp('brown');
%         end
%         if meansat > 0.5 && meanval > 0.4
%             result2 = YellowBucket();
%             if(debug)
%                 disp('--> yellow');
%             end
%         elseif meansat > 0.49 && meanval < 0.3
%             result2 = RedBucket();
%             if(debug)
%                 disp('--> red');
%             end
%         else
%             if(debug)
%                 disp(buckethue);
%                 disp([num2str(bestHue), '   ', num2str(meansat), '   ', num2str(meanval), '   ', num2str(numel(hue)), '   ', num2str(intens)]);
%             end
%         end
%         changed = true;
%     end
%     
%     if ~changed && result2.colorIndex == RedBucket.colorIndex %could be brown or pink (not likely)
%         if(debug)
%             disp('red');
%         end
%         changed = true;
%     end
%     
%     if ~changed && result2.colorIndex == PinkBucket.colorIndex %could be red
%         if(debug)
%             disp('pink');
%         end
%         if meanval < 0.4
%             result2 = RedBucket();
%             if(debug)
%                 disp('--> red');
%             end
%         end
%         changed = true;
%     end
    
%     for n=1:8 % there are 8 buckets
%         
%         bucket = bucketList{n};
%         
%         % make a mask that lets only pass those pixels 
%         % within the specified bucket hue range
%         if bucket.colorIndex == 6 %isa(bucket, 'RedBucket') % red bucket has different evaluation due to hsv hue definition
%             hueMask = hue>=bucket.hueMin | hue<=bucket.hueMax;
%         elseif bucket.colorIndex == 5 %isa(bucket, 'PinkBucket')
%             hueMask = hue>=bucket.hueMin | hue<=bucket.hueMax;
%         else
%             hueMask = hue>=bucket.hueMin & hue<=bucket.hueMax;   
%         end
%         
%         % make a mask that lets only pass those pixels 
%         % within the specified bucket saturation range
%         satMask = sat>=bucket.satMin & sat<=bucket.satMax;
% 
%         % make a mask that lets only pass those pixels 
%         % within the specified bucket value range
%         valMask = val>=bucket.valMin & sat<=bucket.valMax;
% 
%         % filter every pixel that passes all 3 HSV filters
%         bucketPixels = compMask .* hueMask .* satMask .* valMask;
% 
%         % count all pixels that are not 0
%         % those match the HSV specifications of this color bucket
%         pixelCount =  nnz( bucketPixels );
%         
%         % safe the pixel count for later comparison
%         bucketStack(n) = pixelCount;
%         
%     end
    
%     for n=1:8
%         fprintf('%s\t %i \n', class(bucketList{n}),bucketStack(n));
%     end
%     
%     % find the bucket with the most classified pixels
%     [~, bucketIndex] = max(bucketStack(:));
% 
%     result = bucketList{bucketIndex};
end

