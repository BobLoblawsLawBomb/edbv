classdef GreenBucket < AbstractBucket
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorIndex = 4;
        colorName = 'Green';
        rgbColor = [0,255,0];
        hueMin = 90/360;
        hueMax = 150/360;
        satMin = 0;
        satMax = 1;
        valMin = 0.35;
        valMax = 1;
        
        hueMinB = 134/360;
        hueMaxB = 147/360;
        
        meanhue = 0.4;
        huedist = 0.04;
        meansat = 0;
        meanval = 0;
    end

end

