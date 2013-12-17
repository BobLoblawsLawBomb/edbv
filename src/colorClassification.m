function [ componentColorList ] = colorClassification( ColorComponents )

%function [ red, white, black, green, blue, yellow, pink, brown ] = colorClassification()
% % 
% % fuer Testzwecke
% img = imread('res/table_test-7.png');
% z = repmat( uint8(zeros(size(img,1),size(img,2))), [1 1 3]);
% mask = table_mask(img);
% image = img .* mask;

% cform = makecform('srgb2lab');
% lab = applycform(image, cform); 
% rg_chroma = lab(:,:,2); % hell bedeutet mehr rot, dunkel mehr gruen
% rg_bw = imcomplement(im2bw(rg_chroma,0.5));
% table_red = rg_chroma .* uint8(imcomplement(rg_bw));
% table_green = rg_chroma .* uint8(rg_bw);
% h = fspecial('gaussian', 20, 0.5);
% table_green = imfilter(table_green,h);
% lab(:,:,2) = table_green + table_red;
% cform = makecform('lab2srgb');
% image = applycform(lab, cform); 
% imshow(image)

% [~, ColorComponents] = connectedComponent(image, 0.5);
%===========================================

z = repmat( uint8(zeros(size(ColorComponents{1},1),size(ColorComponents{1},2))), [1 1 3]);

[~, num] = size(ColorComponents);


% diese Liste enthaelt fuer jede Component einen Eintrag, der mit einem
% colorIndex einer Farbklasse korreliert
componentColorList = cell(1,num);

for x = 1:num
    
    current = ColorComponents{x};
        
%     figure(50);
%     imshow(current);  
    
    [ballClass, intens] = calcColorClass2(current);
    componentColorList{x} = ballClass.colorIndex;
%     disp(ballClass.colorIndex);
    
    % ================================================   
%     Die Component mit der erkannten Farbe einfaerben
    comp_mask = im2bw(current,0.00001);
    
    comp_red = current(:,:,1);
    comp_green = current(:,:,2);
    comp_blue = current(:,:,3);
    
    if intens ~= 0
        comp_red(comp_mask>0) = ballClass.rgbColor(1) * intens;
        comp_green(comp_mask>0) = ballClass.rgbColor(2) * intens;
        comp_blue(comp_mask>0) = ballClass.rgbColor(3) * intens;
    else
        comp_red(comp_mask>0) = 160*0.5;%/360;
        comp_green(comp_mask>0) = 154*0.5;%/360;
        comp_blue(comp_mask>0) = 203*0.5;%/360;
    end
    
    new_comp = zeros(size(current));
    new_comp(:,:,1) = comp_red;
    new_comp(:,:,2) = comp_green;
    new_comp(:,:,3) = comp_blue;
    
%     imshow(uint8(new_comp));
    z = z + uint8(new_comp);
    % ================================================
                
end
try
   clf(50); 
end
figure(50);
imshow(z);
end
