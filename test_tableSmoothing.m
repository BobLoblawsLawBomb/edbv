img = imread('res/table_test-1.png');

% zuerst maskieren wie immer den tisch aus
mask = table_mask(img);
image = img .* mask;
imshow(image);
% jetzt holen wir uns im Lab Farbraum den rot/gruenen Farbkanal
cform = makecform('srgb2lab');
lab = applycform(image, cform); 
rg_chroma = lab(:,:,2); % hell bedeutet mehr rot, dunkel mehr gruen

% wir zerteilen das bild anhand der schwelle zwischen tisch und allem
% anderen
rg_bw = imcomplement(im2bw(rg_chroma,0.45));

% hier ist alles ungleich 0, was nicht der tisch ist
table_red = rg_chroma .* uint8(imcomplement(rg_bw));

% hier ist nur der tisch, alles andere (zumindest die glanzpunkte) sollten
% schwarz sein
table_green = rg_chroma .* uint8(rg_bw);

% BREAKPOINT
%imshow(table_green)

% jetzt zeichnen wir den gruenen bereich weich und eliminieren hoffentlich
% die fehler
h = fspecial('gaussian');
table_green = imfilter(table_green,h);

% BREAKPOINT
%imshow(table_green)

% nun kombinieren wir wieder alles auf dem tisch mit der modifizierten
% tischflaeche
lab(:,:,2) = table_green + table_red;

% bild zurueck in den RGB raum konvertieren
rgb = lab2uint8(lab);
cform = makecform('lab2srgb');
rgb = applycform(image, cform); 

% BREAKPOINT
imshow(rgb);

[~, ColorComponents] = connectedComponent(rgb, 0.5);
[ componentColorList ] = colorClassification( ColorComponents );