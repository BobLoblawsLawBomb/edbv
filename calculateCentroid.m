function [ centroid ] = calculateCentroid( points )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

    sumx = 0;
    sumy = 0;
    for i = 1 : length(points)
       sumx = sumx + points(i,1);
       sumy = sumy + points(i,2);
    end
    
    
    centroid = [sumx / length(points) , sumy / lengths(points)];

end

