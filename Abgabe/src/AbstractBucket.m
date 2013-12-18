classdef (Abstract) AbstractBucket
    
    % Hierbei handelt es sich das Skelet der Datenstrukturen, in welcher
    % die Grenzen der Farbplassen gespeichert werden
    %
    %   @author Theresa Froeschl
    %   @author Maximilian Irro
    %---------------------------------------------
    
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
        
        hueMinB;
        hueMaxB;
        
        meanhue;
        huedist;
        meansat;
        meanval;
    end
    
end

