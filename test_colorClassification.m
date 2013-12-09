img = imread('res/table_test-1.png');
mask = table_mask(img);
image = img .* mask;

imshow(image)

[BWComponents, ColorComponents] = connectedComponent(image);

[ red, white, black, green, blue, yellow, pink, brown ] = colorClassification( ColorComponents );