classdef (Abstract) AbstractBucket
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract, Constant)
        colorIndex;
        colorName;
        rgbColor;
        hueMin;
        hueMax;
        satMin;
        satMax;
        valMin;
        valMax;
    end
    
end

