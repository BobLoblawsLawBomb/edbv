classdef BlackBucket < AbstractBucket
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorIndex = 1;
        colorName = 'Black';
        rgbColor = [36,36,36]; % grau, damit man es von der maske unterscheiden kann
        hueMin = 0;
        hueMax = 1;
        satMin = 0;
        satMax = 1;
        valMin = 0;
        valMax = 0.15;
        
        hueMinB = 100/360;
        hueMaxB = 120/360;
    end
end

