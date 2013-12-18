function [pos] = getPositionOfComponent( single_component_mask )
%   Berechnet die Position des Zentrums einer Maske.
% 
%   --- INPUT ---
%   
%   single_component_mask
%    Maske einer einzelnen Komponente, deren Position bestimmt werden soll.
%    logical n x m Matrix
% 
%   --- OUTPUT ---
%   
%   pos
%    x,y-Koordinaten des Zentrums der Komponente im bild in der Form [x y]
%
%   
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

    stat = regionprops(single_component_mask,'centroid');
    pos = [stat.Centroid(1), stat.Centroid(2)];
    
end