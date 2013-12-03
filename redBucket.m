classdef RedBucket < AbstractBucket
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        hueMin = 310/360;
        hueMax = 40/360;
        satMin = 0.30;
        satMax = 1;
        valMin = 0.70;
        valMax = 1;
    end

end

