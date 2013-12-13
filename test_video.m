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
    disp('Die Auflösung ist zu niedrig');
	return
end

% -------------------------------------------------------------------------

% 2. Farbige Kugeln (nicht rot/weiss) muessen gefunden werden (falls am Tisch vorhanden)

% Kann nur vom Benutzer verifiziert werden!

% -------------------------------------------------------------------------

% 3. Jede Kugel darf nur hoechstens 1 mal am Tisch erkannt werden

% -------------------------------------------------------------------------

% 4. Aufnahmewinkel: Der Tisch muss eine bestimmte Form haben (Trapez):

 im = imresize(im,[360 NaN]);
 [y,x,z]=size(im);

% Maske holen:
cform = makecform('srgb2lab');
input_lab = applycform(im, cform); 
rg_chroma = input_lab(:,:,2);
BW = im2bw(rg_chroma, 0.45);

% Tisch fuellen und Artefakte entfernen:
BW = bwareaopen(BW, 1000, 4);
BW = imcomplement(BW);
BW = bwareaopen(BW, 1000, 4);

BW = edge(BW, 'canny', 0.9, 16.0);
[H,theta,rho] = hough(BW);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,theta,rho,P,'FillGap',200,'MinLength',100);

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

corners = [0 0];
index = 0;
imshow(im);
hold on
for k = 1:length(lines)
    i = k*2;
    
    line = fit(line_new(i-1:i,1),line_new(i-1:i,2),fit_func);
    first_y = line(0);
    last_y = line(x);
    
    for l = (k+1):length(lines)
        j = l*2;
        line = fit(line_new(j-1:j,1),line_new(j-1:j,2),fit_func);
        first_y_2 = line(0);
        last_y_2 = line(x);
        
        % Linien entlang der Tischgrenze erzeugen:
        [xi,yi] = polyxpoly([0,x],[first_y, last_y],[0,x],[first_y_2, last_y_2], 'unique');
        if xi>0 & yi>0
            plot(xi, yi, 'r.', 'MarkerSize', 20);
            index = index + 1;
            corners(index, 1) = xi;
            corners(index, 2) = yi;
        end
    end
    
    plot([0,x], [first_y, last_y]);
end
hold off

is_ok = index == 4;
if ~is_ok
    disp('Es konnten nicht genau 4 Ecken des Tisches erkannt werden');
	return
end

a = [corners(1,1), corners(1,2)];
b = [corners(2,1), corners(2,2)];
c = [corners(3,1), corners(3,2)];
d = [corners(4,1), corners(4,2)];

y_sorted = sort([a(2),b(2),c(2),d(2)]);
x_sorted = sort([a(1),b(1),c(1),d(1)]);

a = [x_sorted(3), y_sorted(2)];	% Rechts oben
b = [x_sorted(4), y_sorted(4)];	% Rechts unten
c = [x_sorted(1), y_sorted(3)];	% Links unten
d = [x_sorted(2), y_sorted(1)];	% Links oben

% Die Trapezschenkel muessen mindestens 5/8 der unteren Linie betragen
% (einer reicht):

% Laenge der horizontalen Linie ermitteln:
vert = sqrt((a(1)-b(1))^2+(a(2)-b(2))^2)

% Laenge der vertikalen Linie ermitteln:
hor = sqrt((b(1)-c(1))^2+(b(2)-c(2))^2)

% Offizieller Turniertisch: 3556 mm Ã— 1778 mm (jeweils +/- 13 mm)

% Laenge vergleichen:
is_ok = ((hor*5)/8) <= vert;

if ~is_ok
    disp('Der Aufnahmewinkel passt nicht.');
else
    disp('Das Video scheint in Ordnung zu sein.');
end
end
