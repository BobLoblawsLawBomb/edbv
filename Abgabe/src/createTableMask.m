function [ result ] = createTableMask( input )
% Diese Funktion erstellt eine Binaermaske, welches mit dem Eingabebild 
% multipliziert nur den Snookertisch und alles sich darauf befindliche 
% erhaelt und alles anderes ausmaskiert.
%
% Eingabe: Standbild eines Snooker Games, idR ein Frame eines Videos, im RGB Farbraum. 
%
% Ausgabe: Binaermaske als uint8, 3 dimensional, in der Groesse des Input
% Bildes, so dass es direkt mit dem Input wieder multipliziert werden kann.
%   
%   @author Maximlian Irro
%---------------------------------------------

% zuerst erstellen wir eine Farb Transformations Struktur
cform = makecform('srgb2lab');

% nun transformieren wir in den L*a*b Farbraum
input_lab = applycform(input, cform); 

% nun holen wir uns den Rot-Gruen Kanal
rg_chroma = input_lab(:,:,2);

% alles was eher Rot ist->1, Gruen->0
THRESHOLD = 0.45;
BW = im2bw(rg_chroma, THRESHOLD);

% wir wollen aber das der gruene Tisch 1 ist
BW_inv = imcomplement(BW);

% nun fuellen wir noch die Loecher auf, die die Baelle hinterlassen haben,
% als sie mit ausgeschnitten wurden, da sie nicht wirklich gruen sind
BW_filled = imfill(BW_inv, 'holes');

BW_filled = bwmorph(BW_filled,'thin',5);

% BW Bilder sind logicals, wir brauchen uint8
mask = uint8(BW_filled);

% 3x kopieren, um mit RGB kompatibel zu werden
mask3 = repmat( mask, [1 1 3]);

result = mask3;

end

