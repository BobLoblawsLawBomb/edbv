classdef BrownBucket < AbstractBucket

    % Die Attribut Intervalle, anhand eine braune Kugel erkannt wird
    %
    %   @author Theresa Froeschl
    %   @author Maximilian Irro
    %---------------------------------------------
    
    properties(Constant = true)
        colorIndex = 3;
        colorName = 'Brown';
        rgbColor = [139,69,19];
        hueMin = 30/360;
        hueMax = 55/360;
        satMin = 0.5;
        satMax = 1;
        valMin = 0.35;
        valMax = 0.75;
        
        hueMinB = 67/360;
        hueMaxB = 77/360;
        
        meanhue = 0.2;
        huedist = 0.05;
        meansat = 0;
        meanval = 0;
    end

end

