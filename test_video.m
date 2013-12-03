function [ is_ok ] = test_video(video_name) 
%UNTITLED Tests the given video
%   Author: Florian Krall
%   Tests the video with the given name (in the res folder)

video_path = [pwd,filesep,'res',filesep,video_name];

videoReader = vision.VideoFileReader(video_path,'ImageColorSpace','RGB','VideoOutputDataType','uint8');
converter = vision.ImageDataTypeConverter; 
converter.OutputDataType = 'uint8';

frame = step(videoReader);
im = step(converter, frame);

% -------------------------------------------------------------------------

% 1. Bildaufloesung: Minimal 480x360 Bildpunkte

[y,x,z]=size(im);
is_ok = x >= 480 && y >= 360;
if ~is_ok
	return
end

% -------------------------------------------------------------------------

% 2. Farbige Kugeln (nicht rot/weiss) muessen gefunden werden (falls am Tisch vorhanden)

% -------------------------------------------------------------------------

% 3. Jede Kugel darf nur hoechstens 1 mal am Tisch erkannt werden

% -------------------------------------------------------------------------

% 4. Aufnahmewinkel: Der Tisch muss eine bestimmte Form haben (Trapez):

% Get Mask:
cform = makecform('srgb2lab');
input_lab = applycform(im, cform); 
rg_chroma = input_lab(:,:,2);
BW = im2bw(rg_chroma, 0.45);

% Fill Table and remove artifacts:
BW = bwareaopen(BW, 500);
BW = imcomplement(BW);
BW = bwareaopen(BW, 500);
BW = imcomplement(BW);

BW = edge(BW, 'canny', 0.99, 10.0);

corners = corner(BW, 'Harris', 4, 'QualityLevel', 0.70);
imshow(BW)
hold on
[rows,cols] = size(corners);
for i=1:(rows)
    plot(corners(i,1), corners(i,2), 'r.', 'MarkerSize', 20)
end

is_ok = rows == 4;
if ~is_ok
	return
end

a = [corners(1,1), corners(1,2)];	% Rechts oben
b = [corners(2,1), corners(2,2)];	% Rechts unten
c = [corners(3,1), corners(3,2)];	% Links unten

% Vielleicht mit vision.cornerDetector versuchen...

% Die Trapezschenkel muessen mindestens 2/3 der unteren Linie betragen
% (einer reicht):

% Laenge der horizontalen Linie ermitteln:
vert = sqrt((a(1)-b(1))^2+(a(2)-b(2))^2);

% Laenge der vertikalen Linie ermitteln:
hor = sqrt((b(1)-c(1))^2+(b(2)-c(2))^2);

% Laenge vergleichen:
is_ok = ((hor/3)*2) <= vert;
end
