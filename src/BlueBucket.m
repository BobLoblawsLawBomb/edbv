classdef BlueBucket < AbstractBucket
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorIndex = 2;
        colorName = 'Blue';
        rgbColor = [0,0,255];
        hueMin = 190/360;
        hueMax = 250/360;
        satMin = 0.35;
        satMax = 1;
        valMin = 0.35;
        valMax = 1;
        
        hueMinB = 169/360;
        hueMaxB = 201/360;
        
        meanhue = 0.514;
        huedist = 0.075;
        meansat = 0;
        meanval = 0;
    end
    
end

