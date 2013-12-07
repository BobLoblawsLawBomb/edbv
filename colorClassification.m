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
    imshow(current)

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
  
    
    ballColor = componentColor(component);
    
    % ================================================   
    % Die Component mit der erkannten Farbe einfaerben
    comp_mask = im2bw(component,0.00001);
    
    comp_red = component(:,:,1);
    comp_green = component(:,:,2);
    comp_blue = component(:,:,3);
    
    comp_red(comp_mask>0) = ballColor.rgbColor(1);
    comp_green(comp_mask>0) = ballColor.rgbColor(2);
    comp_blue(comp_mask>0) = ballColor.rgbColor(3);
    
    new_comp = zeros(size(component));
    new_comp(:,:,1) = comp_red;
    new_comp(:,:,2) = comp_green;
    new_comp(:,:,3) = comp_blue;
    % ================================================
    
    imshow(uint8(new_comp));

    
end

%end