function [ result ] = componentColorClass( component )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   @author Maximilian Irro

    bucketList = {  WhiteBucket(), PinkBucket(), BlueBucket(), BrownBucket(),  
                    GreenBucket(), BlackBucket(), YellowBucket(), RedBucket()};
            
    bucketStack = [0,0,0,0,0,0,0,0];
    
    %croping the component-matrix to the relevant portion reduces the
    %performance hit by about 95% or 2000 milliseconds!!
    %  execution time without cropping: 2200ms
    %  execution time with cropping: 100ms
    
    bbox = regionprops(im2bw(component,0.000001), 'BoundingBox');
    x = uint32(bbox.BoundingBox(1));
    y = uint32(bbox.BoundingBox(2));
    w = uint32(bbox.BoundingBox(3));
    h = uint32(bbox.BoundingBox(4));
    croppedComponent = component(y:y+h, x:x+w, :);
    
    compMask = im2bw(croppedComponent, 0.000001);
    
    hsv = rgb2hsv(croppedComponent);
    hue = hsv(:,:,1); 
    sat = hsv(:,:,2);
    val = hsv(:,:,3);
    
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
%         bucketPixels = tableMask .* hueMask .* satMask .* valMask;
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
    
    % find the bucket with the most classified pixels
    [~, bucketIndex] = max(bucketStack(:));

    result = bucketList{bucketIndex};
end

