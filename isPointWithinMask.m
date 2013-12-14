function [ isPointWithinMask ] = isPointWithinMask( point, mask )
%ISPOINTWITHINMASK Returns if the given point is within the given mask

%     disp([num2str(point(1)), ' ', num2str(point(2)), ' ', num2str(mask(point(1), point(2)))]);
    if mask(point(1), point(2)) == 0
        isPointWithinMask = false;
    else
        isPointWithinMask = true;
    end
    
end

