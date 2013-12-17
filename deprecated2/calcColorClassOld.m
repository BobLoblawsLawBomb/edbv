function [ result, intens] = calcColorOld( component )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   
%   @author Maximilian Irro
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

    debug = false;
    intens = 1;

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
    
%     %gruenen boden wegschneiden
%     hue(hue > 0.25 & hue < 0.4) = NaN;
%     sat(hue > 0.25 & hue < 0.4) = NaN;
%     val(hue > 0.25 & hue < 0.4) = NaN;
%     
%     %ganze schwarzes wegwerfen
% %     hue(val <= 0) = NaN;
% %     sat(val <= 0) = NaN;
% %     val(val <= 0) = NaN;
%     
%     color_data = double(repmat(zeros(size(croppedComponent)), [1 1 3]));
%     color_data(:,:,1) = hue;
%     color_data(:,:,2) = sat;
%     color_data(:,:,3) = val;
%     
%     color_data = hsv2rgb(color_data);
    
%     figure(75);
%     imshow(color_data);
    
    for n=1:8 % there are 8 buckets
        
        bucket = bucketList{n};
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket hue range
        if bucket.colorIndex == 6 %isa(bucket, 'RedBucket') % red bucket has different evaluation due to hsv hue definition
            hueMask = hue>=bucket.hueMin | hue<=bucket.hueMax;
        elseif bucket.colorIndex == 5 %isa(bucket, 'PinkBucket')
            hueMask = hue>=bucket.hueMin | hue<=bucket.hueMax;
        else
            hueMask = hue>=bucket.hueMin & hue<=bucket.hueMax;   
        end
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket saturation range
        satMask = sat>=bucket.satMin & sat<=bucket.satMax;

        % make a mask that lets only pass those pixels 
        % within the specified bucket value range
        valMask = val>=bucket.valMin & sat<=bucket.valMax;

        % filter every pixel that passes all 3 HSV filters
        bucketPixels = compMask .* hueMask .* satMask .* valMask;

        % count all pixels that are not 0
        % those match the HSV specifications of this color bucket
        pixelCount =  nnz( bucketPixels );
        
        % safe the pixel count for later comparison
        bucketStack(n) = pixelCount;
        
    end
    
    for n=1:8
        fprintf('%s\t %i \n', class(bucketList{n}),bucketStack(n));
    end
    
    % find the bucket with the most classified pixels
    [~, bucketIndex] = max(bucketStack(:));

    result = bucketList{bucketIndex};
end

