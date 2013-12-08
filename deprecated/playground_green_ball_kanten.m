path = ['res',filesep,'table_test-6.png'];
img = imread(path);
mask = table_mask(img);
masked_img = img .* mask;
im_gray = rgb2gray(masked_img);

%kernel = [10,9,10,0,0,0,-10,-9,-10];
%kernel = [ 15,10,10; 0,0,0; -15,-10,-15 ];


%kernel = [ 0,0,2,0,0,; 0,2,0,2,0; -1,0,0,0,-1; 0,-2,0,-2,0; 0,0,-2,0,0];
kernel = [ 0,-2,-2,-2,0; -2,0,0,0,-2; 2,0,0,0,2; 2,0,0,0,2; 0,-2,-2,-2,0];

im_gradient = imfilter(im_gray, kernel);

imshow(im_gradient)

h = fspecial('gaussian');
im_gradient = imfilter(im_gradient, h);
imshow(im_gradient)

im_bw = im2bw(im_gradient);
imshow(im_bw)

im_thickend = bwmorph(im_bw,'thicken',6);
imshow(im_thickend)

[centers, radii] = imfindcircles(im_thickend,[10 15], 'ObjectPolarity','bright', 'Sensitivity',0.93);
%h = viscircles(centers,radii);

% Jetzt erzeugen wir eine neue Maske aus den erkannten Punkten. 
ball_mask = zeros(size(im_gray));
for i=1:size(radii)
    cx = round(centers(i,2));
    cy = round(centers(i,1));
    %radius = radii(i);
    ball_mask(cx,cy) = 1; 
end

ball_mask = bwmorph(ball_mask,'thicken',15);
imshow(ball_mask)

ball_mask = repmat( uint8(ball_mask), [1 1 3]);