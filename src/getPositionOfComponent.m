function [pos] = getPositionOfComponent( single_component_mask )
%Input: Maske einer Komponente
%Output: x,y-Koordinaten des Zentrums der Komponente im bild
%        in der Form [x y]
%
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

    stat = regionprops(single_component_mask,'centroid');
    pos = [stat.Centroid(1), stat.Centroid(2)];
    
end