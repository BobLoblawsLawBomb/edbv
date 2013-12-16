function [ isWithin ] = isPointWithinMask( point, mask )
%ISPOINTWITHINMASK Returns if the given point is within the given mask
%
%   @author 
%---------------------------------------------

    if mask(point(1), point(2)) == 0
        isWithin = false;
    else
        isWithin = true;
    end
    
end

