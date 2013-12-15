function [ result, result2, intens] = componentColorClass_modified( component )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   @author Maximilian Irro

    debug = false;

    bucketList = {  WhiteBucket(), PinkBucket(), BlueBucket(), BrownBucket(), GreenBucket(), BlackBucket(), YellowBucket(), RedBucket()};
            
    bucketStack = [0,0,0,0,0,0,0,0];
    
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

    compMask = im2bw(croppedComponent, 0.000001);
    
    hsv_of_comp = rgb2hsv(croppedComponent);
    hue = hsv_of_comp(:,:,1); 
    sat = hsv_of_comp(:,:,2);
    val = hsv_of_comp(:,:,3);
    
    %gruenen boden wegschneiden
    hue(hue > 0.25 & hue < 0.4) = NaN;
    sat(hue > 0.25 & hue < 0.4) = NaN;
    val(hue > 0.25 & hue < 0.4) = NaN;
    
    %ganze schwarzes wegwerfen
%     hue(val <= 0) = NaN;
%     sat(val <= 0) = NaN;
%     val(val <= 0) = NaN;
    
    color_data = double(repmat(zeros(size(croppedComponent)), [1 1 3]));
    color_data(:,:,1) = hue;
    color_data(:,:,2) = sat;
    color_data(:,:,3) = val;
    
    color_data = hsv2rgb(color_data);
    
%     figure(75);
%     imshow(color_data);
    
    meansat = nanmean(nanmean(sat));
    meanval = nanmean(nanmean(val));
    
    [hueUniqueList, hueCountList, count] = dynamicHistogram(hue, 0.1, 0, 0, 1);
    [bestcount, I] = max(hueCountList);
    bestHue = hueUniqueList(I);
    intens = bestcount / count;
    
    if(debug)
%     if(meanval > 0.35 && meansat < 0.45)
        disp([num2str(bestHue), '   ', num2str(meansat), '   ', num2str(meanval), '   ', num2str(numel(hue)), '   ', num2str(intens)]);
%     end
    end
        
    blackthreshold = 0.5;
    whitethreshold = 0.7;
    
%     disp((1-meansat)+meanval);
%     disp((1-meanval)+meansat);
    
    if((1-meansat)+meanval < blackthreshold)%bei hohem sat und niedrigem val, sollte es black sein
        if(debug)
            disp('BLACK');
        end
        result = bucketList{6};
        result2 = bucketList{6};
        return;
    end
    
    if max(max(max(color_data))) == 0
        if(debug)
            disp('NOTHING');
        end
        if meanval > 0.39 && meansat < 0.4
            if(debug)
                disp('--> WHITE');
            end
            result = bucketList{1};
            result2 = bucketList{1};
            intens = 1;
        else
            result = bucketList{6};
            result2 = bucketList{6};
            intens = 0;
        end
        if(debug)
            disp([num2str(bestHue), '   ', num2str(meansat), '   ', num2str(meanval), '   ', num2str(numel(hue)), '   ', num2str(intens)]);
        end
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
    
    dists = ones([8, 1]);
    for n = 1 : 8
        bucket = bucketList{n};
        minhue = bucket.hueMinB;
        maxhue = bucket.hueMaxB;
        if minhue > maxhue
            minhue = minhue - 1;
        end
        meanhue = nanmean([minhue, maxhue]);
        dists(n) = abs(meanhue - bestHue);
        if dists(n) > 0.5
            if(meanhue > bestHue)
                meanhue = meanhue - 1;
            else
                bestHue = bestHue - 1;
            end
            dists(n) = abs(meanhue - bestHue);
        end
    end
    [C,I] = min(dists);
    result2 = bucketList{I};
%     disp(['winning dist: ', num2str(C)]);
    
    if(meanval > 0.38 && meansat < 0.4 && intens > 0.8)%bei hohem val und niedrigem sat sollte es white sein
        if(debug)
            disp('WHITE');
            disp([num2str(bestHue), '   ', num2str(meansat), '   ', num2str(meanval), '   ', num2str(numel(hue)), '   ', num2str(intens)]);
        end
        result = bucketList{1};
        result2 = bucketList{1};
        intens = 1;
        return;
    end
    
    if(debug)
        if(result2.colorIndex == WhiteBucket.colorIndex)
            disp('white');
        end
        if(result2.colorIndex == BlackBucket.colorIndex)
            disp('black');
        end
        if(result2.colorIndex == GreenBucket.colorIndex)
            disp('green');
        end
        if(result2.colorIndex == BlueBucket.colorIndex)
            disp('blue');
        end
    end
    
    changed = false;
    
    if ~changed && result2.colorIndex == YellowBucket.colorIndex %could be brown or red
        if(debug)
            disp('yellow');
        end
        if meanval < 0.31
            result2 = RedBucket();
            if(debug)
                disp('--> red');
            end
        elseif(meansat > 0.5 && meanval < 0.38)
            result2 = BrownBucket();
            if(debug)
                disp('--> brown');
            end
        end
        changed = true;
    end
    
    if ~changed && result2.colorIndex == BrownBucket.colorIndex %could be yellow or red
        if(debug)
            disp('brown');
        end
        if meansat > 0.5 && meanval > 0.4
            result2 = YellowBucket();
            if(debug)
                disp('--> yellow');
            end
        elseif meansat > 0.49 && meanval < 0.3
            result2 = RedBucket();
            if(debug)
                disp('--> red');
            end
        else
            disp(meanhue);
            disp([num2str(bestHue), '   ', num2str(meansat), '   ', num2str(meanval), '   ', num2str(numel(hue)), '   ', num2str(intens)]);
        end
        changed = true;
    end
    
    if ~changed && result2.colorIndex == RedBucket.colorIndex %could be brown or pink (not likely)
        if(debug)
            disp('red');
        end
        changed = true;
    end
    
    if ~changed && result2.colorIndex == PinkBucket.colorIndex %could be red
        if(debug)
            disp('pink');
        end
        if meanval < 0.4
            result2 = RedBucket();
            if(debug)
                disp('--> red');
            end
        end
        changed = true;
    end
    
    result = result2;
    
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

