function [ maskPositions ] = getMaskPositionOfComponent( mask )
%GETMASKPOSITIONOFCOMPONENT Summary of this function goes here
%   Detailed explanation goes here

    [B,L]=bwboundaries(mask,'noholes');

    array=cell2mat(B(1));
    
    for i=1:size(array)
       maskPositions(i,2)=array(i,1);
       maskPositions(i,1)=array(i,2);
    end

end

