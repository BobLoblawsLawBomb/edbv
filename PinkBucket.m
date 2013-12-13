classdef PinkBucket < AbstractBucket
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorIndex = 5;
        colorName = 'Pink';
        rgbColor = [255,20,147];
        hueMin = 310/360;
        hueMax = 40/360;
        satMin = 0;
        satMax = 0.435;
        valMin = 0.75;
        valMax = 1;
    end

end

