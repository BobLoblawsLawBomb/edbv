classdef BlackBucket < AbstractBucket
    
    % Die Attribut Intervalle, anhand eine schwarze Kugel erkannt wird
    %
    %   @author Theresa Froeschl
    %   @author Maximilian Irro
    %---------------------------------------------
    
    properties(Constant = true)
        colorIndex = 1;
        colorName = 'Black';
        rgbColor = [80,80,80]; % grau, damit man es von der maske unterscheiden kann
        hueMin = 0;
        hueMax = 1;
        satMin = 0;
        satMax = 1;
        valMin = 0;
        valMax = 0.15;
        
        hueMinB = 100/360;
        hueMaxB = 120/360;
        
        meanhue = 0;
        huedist = 0;
        meansat = 0;
        meanval = 0;
    end
end

