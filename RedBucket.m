classdef RedBucket < AbstractBucket
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorIndex = 6;
        colorName = 'Red';
        rgbColor = [255,0,0];
        hueMin = 310/360;
        hueMax = 40/360;
        satMin = 0.435;
        satMax = 1;
        valMin = 0.70;
        valMax = 1;
        
        hueMinB = 351/360;
        hueMaxB = 11/360;
    end

end

