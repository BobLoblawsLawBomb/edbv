function [ result ] = table_mask( input )
%TABLE_MASK makes a binary mask for a pool or snooker table
%   @author Maximilian Irro

%create color transformation structure
cform = makecform('srgb2lab');

% transform into L*a*b color space
input_lab = applycform(input, cform); 

% extract the red-green chroma component
rg_chroma = input_lab(:,:,2);

% make a binary image
THRESHOLD = 0.45;
BW = im2bw(rg_chroma, THRESHOLD);

% now everything except the table is 1, 
% but we need this the other way around
BW_inv = imcomplement(BW);

% fill all holes in the segmented table
% holes are balls (mind the bad dirty joke!)
BW_filled = imfill(BW_inv, 'holes');

% convert it to uint8 to make it compatible with an image
mask = uint8(BW_filled);

% replicate the matrix 3 times, to combine it with a color image
mask3 = repmat( mask, [1 1 3]);

% return only the game table
result = mask3;

end

