%function [ red, white, black, green, blue, yellow, pink, brown ] = colorClassification( colorComponents )
img = imread('res/table_test-1.png');
mask = table_mask(img);
image = img .* mask;
[BWComponents, ColorComponents] = connectedComponent(image);
red = [];
[dim num] = size(ColorComponents);

for x = 1:num
    
    current = ColorComponents{x};
    %imshow(current);
    
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
    
    
    % hier faerben wir die Component einmal mit 
    % der Durschnittsfarbe ein
    mean_color = meanImageColor(component);
    mean_color = mean_color - uint8([20 50 0]); % Pauschalkorrektur fuer Gruenstich durch gruene Pixel
    mean_color = mean_color + uint8([80 80 80]); % pauschalfaktor um grau auf weiss zu bringen (grauwertkorrektur bei der wei?en kugel fixt auch die anderen baelle)
    meanRed = mean_color(1);
    meanGreen = mean_color(2);
    meanBlue = mean_color(3);
    component_mean_colored = mask;
    redChannel = component(:,:,1);
    greenChannel = component(:,:,2);
    blueChannel = component(:,:,3);
    
    redChannel(redChannel ~= 0) = meanRed;
    greenChannel(greenChannel ~= 0) = meanGreen;
    blueChannel(blueChannel ~= 0) = meanBlue;
    
    component_mean_colored(:,:,1) = redChannel;
    component_mean_colored(:,:,2) = greenChannel;
    component_mean_colored(:,:,3) = blueChannel;
    
    imshow(component_mean_colored);
    % Ende der Einfaerbung 
    
    
   
    [row,col,v] = find(current);
    pixels = impixel(current,col,row);
    pixel_max = max(pixels);
    
    p_single = im2single(pixels);
    pixel_median = median(p_single);
    
    p_uint8 = im2uint8(pixels);
    pixel_mean = mean(p_uint8);
    
    p_cell = num2cell(pixels);
    
    imshow(current);
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