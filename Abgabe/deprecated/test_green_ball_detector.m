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

white = uint8([255 255 255]);
shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom','CustomBorderColor',white,'FillColor','Custom','CustomFillColor',white);

% eine 2D matrix bestehend aus x/y/radius
coord = [];
coord(:,:) = centers;
coord(:,3) = radii;

circles = int32(coord);

panel = zeros(size(I));
%panel = repmat(panel, [1,1,3]);


J = step(shapeInserter, panel, circles);

imshow(J)

% img_size = size(img);
% Nx = img_size(1);
% Ny = img_size(2);
% 
% balls = zeros(img_size(:,:,1));
% for i=1:size(radii)
%     cx = centers(i,2);
%     cy = centers(i,1);
%     radius = radii(i);
%     circlePixels = (Nx - cx).^2 + (Ny - cy).^2 <= radius.^2;
%     balls = balls + circlePixels;   
% end


