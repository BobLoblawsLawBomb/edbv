classdef RedBucket < AbstractBucket
    
    % Die Attribut Intervalle, anhand eine rote Kugel erkannt wird
    %
    %   @author Theresa Froeschl
    %   @author Maximilian Irro
    %---------------------------------------------
    
    properties(Constant = true)
        colorIndex = 6;
        colorName = 'Red';
        rgbColor = [255,0,0];
        hueMin = 310/360;
        hueMax = 40/360;
        satMin = 0.435;
        satMax = 1;
        valMin = 0.70;
        valMax = 1;
        
        hueMinB = 351/360;
        hueMaxB = 11/360;
        
        meanhue = 0; % 0 sollte so stimmen
        huedist = 0.155;
        meansat = 0;
        meanval = 0;
    end

end

