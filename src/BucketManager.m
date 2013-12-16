classdef BucketManager 
    %UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    
    properties(Constant = true)
        bucketMap = containers.Map({1,2,3,4,5,6,7,8}, { BlackBucket(), BlueBucket(), BrownBucket(), GreenBucket(), PinkBucket(), RedBucket(), WhiteBucket(), YellowBucket() });
    end
    

    methods (Static = true)
      function [bucket] = getBucket( bucket_index )
         bucket = BucketManager.bucketMap(bucket_index);
      end
   end
    
end