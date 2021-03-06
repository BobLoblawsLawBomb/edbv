img = imread('res/images/table_test-1.png');
mask = table_mask(img);
image = img .* mask;

[BWComponents, ColorComponents] = connectedComponent(image, 0.5);

componentColorList = colorClassification( ColorComponents );