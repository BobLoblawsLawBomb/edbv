function [ vx, vy ] = calcComponentVelocity( of, componentMask )
%CALCCOMPONENTVELOCITY Summary of this function goes here
%   Detailed explanation goes here
    xv = real(of).*componentMask;
    yv = imag(of).*componentMask;
    s = sum(sum(componentMask));
    vx = sum(sum(xv))/s; %calculate x-average of all points that are within the mask
    vy = sum(sum(yv))/s; %calculate y-average of all points that are within the mask
end