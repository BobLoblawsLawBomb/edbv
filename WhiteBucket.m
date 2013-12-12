classdef WhiteBucket < AbstractBucket
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorName = 'White';
        rgbColor = [255,255,255];
%         hueMin = 0;
%         hueMax = 1;
        hueMin = 40/360;
        hueMax = 350/360;
        satMin = 0;
        satMax = 0.35;
        valMin = 0.75;
        valMax = 1;
    end
    
end

