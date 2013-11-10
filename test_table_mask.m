path = ['res',filesep,'table_test-6.png'];
img = imread(path);
mask = table_mask(img);
imshow( img .* mask )
%imshow( rgb2gray(img .* mask) )

