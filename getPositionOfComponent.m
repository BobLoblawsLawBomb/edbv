function [pos] = getPositionOfComponent( single_component_mask )
%Input: Maske einer Komponente
%Output: x,y-Koordinaten der Komponente im bild

    stat = regionprops(single_component_mask,'centroid');
    pos = [stat.Centroid(1), stat.Centroid(2)];

%     [B,L] = bwboundaries(single_component_mask, 'noholes');
%     
%     xSum = 0;
%     ySum = 0;
%     
%     if size(B) > 0
%         array = cell2mat(B(1));
%         for i = 1 : size(array)
%           ySum = ySum + array(i,2);
%           xSum = xSum + array(i,1);
%         end
% 
%         sizeArray = size(array);
%         pos(1) = int32(xSum / sizeArray(1));
%         pos(2) = int32(ySum / sizeArray(1));
%     else
%         pos(1) = int32(0);
%         pos(2) = int32(0);
%     end
end