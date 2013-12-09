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

% Kann nur vom Benutzer verifiziert werden…

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
%BW = imcomplement(BW);

%regionprops(bw).BoundingBox

BW = edge(BW, 'canny', 0.9, 10.0);

[H,theta,rho] = hough(BW);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength',7)

% Linien erzeugen:
fit_func = fittype('poly1'); 
line_new = [2*length(lines) 2];
for k = 1:length(lines)
    i = k*2;
    line_new(i-1,1) = lines(k).point1(1);
    line_new(i-1,2) = lines(k).point1(2);
    line_new(i,1) = lines(k).point2(1);
    line_new(i,2) = lines(k).point2(2);
end


imshow(BW)
hold on
for k = 1:length(lines)
    i = k*2;
    line_one = fit(line_new(i-1:i,1),line_new(i-1:i,2),fit_func);
    line_two = fit(line_new(i-1:i,1),line_new(i-1:i,2),fit_func);
    first_y_one = line_one(0);
    last_y_one = line_one(x);
    first_y_two = line_one(0);
    last_y_two = line_one(x);
    
    % Schnittpunkte der Linien erzeugen:
    [xi,yi] = polyxpoly([0,x],[first_y_one, last_y_one],[0,x],[first_y_two, last_y_two])
    plot(xi, yi);
end
hold off




corners = corner(BW, 'Harris', 4, 'QualityLevel', 0.70);
% imshow(BW)
% hold on
% [rows,cols] = size(corners);
% for i=1:(rows)
%     plot(corners(i,1), corners(i,2), 'r.', 'MarkerSize', 20)
% end
% hold off

%is_ok = rows == 4;
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

% Offizieller Turniertisch: 3556 mm × 1778 mm (jeweils +/- 13 mm)

% Laenge vergleichen:
is_ok = ((hor/3)*2) <= vert;
end
