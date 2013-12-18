function [ ball_mask ] = greenBallDetector2( masked_img )
%GREENBALLDETECTOR2 makes a binary mask for the balls on a snooker table,
% including the green ball
%   @author Maximilian Irro

% Wir operieren auf dem Graustufenbild. Interessanterweise 
% erziehlen wir mit diesem Ansatz bereits sehr gute Ergebnisse
% auf den Grauwertbild des unbearbeiteten RGB Bildes
im_gray = rgb2gray(masked_img);

% 
% kernel = [ 10  9  10 
%             0  0  0
%           -10 -9 -10 ];

%kernel = [10,9,10,0,0,0,-10,-9,-10];
%kernel = [ 10,10,10; 0,0,0; -10,-10,-10 ];
kernel = [ 15,10,10; 0,0,0; -15,-10,-15 ];

% Jetzt wenden wir einen "ma?geschneiderten" Gradientenfilter an. 
% Je wilder der Kernel aussieht, desto besser das Ergebnis fuer
% die naechsten Verarbeitungsschritte, wie viele viele Tests 
% gezeigt haben...
% Dieser Filter hebt das Kerngebiet der Baelle hervor. Er funktioniert
% fuer rote Baelle deutlich schlechter, als fuer die anderen Farben.
% Aber uns geht es hier ohnehin primaer um die gruene Kugel.
im_gradient = imfilter(im_gray, kernel);

% Der Gradientenfilter produziert auch viel Rauschen. Dieses 
% eliminieren wird hiermit.
im_bw = im2bw(im_gradient);

% Jetzt lassen wir alle 1 Regionen wachsen um sicherzustellen, dass
% die Hough Transformation auch die Stellen erkennt die wir suchen
%
% http://www.mathworks.de/de/help/images/ref/bwmorph.html
%
im_thickend = bwmorph(im_bw,'thicken',6);

% Jetzt suchen wir nach kreisfoermigen Objekten innerhalb unserer
% BW Maske. imfindcircles wendet zuerst einen Gradientenfilter an 
% versucht anschlie?end mittels Hough Transformation Strukturen zu 
% erkennen. Somit werden die Regionen die der Kantenfilter ebenfalls
% erkannt hat, die aber nich zu einem Ball gehoeren eliminiert.
% Da die roten Baelle 1) oftmals in einem Pack liegen und 2) vom 
% Filterkern nicht so gut hervorgehoben werden, besteht hier eine 
% gute Chance, dass sie diesen Schritt nicht ueberstehen
%
% http://www.mathworks.de/de/help/images/ref/imfindcircles.html
%
[centers, radii] = imfindcircles(im_thickend,[10 15], 'ObjectPolarity','bright', 'Sensitivity',0.93);
%h = viscircles(centers,radii);

% Jetzt erzeugen wir eine neue Maske aus den erkannten Punkten. 
ball_mask = zeros(size(im_gray));

for i=1:size(radii)
    cx = round(centers(i,2));
    cy = round(centers(i,1));
    radius = radii(i);
    %insertShape(uint8(ball_mask),'FilledCircle',[cx,cy,radius]);
    ball_mask(cx,cy) = 1; 
end

% Da jetzt nur einzelne Pixel =1 sind, muessen wir diese Gegenden
% noch wachsen lassen. 15 Pixel ist bei imfindcircles der maximale
% Radius eines Balles. Somit lassen wir jede Region auch auf diesen
% Umfang wachsen, damit jeder Ball auch sicher vollstaendig darin
% enthalten ist
ball_mask = bwmorph(ball_mask,'thicken',15);

% Abschlie?end replizieren wir die Matrix noch auf 3 Dimensionen
% damit sie ohne weitere Schritte auch auf Farbbilder angewendet 
% werden kann. Die Datentyp wird auch zwecks kompatibilitaet angepasst.
ball_mask = repmat( uint8(ball_mask), [1 1 3]);

end
