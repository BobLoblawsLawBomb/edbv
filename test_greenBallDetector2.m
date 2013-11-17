path = ['res',filesep,'table_test-4.png'];
img = imread(path);
mask = table_mask(img);
masked_img = img .* mask;

ball_mask = greenBallDetector2(masked_img);
imshow(masked_img .* ball_mask);