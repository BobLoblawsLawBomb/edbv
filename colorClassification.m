function [ componentColorList ] = colorClassification( ColorComponents )
%====================================
% function [ red, white, black, green, blue, yellow, pink, brown ] = colorClassification()
% % 
% % fuer Testzwecke
% img = imread('res/table_test-6.png');
% mask = table_mask(img);
% image = img .* mask;
% %imshow(image)
% [BWComponents, ColorComponents] = connectedComponent(image, 0.5);
%====================================

[dim num] = size(ColorComponents);

% diese Liste enthaelt fuer jede Component einen Eintrag, der mit einem
% colorIndex einer Farbklasse korreliert
componentColorList = cell(1,num);

for x = 1:num
    
    current = ColorComponents{x};
    
    imshow(current);  
    
    ballClass = componentColorClass(current);
    componentColorList{x} = ballClass.colorIndex;
    
    % ================================================   
    % Die Component mit der erkannten Farbe einfaerben
    comp_mask = im2bw(current,0.00001);
    
    comp_red = current(:,:,1);
    comp_green = current(:,:,2);
    comp_blue = current(:,:,3);
    
    comp_red(comp_mask>0) = ballClass.rgbColor(1);
    comp_green(comp_mask>0) = ballClass.rgbColor(2);
    comp_blue(comp_mask>0) = ballClass.rgbColor(3);
    
    new_comp = zeros(size(current));
    new_comp(:,:,1) = comp_red;
    new_comp(:,:,2) = comp_green;
    new_comp(:,:,3) = comp_blue;
    
    imshow(uint8(new_comp));
    % ================================================
                
end

end
