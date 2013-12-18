function [ circles ] = getCirclesForPositions(positions, radius, im)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    circles = cell(length(positions));
    
    for i = 1 : length(positions)
    
        mask = false(size(im));
        
        position = [positions(i,1), positions(i,2)];
        positionWithFactor = position;
        positionWithFactor(3) = radius;
        uint8Mask = insertShape(uint8(mask), 'FilledCircle', positionWithFactor);

        outMask = im2bw(uint8Mask,0.5);
        
        circles{i} = outMask;

    end

end

