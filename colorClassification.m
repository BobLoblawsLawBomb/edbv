%function [ red, white, black, green, blue, yellow, pink, brown ] = colorClassification( colorComponents )

%====================================
% fuer Testzwecke
img = imread('res/table_test-1.png');
mask = table_mask(img);
image = img .* mask;
imshow(image)
[BWComponents, ColorComponents] = connectedComponent(image);
%====================================


% das hier sind die Farbklassen, in die jede Component eingeordnet wird
red = {};
white = {};
black = {};
green = {};
blue = {};
yellow = {};
pink = {};
brown = {};

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
  
    
    ballClass = componentColorClass(component);
    
    % ================================================   
    % Die Component mit der erkannten Farbe einfaerben
    comp_mask = im2bw(component,0.00001);
    
    comp_red = component(:,:,1);
    comp_green = component(:,:,2);
    comp_blue = component(:,:,3);
    
    comp_red(comp_mask>0) = ballClass.rgbColor(1);
    comp_green(comp_mask>0) = ballClass.rgbColor(2);
    comp_blue(comp_mask>0) = ballClass.rgbColor(3);
    
    new_comp = zeros(size(component));
    new_comp(:,:,1) = comp_red;
    new_comp(:,:,2) = comp_green;
    new_comp(:,:,3) = comp_blue;
    % ================================================
    
    imshow(uint8(new_comp));
    

    % Jetzt weisen wir anhand der Farbklasse die Component einem Set zu
    if isa(ballClass, 'RedBucket')
        redSize = size(red);
        red{redSize(2)} = red{redSize(2)}+1;
    else if isa(ballClass, 'WhiteBucket')
        whiteSize = size(white);
        white{whiteSize(2)} = white{whiteSize(2)}+1;    
    else if isa(ballClass, 'BlackBucket')
        blackSize = size(black);
        black{blackSize(2)} = black{blackSize(2)}+1;        
    else if isa(ballClass, 'GreenBucket')
        greenSize = size(green);
        green{greenSize(2)} = green{greenSize(2)}+1;            
    else if isa(ballClass, 'BlueBucket')
        blueSize = size(blue);
        blue{blueSize(2)} = blue{blueSize(2)}+1;        
    else if isa(ballClass, 'YellowBucket')
        yellowSize = size(yellow);
        yellow{yellowSize(2)} = yellow{yellowSize(2)}+1;        
    else if isa(ballClass, 'PinkBucket')
        pinkSize = size(pink);
        pink{pinkSize(2)} = pink{pinkSize(2)}+1;        
    else if isa(ballClass, 'BrownBucket')
        brownSize = size(brown);
        brown{brownSize(2)} = brown{brownSize(2)}+1;
    end
            
end

%end