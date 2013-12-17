classdef WhiteBucket < AbstractBucket
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        colorIndex = 7;
        colorName = 'White';
        rgbColor = [250,250,250];
        hueMin = 40/360;
        hueMax = 350/360;
        satMin = 0;
        satMax = 0.35;
        valMin = 0.75;
        valMax = 1;
        
        hueMinB = 70/360;
        hueMaxB = 110/360;
        
        meanhue = 0;
        huedist = 0;
        meansat = 0;
        meanval = 0;
    end
    
end

