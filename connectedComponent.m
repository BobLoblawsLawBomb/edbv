function [ resultBW, resultColor, resultRaw] = connectedComponent( table_mask , threshold)
%input bild: Tisch muss bereits durch die Tisch-Maske ausgeschnitten sein
%Diese Funktion ermittelt die Components im Bild (d.h. die Kugeln) 
%Dafuer werden die Glanzpunkte der Kugeln benutzt. Durch sehr helle Stellen
%im Bild, die zu keiner Kugel geh?ren, werden auch Fragmente vom Tisch und
%Koe als Glanzpunkte interpretiert.
%Ausgabe: resultBW: ist ein n-dim. cell-Element, das in jeder Zelle ein Binaerbild
%einer Komponente enthaellt. insgesammt sind es n Components
%Ausgabe: resultColor: ist ebenfalls ein n-dim. cell-Element, das in jeder Zelle
%ein farbiges Bild (also ein 3-dim RGB-Bild) einer Komponente enthaelt.

img = table_mask;

%aus dem bild wird binaerbild, nur die hellsten stellen werden weiss
%koe und linke und rechte obere Ecke werden auch erkannt 
BW = im2bw(table_mask , threshold);%0.5 %0.60

%elemente von einander trennen
%[L, num] = bwlabeln(BW, 4);
[L, num] = ccl_labeling(BW);

BW = im2uint8(BW);
color_img = repmat( uint8(zeros(size(img,1),size(img,2))), [1 1 3]);

resultRaw = L;

%berechne moeglichst passende komponente fuer eine kugel
%annahme: 
%   der glanzpunkt ist auf der x-achse in der mitte
%   der glanzpunkt endet auf der y-achse oben genau wo die kugel endet
bbox = regionprops(L, 'BoundingBox');
%disp(['x: ', num2str(bbox(1).BoundingBox(1)), ', y: ', num2str(bbox(1).BoundingBox(2)), ', xw: ', num2str(bbox(1).BoundingBox(3)), ', yw: ', num2str(bbox(1).BoundingBox(4))]);

% mittelpunkte der gelabelten BLOBs berechnen lassen
% http://www.mathworks.com/matlabcentral/answers/28996-centroid-of-an-image
stat = regionprops(L,'centroid');
stat2 = regionprops(L, 'EquivDiameter');

%resultBW = zeros(size(BW,1),size(BW,2), num);
% resultBW = cell(1,num);
% resultColor = cell(3,num);

% Die groesse kann nicht vorher fixiert werden, da eventuell komponenten
% verworfen werden, das wuerde zu leeren eintraegen fuehren.
clear resultBW;
clear resultColor;

%setzt f?r jedes Label alle anderen Elemente auf schwarz
idx = 1;
for x = 1:num
    
    rx = L;
    
    % alles was nicht die aktuelle component ist ausmaskieren
    rx(rx<x) = 0;
    rx(rx>x) = 0;
    
    % jetzt maskieren wir die Kugel mit einem Kreis aus
    %rx = bwmorph(rx,'thicken',10);
    cx = stat(x).Centroid(1);
    %cy = stat(x).Centroid(2);
    cy = bbox(x).BoundingBox(2);
    cy = cy + 5; % Positionskorrektur von Glanzpunkt auf Ballmittelpunkt
    rx = insertShape(uint8(rx), 'FilledCircle', [cx cy 7]);
    rx = im2bw(rx); % ist durch shape insertion zu uint8 geworden
    
%     imshow(rx);
    
    if stat2(x).EquivDiameter < 17
        
        resultBW{idx} = rx;

        rx = im2uint8(rx);
        rx3 = cat(3, rx, rx, rx);
        rcx = img;

        rcx(rx3 == 0) = 0;

%         cform = makecform('srgb2lab');
%         lab = applycform(rcx,cform);
%         rg_chroma = lab(:,:,2);
%         THRESHOLD = 0.40;
%         BW = im2bw(rg_chroma, THRESHOLD);
%         mask = uint8(BW);
%         mask = repmat( mask, [1 1 3]);
%         rcx = mask .* rcx;

%          figure(8)
%          imshow(rcx);
         %imshow(color_img);

        color_img = color_img + rcx;
        resultColor{idx} = rcx;
        
        idx = idx + 1;
    end
    
end;


%imshow(color_img);


end

