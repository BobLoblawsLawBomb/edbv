function [indices, vx, vy, output_vmask, output_cmask, vlines] = tryToLinkComponents( oldPositions, newPositions, oldClasses, newClasses, ofCompMasks, ofCompPositions, of, mask_search_radius, position_search_radius, compIgnore)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

%matrix um bereiche zu speichern in denen die geschwindigkeiten der
%komponenten gemittelt werden.
output_vmask = false(size(of));
output_cmask = false(size(of));

%matrix um geschwindigkeits-vektor-linien zu speichern
vlines = [0 0 0 0];

newPositionSize = size(newPositions);

indices = zeros(newPositionSize(1), 1);
vx = zeros(newPositionSize(1), 1);
vy = zeros(newPositionSize(1), 1);

for i = 1 : newPositionSize(1)
    
    newCompPosition = newPositions(i,:);
    newCompClass = newClasses(i);
    
    [oldCompIndex, nvx, nvy, vmask, smask] = findOldPosition( oldPositions, newCompPosition, oldClasses, newCompClass, ofCompMasks, ofCompPositions, of, mask_search_radius, position_search_radius, compIgnore);
    
    vx(i) = nvx;
    vy(i) = nvy;
    
    if(oldCompIndex ~= 0)
%         disp(['set: ', num2str(oldCompIndex), ' to ', num2str(newCompPosition), ' | before: ', num2str(compPosition(:, :, oldCompIndex, frameNo-1))]);
        
%         compPosition(:, :, oldCompIndex, frameNo) = newCompPosition;
%         compClass(:, oldCompIndex, frameNo) = newCompClass;
        
        indices(i) = oldCompIndex;
        
        %if the position is already taken, choose which one is more
        %relevant from the perspective of the old position
        %the one who lost can try again.
        
        %draw oldPosition-search-areas
        output_vmask = or(output_vmask, vmask);
        
        %draw component-masks
        output_cmask = or(output_cmask, smask);
        
    else
        indices(i) = oldCompIndex;
    end
    
end

end