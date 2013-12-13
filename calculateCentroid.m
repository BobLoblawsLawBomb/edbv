function [ centroid ] = calculateCentroid( points )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

    sumx = 0;
    sumy = 0;
    psize = size(points);
    k = psize(1);
    for i = 1 : k
       sumx = sumx + points(i,1);
       sumy = sumy + points(i,2);
    end
    
    centroid = [sumx / k , sumy / k];

end

