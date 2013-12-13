% Versieht alle Baelle mit Labels (untersch. Farben) und 
% liefert die dabei entstandene Maske zurueck.
% Author: Florian
% Date: 2013/11/04 09:37:30
function L = labelComponents(rgb_image)

  gray = rgb2gray(rgb_image);  % Grauwertbild erzeugen

  % Mittels imhist(gray); kann ein passender threshold bestimmt werden.
  % Dabei muss darauf geachtet werden, dass der Grüne Ball auch zu sehen 
  % sein soll, der Tisch jedoch nicht!

  threshold = 30 % TODO: diesen Wert empirisch bestimmen (mit imhist).

  bw = gray>threshold; % Binaerbild mit Hilfe des threshold-Wertes bestimmen.

  % Zur Kontrolle kann man das Binaerbild mit imshow(bw); anzeigen.

  [L,num] = bwlabel(bw); % Objekte mit Label versehen.
  
  % Die Groesse der Einzelnen Objekte speichern 
  % (um ungueltige Objekte/Pixel zu vermeiden):
  for i=1:num
    area(i) = bwarea(L==i);
  end

  min_size = 2 % Die Mindestgroesse einer Kugel (muss empirisch bestimmt werden).
  x = find(area>min_size) % Alle Objekte, die eine bestimmte Mindesgroesse haben.

  L = (L == x)	% Bild mit den gelabelten Objekten minimaler Groesse bestimmen.

  % Zur Kontrolle kann man das Bild mit imshow(L); anzeigen.

end