%function [ red, white, black, green, blue, yellow, pink, brown ] = colorClassification( colorComponents )
%img = imread('res/table_test-1.png');
%mask = table_mask(img);
%image = img .* mask;
[BWComponents, ColorComponents] = connectedComponent(image);
red = [];
[dim num] = size(ColorComponents);

for x = 1:num
    
    current = ColorComponents{x};
    current = rgb2hsv(current);
    %imshow(hsv);
    %color = impixel(current);
    
    %gruener Teil wegschneiden
%     cform = makecform('srgb2lab');
%     lab = applycform(current,cform);
%     rg_chroma = lab(:,:,2);
%     THRESHOLD = 0.40;
%     BW = im2bw(rg_chroma, THRESHOLD);
%     
%     mask = uint8(BW);
%     mask = repmat( mask, [1 1 3]);
%     component = mask .* current;
%     imshow(component);
    
   
    [row,col,v] = find(current);
    pixels = impixel(current,col,row);
    pixel_max = max(pixels);
    
    %p_single = im2single(pixels);
    pixel_median = median(reshape(pixels, [], 3), 2);
    
    
    p_uint8 = im2uint8(pixels);
    pixel_mean = mean(p_uint8);
    p_mean_red = mean(p_uint8(:,1));
    p_mean_green = mean(p_uint8(:,2));
    p_mean_blue = mean(p_uint8(:,3));
    
    [row_com,col_com,v_com] = find(component);
    pixels_com = impixel(component,col_com,row_com);
    pixel_max_com = max(pixels_com);
    p_uint8_com = im2uint8(pixels_com);
    pixel_mean_com = mean(p_uint8_com);
    pixel_median_com = median(reshape(pixels_com, [], 3), 2);
    p_mean_com_red = mean(p_uint8_com(:,1));
    p_mean_com_green = mean(p_uint8_com(:,2));
    p_mean_com_blue = mean(p_uint8_com(:,3));
   
    
    p_cell = num2cell(pixels);
    
    imshow(current);
%     
%     red = [red; current];
%     red = [red; ColorComponents{x+1}];
%     red = [red; ColorComponents{x+2}];
%     r1 = red(1:size(current,1),1:size(current,2), :);
%     r2 = red(size(current,1)+1:size(current,1)*2 ,1:size(current,2), :);
%     if r1 == current
%        if r2 == ColorComponents{2}
%         b = true;
%        end
%     end
    
end

%end