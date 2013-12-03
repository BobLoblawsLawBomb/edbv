function [ dominantBucket ] = dominantBucketColor2( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   @author Maximilian Irro

    bucketList = {  WhiteBucket(), GreenBucket(), BlueBucket(), BrownBucket(),  
                    PinkBucket(), BlackBucket(), YellowBucket(), RedBucket()};
            
    bucketStack = [0,0,0,0,0,0,0,0];
            
%     buckets = cell(8,2);
%     buckets(1,:) = { BlackBucket(), 0};
%     buckets(2,:) = { BlueBucket(),  0};
%     buckets(3,:) = { BrownBucket(), 0};
%     buckets(4,:) = { GreenBucket(), 0};
%     buckets(5,:) = { PinkBucket(),  0};
%     buckets(6,:) = { RedBucket(),   0};
%     buckets(7,:) = { WhiteBucket(), 0};
%     buckets(8,:) = { YellowBucket(),0};
            
    tableMask = im2bw(img,0.000001);

    hsv = rgb2hsv(img);
    hue = hsv(:,:,1);
    sat = hsv(:,:,2);
    val = hsv(:,:,3);
            
    for n=1:7 % there are 7 buckets
        
        bucket = bucketList{n};
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket hue range
        if isa(bucket, 'RedBucket') % red bucket has different evaluation due to hsv hue definition
            hueMask = hue>=bucket.hueMin | hue<=bucket.hueMax; 
        else
            hueMask = hue>=bucket.hueMin & hue<=bucket.hueMax;   
        end
        imshow(hueMask)
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket saturation range
        sat(sat>0)
        imshow(sat)
        bucket.satMax
        satMask = sat<=bucket.satMax;
        %satMask = sat>=bucket.satMin & sat<=bucket.satMax;
        imshow(satMask)
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket value range
        valMask = val>=bucket.valMin & sat<=bucket.valMax;
        imshow(valMask)
        
        % filter every pixel that passes all 3 HSV filters
        bucketPixels = tableMask .* hueMask .* satMask .* valMask;
        class(bucket)
        imshow(bucketPixels)
        
        % count all pixels that are not 0
        % those match the HSV specifications of this color bucket
        pixelCount =  nnz( bucketPixels );
        
        % safe the pixel count for later comparison
        bucketStack(n) = pixelCount;
        
    end
    
    % find the bucket with the most classified pixels
    [maxPixelCount, bucketIndex] = max(bucketStack(:));

    dominantBucket = bucketList{bucketIndex};
end

