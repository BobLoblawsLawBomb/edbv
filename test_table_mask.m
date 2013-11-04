img = imread('res/table_test.png');
mask = table_mask(img);
imshow( img .* mask )