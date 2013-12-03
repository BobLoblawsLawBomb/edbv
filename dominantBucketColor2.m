function [ dominantColor ] = dominantBucketColor2( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   @author Maximilian Irro

    buckets = [ BlackBucket,    0;
                BlueBucket,     0;
                BrownBucket,    0;
                GreenBucket,    0;
                PinkBucket,     0;
                RedBucket,      0;
                WhiteBucket,    0;
                YellowBucket,   0];
            
    tableMask = im2bw(img,0.000001);

    hsv = rgb2hsv(img);
    hue = hsv(:,:,1);
    sat = hsv(:,:,2);
    val = hsv(:,:,3);
            
    for n=1:7 % there are 7 buckets
        
        bucket = buckets(n,1);
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket hue range
        if isa(bucket,RedBucket) % red bucket has different evaluation due to hsv hue definition
            hueMask = hue>bucket.hueMin | hue<bucket.hueMax; 
        else
            hueMask = hue>bucket.hueMin & hue<bucket.hueMax;   
        end
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket saturation range
        satMask = sat>bucket.satMin & sat<bucket.satMax;
        
        % make a mask that lets only pass those pixels 
        % within the specified bucket value range
        valMask = val>bucket.valMin & sat<bucket.valMax;
        
        % filter every pixel that passes all 3 HSV filters
        bucketPixels = tableMask .* hueMask .* satMask .* valMask;
        
        % count all pixels that are not 0
        % those match the HSV specifications of this color bucket
        pixelCount =  nnz( bucketPixels );
        
        % safe the pixel count for later comparison
        buckets(n,2) = pixelCount;
        
    end
    
    ??? [colorElementCount, bucketIndex] = max(buckets(:,2));

    dominantColor = hsv (oder rgb?) von dominater farbe
end

