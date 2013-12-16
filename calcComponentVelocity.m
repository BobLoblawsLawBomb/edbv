function [ vx, vy , newMask] = calcComponentVelocity( of, im, position, compSize)
%CALCCOMPONENTVELOCITY Summary of this function goes here
%   Detailed explanation goes here
%   
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

    newPositionWithFactor = position;
    newPositionWithFactor(3) = compSize;
    newMask = false(size(im));
    uint8NewMask = insertShape(uint8(newMask), 'FilledCircle', newPositionWithFactor);
    newMask = im2bw(uint8NewMask, 0.5);
    %newMask3 = repmat(uint8(newMask), [1 1 3]);
    %newOF = newMask3 .* im;
    
    %************************
    % grünen boden weg schneiden
    %************************
    
%     %create color transformation structure
%     cform = makecform('srgb2lab');
%     
%     % transform into L*a*b color space
%     input_lab = applycform(im, cform);
%     
%     % extract the red-green chroma component
%     rg_chroma = input_lab(:,:,2);
%     
%     % make a binary image
%     THRESHOLD = 0.40;
%     BW = im2bw(rg_chroma, THRESHOLD);
%     
%     newMask = and(newMask, BW);
    
    %************************

    %imshow(newMask);
    
    mask = double(newMask);
    
    xv = real(of).*mask;
    yv = imag(of).*mask;
    s = sum(sum(mask));
    vx = sum(sum(xv))/s; %calculate x-average of all points that are within the mask
    vy = sum(sum(yv))/s; %calculate y-average of all points that are within the mask
end
