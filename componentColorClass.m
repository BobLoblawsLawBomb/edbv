function [ result ] = componentColorClass( component )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   @author Maximilian Irro

    bucketList = {  WhiteBucket(), PinkBucket(), BlueBucket(), BrownBucket(),  
                    GreenBucket(), BlackBucket(), YellowBucket(), RedBucket()};
            
    bucketStack = [0,0,0,0,0,0,0,0];
           
    imshow(component)
    tableMask = im2bw(component,0.000001);
    imshow(tableMask)
    
    hsv = rgb2hsv(component);
    hue = hsv(:,:,1);
    sat = hsv(:,:,2);
    val = hsv(:,:,3);
            
    for n=1:8 % there are 8 buckets
        
        bucket = bucketList{n};
%         class(bucket)
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket hue range
        if isa(bucket, 'RedBucket') % red bucket has different evaluation due to hsv hue definition
            hueMask = hue>=bucket.hueMin | hue<=bucket.hueMax;
        elseif isa(bucket, 'PinkBucket')
            hueMask = hue>=bucket.hueMin | hue<=bucket.hueMax;
        else
            hueMask = hue>=bucket.hueMin & hue<=bucket.hueMax;   
        end
        
%         imshow(hueMask)
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket saturation range
        
%         imshow(sat)
%         sat(sat>0)
%         bucket.satMax
        satMask = sat>=bucket.satMin & sat<=bucket.satMax;
%         imshow(satMask)
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket value range
        valMask = val>=bucket.valMin & sat<=bucket.valMax;
%         val(val>0.5)
%         imshow(valMask)
        
        % TEST
%         if isa(bucket, 'RedBucket')
%             sat(sat>0.3)
%             imshow(sat)
%             
%             val(val>0.7)
%             imshow(valMask)
%         end
        
        % filter every pixel that passes all 3 HSV filters
        bucketPixels = tableMask .* hueMask .* satMask .* valMask;
%         imshow(bucketPixels)
        
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
    [maxPixelCount, bucketIndex] = max(bucketStack(:));

    result = bucketList{bucketIndex};
end

