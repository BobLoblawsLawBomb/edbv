function [position] = getPositionOfComponent( single_component_mask )
%Input: Maske einer Komponente
%Output: x,y-Koordinaten der Komponente im bild

    [B,L] = bwboundaries(single_component_mask, 'noholes');
    
    xSum = 0;
    ySum = 0;
    
    if size(B) > 0
        array = cell2mat(B(1));
        for i = 1 : size(array)
          ySum = ySum + array(i,2);
          xSum = xSum + array(i,1);
        end

        sizeArray = size(array);
        position(1) = int32(ySum / sizeArray(1));
        position(2) = int32(xSum / sizeArray(1));
    else
        position(1) = int32(0);
        position(2) = int32(0);
    end
end