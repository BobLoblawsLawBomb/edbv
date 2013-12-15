classdef WhiteBucket < AbstractBucket
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorIndex = 7;
        colorName = 'White';
        rgbColor = [220,220,220];
        hueMin = 40/360;
        hueMax = 350/360;
        satMin = 0;
        satMax = 0.35;
        valMin = 0.75;
        valMax = 1;
        
        hueMinB = 70/360;
        hueMaxB = 110/360;
    end
    
end

