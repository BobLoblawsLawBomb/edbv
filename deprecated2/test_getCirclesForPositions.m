im = imread('res/table_test-1.png');


positions(1,:) = [100 100];
positions(2,:) = [150 100];

positions

circles = getCirclesForPositions(positions, 50, im);



imshow(intersectMasks(circles));