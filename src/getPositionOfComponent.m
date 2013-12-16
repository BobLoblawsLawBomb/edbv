function [pos] = getPositionOfComponent( single_component_mask )
%Input: Maske einer Komponente
%Output: x,y-Koordinaten der Komponente im bild
%
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

    stat = regionprops(single_component_mask,'centroid');
    pos = [stat.Centroid(1), stat.Centroid(2)];
    
end