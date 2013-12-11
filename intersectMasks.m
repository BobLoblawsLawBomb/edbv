function [ intersection ] = intersectMasks( masks )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    intersection = masks{1};
    
   for i = 2 : length(masks)
       
       intersection = and(intersection,masks{i});
       
   end
   

end

