function [ mean_color ] = meanImageColor( img )
%UNTITLED Calculates the mean color of an rgb image
%   @author Maximilian Irro
    
    sum_red = sum(sum( img(:,:,1) ));
    sum_green = sum(sum( img(:,:,2) ));
    sum_blue = sum(sum( img(:,:,3) ));
    
    A = img(:,:,1);
    sum_colorPixels = sum(sum( A ~= 0 ));
    
    mean_red = sum_red / sum_colorPixels;
    mean_green = sum_green / sum_colorPixels;
    mean_blue = sum_blue / sum_colorPixels;
    
    mean_color = uint8( [mean_red mean_green mean_blue] );
    
end

