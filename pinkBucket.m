classdef PinkBucket < AbstractBucket
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorName = 'Pink';
        rgbColor = [255,20,147];
        hueMin = 310/360;
        hueMax = 40/360;
        satMin = 0;
        satMax = 0.3;
        valMin = 0.85;
        valMax = 1;
    end

end

