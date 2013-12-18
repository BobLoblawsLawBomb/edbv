classdef BucketManager 
%   Stellt funktionalität bereit um von einem bucket index direkt auf die
%   entsprechende Bucket-Klasse schließen zu können.
%   
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------
    
    properties(Constant = true)
        bucketMap = containers.Map({1,2,3,4,5,6,7,8}, { BlackBucket(), BlueBucket(), BrownBucket(), GreenBucket(), PinkBucket(), RedBucket(), WhiteBucket(), YellowBucket() });
    end
    

    methods (Static = true)
      function [bucket] = getBucket( bucket_index )
      %   Liefert die entsprechende Bucket-Klasse zur gegebenen bucket ID.
      % 
      %   --- INPUT ---
      %   
      %   bucket_index
      %    Ein interger-index der angibt um welche Bucket es sich handelt.
      % 
      %   --- OUTPUT ---
      %   
      %   bucket
      %    Der passende Subtyp von AbstractBucket, welcher als colorIndex
      %    den gegebenen bucket_index besitzt.
      %
      %   
      %   @author Andreas Mursch-Radlgruber
      %---------------------------------------------
         bucket = BucketManager.bucketMap(bucket_index);
      end
   end
    
end