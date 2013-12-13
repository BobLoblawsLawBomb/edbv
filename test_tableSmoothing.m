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
h = fspecial('gaussian');
table_green = imfilter(table_green,h);

% BREAKPOINT
%imshow(table_green)

% nun kombinieren wir wieder alles auf dem tisch mit der modifizierten
% tischflaeche
lab(:,:,2) = table_green + table_red;

max(max(lab(:,:,1)))
max(max(lab(:,:,2)))
max(max(lab(:,:,3)))

lab = im2double(lab);

max(max(lab(:,:,1)))
max(max(lab(:,:,2)))
max(max(lab(:,:,3)))

% bild zurueck in den RGB raum konvertieren
image = colorspace('Lab->RGB',lab);
% [R, G, B] = Lab2RGB(lab);
% image(:,:,1) = R;
% image(:,:,2) = G;
% image(:,:,3) = B;

% BREAKPOINT

max(max(image(:,:,1)))
max(max(image(:,:,2)))
max(max(image(:,:,3)))

imshow(image);