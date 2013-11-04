function [ output_args ] = connectedComponent( img_path )

img = imread(img_path);

BW = im2bw(img , 0.4); %level womoeglich noch anpassen.
[L, num] = bwlabel(BW, 4);
result = zeros(size(BW,1),size(BW,2), num);

for x = 1:num
    result(:,:,x) = L;
    rx =  result(:,:,x);
    rx(rx<x) = 0;
    rx(rx>x) = 0;
    result(:,:,x) = rx;
    imshow(rx);
end;

output_args = result;

end

