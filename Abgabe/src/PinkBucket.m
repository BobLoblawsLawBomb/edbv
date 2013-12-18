classdef PinkBucket < AbstractBucket

    % Die Attribut Intervalle, anhand eine roserne Kugel erkannt wird
    %
    %   @author Theresa Froeschl
    %   @author Maximilian Irro
    %---------------------------------------------
    
    properties(Constant = true)
        colorIndex = 5;
        colorName = 'Pink';
        rgbColor = [255,20,147];
        hueMin = 310/360;
        hueMax = 40/360;
        satMin = 0;
        satMax = 0.435;
        valMin = 0.75;
        valMax = 1;
        
        hueMinB = 351/360;
        hueMaxB = 23/360;
        
        meanhue = 0.02;
        huedist = 0.12;
        meansat = 0;
        meanval = 0;
    end

end

