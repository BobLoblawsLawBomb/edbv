path = ['res',filesep,'table_test-1.png'];
img = imread(path);
mask = table_mask(img);



imshow( img .* mask )
%imshow( rgb2gray(img .* mask) )

