img = imread('res/table_test-7.png');

% zuerst maskieren wie immer den tisch aus
mask = table_mask(img);
image = img .* mask;

% jetzt holen wir uns im Lab Farbraum den rot/gruenen Farbkanal
cform = makecform('srgb2lab');
lab = applycform(image, cform); 
rg_chroma = lab(:,:,2); % hell bedeutet mehr rot, dunkel mehr gruen

% wir zerteilen das bild anhand der schwelle zwischen tisch und allem
% anderen
rg_bw = imcomplement(im2bw(rg_chroma,0.45));

imshow(rg_bw);

% hier ist alles ungleich 0, was nicht der tisch ist
table_red = rg_chroma .* uint8(imcomplement(rg_bw));
%imshow(table_red)

% hier ist nur der tisch, alles andere (zumindest die glanzpunkte) sollten
% schwarz sein
table_green = rg_chroma .* uint8(rg_bw);

% BREAKPOINT
%imshow(table_green)

% jetzt zeichnen wir den gruenen bereich weich und eliminieren hoffentlich
% die fehler
imshow(table_green);
%h = fspecial('gaussian', 40, 3);
h = fspecial('average', 50);
table_green = imfilter(table_green,h);
table_green = table_green .* uint8(rg_bw);

% BREAKPOINT
imshow(table_green);

% nun kombinieren wir wieder alles auf dem tisch mit der modifizierten
% tischflaeche
lab(:,:,2) = table_green + table_red;


cform = makecform('lab2srgb');
image = applycform(lab, cform); 



imshow(image);