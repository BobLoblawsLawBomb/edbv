function [ resultBW, resultColor ] = connectedComponent( table_mask )
%input bild: Tisch muss bereits durch die Tisch-Maske ausgeschnitten sein
%Diese Funktion ermittelt die Components im Bild (d.h. die Kugeln) 
%Dafür werden die Glanzpunkte der Kugeln benutzt. Durch sehr helle Stellen
%im Bild, die zu keiner Kugel gehören, werden auch Fragmente vom Tisch und
%Koe als Glanzpunkte interpretiert.
%Ausgabe: resultBW: ist ein n-dim. cell-Element, das in jeder Zelle ein Binärbild
%einer Komponente enthällt. insgesammt sind es n Components
%Azsgabe: resultColor: ist ebenfalls ein n-dim. cell-Element, das in jeder Zelle
%ein farbiges Bild (also ein 3-dim RGB-Bild) einer Komponente enthält.

img = table_mask;
%aus dem bild wird binaerbild, nur die hellsten stellen werden weiß
%kö und linke und rechte obere Ecke werden auch erkannt 
BW = im2bw(img , 0.50);%0.60

%farbigen Componenten werden ermittelt
%dabei wurde das gesamtBild in 2 Componenten geteilt: 
%Hintergrund und Kugeln
%[ component1, component2 ] = coloredComponents(img);

BW = im2uint8(BW);
BW3 = cat(3, BW, BW, BW);

%alles, was nicht zu einem 'Glanzpunkt' gehört, wird schwarz
%component1(BW3 == 0) = 0;
%component2(BW3 == 0) = 0;


color_img = repmat( uint8(zeros(size(img,1),size(img,2))), [1 1 3]);

%Addition der farbigen Components,
%da die gelbe Kugel auch als Hintergrund erkannt wird.
%coloredComponent = component1 + component2;

%elemente von einander trennen
[L, num] = bwlabeln(BW, 4);
%resultBW = zeros(size(BW,1),size(BW,2), num);
resultBW = cell(1,num);
resultColor = cell(3,num);

%setzt für jedes Label alle anderen Elemente auf schwarz
for x = 1:num
    
    rx = L;
    rx(rx<x) = 0;
    rx(rx>x) = 0;
    rx = bwmorph(rx,'thicken',10);
    resultBW{x} = rx;
    
    rx = im2uint8(rx);
    rx3 = cat(3, rx, rx, rx);
    rcx = img;
    
    rcx(rx3 == 0) = 0;
    
    color_img = color_img + rcx;
    resultColor{x} = rcx;
    
end;


%imshow(color_img);


end

