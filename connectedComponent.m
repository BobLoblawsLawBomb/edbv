function [ result ] = connectedComponent( table_mask )
%input bild maskiert

img = table_mask;
%aus dem bild wird binaerbild, nur die hellsten stellen werden weiß
%kö und linke und rechte obere Ecke werden auch erkannt 
BW = im2bw(img , 0.60);
%nur zur kontrolle 
imshow(BW);
%elemente von einander trennen
[L, num] = bwlabel(BW, 8);
result = zeros(size(BW,1),size(BW,2), num);

%setzt für jedes Label alle anderen Elemente auf schwarz
for x = 1:num
    result(:,:,x) = L;
    rx =  result(:,:,x);
    rx(rx<x) = 0;
    rx(rx>x) = 0;
    result(:,:,x) = rx;
end;

end

