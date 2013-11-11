path = ['res',filesep,'table_test-4.png'];
img = imread(path);
mask = table_mask(img);
masked_img = img .* mask;

I = green_ball_detector(masked_img);

%imshow(I)
%imshow(masked_img)

[centers, radii] = imfindcircles(I,[10 15], 'ObjectPolarity','bright', 'Sensitivity',0.93, 'Method', 'TwoStage');
%[centers,radii]=RemoveOverLap(centers,radii,5,1);

%h = viscircles(centers,radii);

img_size = size(img);
Nx = img_size(1);
Ny = img_size(2);

balls = zeros(img_size(:,:,1));
for i=1:size(radii)
    cx = centers(i,2);
    cy = centers(i,1);
    radius = radii(i);
    circlePixels = (Nx - cx).^2 + (Ny - cy).^2 <= radius.^2;
    balls = balls + circlePixels;   
end


imshow(balls)

