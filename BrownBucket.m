classdef BrownBucket < AbstractBucket
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorName = 'Brown';
        rgbColor = [139,69,19];
        hueMin = 30/360;
        hueMax = 55/360;
        satMin = 0.5;
        satMax = 1;
        valMin = 0.35;
        valMax = 0.75;
    end

end

