img = imread('table.png');
mask = table_mask(img);
imshow( img .* mask )