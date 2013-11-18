function [ vx, vy ] = calcComponentVelocity( of, componentMask )
%CALCCOMPONENTVELOCITY Summary of this function goes here
%   Detailed explanation goes here
    mask = double(componentMask);
    xv = real(of).*mask;
    yv = imag(of).*mask;
    s = sum(sum(mask));
    vx = sum(sum(xv))/s; %calculate x-average of all points that are within the mask
    vy = sum(sum(yv))/s; %calculate y-average of all points that are within the mask
end