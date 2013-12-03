classdef YellowBucket < AbstractBucket
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorName = 'Yellow';
        rgbColor = [255,255,0];
        hueMin = 65/360;
        hueMax = 55/360;
        satMin = 0;
        satMax = 1;
        valMin = 0.85;
        valMax = 1;
    end
    
end

