classdef YellowBucket < AbstractBucket

    % Die Attribut Intervalle, anhand eine gelbe Kugel erkannt wird
    %
    %   @author Theresa Froeschl
    %   @author Maximilian Irro
    %---------------------------------------------
    
    properties(Constant = true)
        colorIndex = 8;
        colorName = 'Yellow';
        rgbColor = [255,255,0];
        hueMin = 40/360;
        hueMax = 60/360;
        satMin = 0.8;
        satMax = 1;
        valMin = 0.8;
        valMax = 1;
        
        hueMinB = 60/360;
        hueMaxB = 64/360;
        
        meanhue = 0.172;
        huedist = 0.04;
        meansat = 0;
        meanval = 0;
    end
    
end

