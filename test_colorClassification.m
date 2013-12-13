img = imread('res/table_test-7.png');
mask = table_mask(img);
image = img .* mask;

imshow(image);

[BWComponents, ColorComponents] = connectedComponent(image, 0.5);

componentColorList = colorClassification( ColorComponents );