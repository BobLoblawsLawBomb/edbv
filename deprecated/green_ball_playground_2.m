path = ['res',filesep,'table_test-6.png'];
img = imread(path);
mask = table_mask(img);
masked_img = img .* mask;

im_gray = rgb2gray(masked_img);
% 
% kernel = [ 10  9  10 
%             0  0  0
%           -10 -9 -10 ];

kernel = [ 15  10  10 
            0   0   0
          -15 -10 -15 ];


im_gradient = imfilter(im_gray, kernel);
%imshow(im_gradient)

im_bw = im2bw(im_gradient);
%imshow(im_bw)

% http://www.mathworks.de/de/help/images/ref/bwmorph.html
im_thickend = bwmorph(im_bw,'thicken',6);
%imshow(im_thickend)


%imshow(masked_img)

% http://www.mathworks.de/de/help/images/ref/imfindcircles.html
[centers, radii] = imfindcircles(im_thickend,[10 15], 'ObjectPolarity','bright', 'Sensitivity',0.93);
%h = viscircles(centers,radii);

ball_mask = zeros(size(im_gray));

for i=1:size(radii)
    
    % positions are double with possibly existing fraction part
    cx = round(centers(i,2));
    cy = round(centers(i,1));
    %radius = radii(i);
    ball_mask(cx,cy) = 1; 
end

% http://www.mathworks.de/de/help/images/ref/bwmorph.html
balls_thickend = bwmorph(ball_mask,'thicken',15);
imshow(repmat( uint8(balls_thickend), [1 1 3]) .* masked_img)
