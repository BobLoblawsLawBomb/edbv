table_test = imread('res/table_test.png');
mask = table_mask(table_test);
bild = table_test.*mask;
bildBW = im2bw(bild , 0.60);
bildBW = im2uint8(bildBW);
bildBW = cat(3, bildBW, bildBW, bildBW);

[colorComponents1, colorComponents2] = colorSegmentation(bild);

bild1 = colorComponents1;
bild2 = colorComponents2;

bild1(bildBW==0) = 0;
bild2(bildBW==0) = 0;

bild3 = bild1 + bild2;

imshow(bild3);