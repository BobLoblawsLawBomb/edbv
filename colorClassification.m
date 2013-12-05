%function [ red, white, black, green, blue, yellow, pink, brown ] = colorClassification( colorComponents )

img = imread('res/table_test-1.png');
mask = table_mask(img);
image = img .* mask;
imshow(image)
[BWComponents, ColorComponents] = connectedComponent(image);
red = [];
[dim num] = size(ColorComponents);

for x = 1:num
    
    current = ColorComponents{x};

    %gruener Teil wegschneiden
    cform = makecform('srgb2lab');
    lab = applycform(current,cform);
    rg_chroma = lab(:,:,2);
    THRESHOLD = 0.40;
    BW = im2bw(rg_chroma, THRESHOLD);
    
    mask = uint8(BW);
    mask = repmat( mask, [1 1 3]);
    component = mask .* current;
    imshow(component);
    
%     % hier faerben wir die Component mit der durschnittlichen Farbe ein 
%     mean_color = meanImageColor(component);
%     mean_color = mean_color - uint8([20 50 0]); % Pauschalkorrektur fuer Gruenstich durch gruene Pixel
%     mean_color = mean_color + uint8([80 80 80]); % pauschalfaktor um grau auf weiss zu bringen (grauwertkorrektur bei der wei?en kugel fixt auch die anderen baelle)
%     meanRed = mean_color(1);
%     meanGreen = mean_color(2);
%     meanBlue = mean_color(3);
%     component_mean_colored = mask;
%     redChannel = component(:,:,1);
%     greenChannel = component(:,:,2);
%     blueChannel = component(:,:,3);
%     
%     redChannel(redChannel ~= 0) = meanRed;
%     greenChannel(greenChannel ~= 0) = meanGreen;
%     blueChannel(blueChannel ~= 0) = meanBlue;
%     
%     component_mean_colored(:,:,1) = redChannel;
%     component_mean_colored(:,:,2) = greenChannel;
%     component_mean_colored(:,:,3) = blueChannel;
%     
%     % HIER EINEN BREAKPOINT SETZEN
%     imshow(component_mean_colored);
    
%     % - - - Ende der Einfaerbung - - - 
%     
%     % hier faerben wir die Component mit der dominanten Bucket Color ein
%     bucketColor = dominantBucketColor(component, 6, 0);
%     
%     hsv = rgb2hsv(component);
%     hue = hsv(:,:,1);
%     sat = hsv(:,:,2);
%     val = hsv(:,:,3);
%     
%     hue(hue ~= 0) = bucketColor;
%     sat(hue ~= 0) = 1;
%     val(hue ~= 0) = 1;
%     
%     hsv(:,:,1) = hue;
%     hsv(:,:,2) = sat;
%     hsv(:,:,3) = val;
%    
%     % HIER EINEN BREAKPOINT SETZEN
%     imshow( hsv2rgb(hsv));
%     
%     
%     
%     
    % HIER TESTEN WIR DOMINAT BUCKET V2
    
    dominatBucket = dominantBucketColor2(component);
    %class(dominatBucket)
    
    comp_mask = im2bw(component,0.00001);
    
    comp_red = component(:,:,1);
    comp_green = component(:,:,2);
    comp_blue = component(:,:,3);
    
    comp_red(comp_mask>0) = dominatBucket.rgbColor(1);
    comp_green(comp_mask>0) = dominatBucket.rgbColor(2);
    comp_blue(comp_mask>0) = dominatBucket.rgbColor(3);
    
    new_comp = zeros(size(component));
    new_comp(:,:,1) = comp_red;
    new_comp(:,:,2) = comp_green;
    new_comp(:,:,3) = comp_blue;
    
     imshow(uint8(new_comp));
    
%     % - - - Ende der Einfarbung - - - 
%    
%     [row,col,v] = find(current);
%     pixels = impixel(current,col,row);
%     pixel_max = max(pixels);
%     
%     %p_single = im2single(pixels);
%     pixel_median = median(reshape(pixels, [], 3), 2);
%     
%     
%     p_uint8 = im2uint8(pixels);
%     pixel_mean = mean(p_uint8);
%     p_mean_red = mean(p_uint8(:,1));
%     p_mean_green = mean(p_uint8(:,2));
%     p_mean_blue = mean(p_uint8(:,3));
%     
%     [row_com,col_com,v_com] = find(component);
%     pixels_com = impixel(component,col_com,row_com);
%     pixel_max_com = max(pixels_com);
%     p_uint8_com = im2uint8(pixels_com);
%     pixel_mean_com = mean(p_uint8_com);
%     pixel_median_com = median(reshape(pixels_com, [], 3), 2);
%     p_mean_com_red = mean(p_uint8_com(:,1));
%     p_mean_com_green = mean(p_uint8_com(:,2));
%     p_mean_com_blue = mean(p_uint8_com(:,3));
%    
%     
%     p_cell = num2cell(pixels);
%     
%     imshow(current);
    %colormap(jet)
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