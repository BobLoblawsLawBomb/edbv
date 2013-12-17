function [ resultBW, resultColor] = connectedComponent( table_mask , threshold)
%
% Diese Funktion ermittelt die Components im Bild (d.h. die Kugeln) 
% Dafuer werden die Glanzpunkte der Kugeln benutzt. Durch sehr helle Stellen
% im Bild, die zu keiner Kugel gehoeren, werden auch Fragmente vom Tisch und
% Koe als Glanzpunkte interpretiert.
%
% Input: Tisch muss bereits durch die Tisch-Maske ausgeschnitten sein
% 
% Ausgabe: 
% - resultBW: ist ein n-dim. cell-Element, das in jeder Zelle ein Binaerbild
%            einer Komponente enthaellt. insgesammt sind es n Components
% - resultColor: ist ebenfalls ein n-dim. cell-Element, das in jeder Zelle
%            ein farbiges Bild (also ein 3-dim RGB-Bild) einer Komponente enthaelt.
%
% aus dem bild wird ein binaerbild, nur die hellsten stellen werden weiss
%
%   @author Theresa Froeschl
%   @author Maximilian Irro
%---------------------------------------------

BW = im2bw(table_mask , threshold);

figure(20);
imshow(BW);

%Elemente werden von einander getrennt
%Anwendung des selbst implementierten Algorithmus zu Connected Component Labeling 
[L, num] = ccl_labeling(BW);

L = uint8(L);
BW = im2uint8(BW);
color_img = repmat( uint8(zeros(size(BW,1),size(BW,2))), [1 1 3]);

%berechne moeglichst passende komponente fuer eine kugel
%annahme: 
%   der glanzpunkt ist auf der x-achse in der mitte
%   der glanzpunkt endet auf der y-achse oben genau wo die kugel endet
bbox = regionprops(L, 'BoundingBox');

% mittelpunkte der gelabelten BLOBs berechnen lassen
stat = regionprops(L,'centroid');
stat2 = regionprops(L, 'EquivDiameter');

resultBW = cell(0);
resultColor = cell(0);

idx = 1;
for x = 1:num
    
    rx = L;
    
    % alles, was nicht die aktuelle Komponente ist, wird ausmaskiert
    rx(rx ~= x) = 0;

    % jetzt maskieren wir die Kugel mit einem Kreis aus
    cx = stat(x).Centroid(1);
    cy = bbox(x).BoundingBox(2);
    cy = cy + 5; % Positionskorrektur von Glanzpunkt auf Ballmittelpunkt
    rx = insertShape(uint8(rx), 'FilledCircle', [cx cy 7]);
    rx = im2bw(rx); % ist durch shape insertion zu uint8 geworden
    
    if stat2(x).EquivDiameter < 17
        
        resultBW{idx} = rx;

        rx = im2uint8(rx);
        rx3 = cat(3, rx, rx, rx);
        rcx = table_mask;

        rcx(rx3 == 0) = 0;

        color_img = color_img + rcx;
        resultColor{idx} = rcx;
        
        idx = idx + 1;
    end
    
end;

 figure(21);
 imshow(color_img);

end

