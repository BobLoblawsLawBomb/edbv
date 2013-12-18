function [ is_ok ] = test_video(relpath, only_first_frame, show_image) 
%UNTITLED Tests the given video
%   Author: Florian Krall
%   Tests the video at the given relative path
%   If only_first_frame is false, the whole video is analyzed (default: true)
%   If show_image is true, the result of the corner detection is shown (default: false)
%   Note:   Testing the whole video is slow and in most cases the video is 
%           classified as not suitable (so by default this is not applied). 
%           A color check is also applied, but it does not detect the 
%           proper colors, so the video is classified as suitable even if 
%           there are too much balls of one color (the result is printed to 
%           the console).

if (nargin<2)
    only_first_frame = true;
end

if (nargin<3)
    show_image = false;
end

video_path = [pwd,filesep,relpath];

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
	return;
end

% Fuer die folgenden Schritte kann das Bild verkleinert werden:
im = imresize(im,[360 NaN]);
[y,x,z]=size(im);

% -------------------------------------------------------------------------

% 2. Farbige Kugeln (nicht rot/weiss) muessen gefunden werden (falls am Tisch vorhanden)

mask = createTableMask(im);
im2 = im.*mask;

[ resultBW, resultColor, resultRaw] = connectedComponent(im2, 0.5);
componentColorList = colorClassification(resultColor, false);
number_of_black = 0;
number_of_blue = 0;
number_of_brown = 0;
number_of_green = 0;
number_of_pink = 0;
number_of_red = 0;
number_of_white = 0;
number_of_yellow = 0;

for k = 1:length(componentColorList)
    color = componentColorList(k);
    if (color{1} == 1) number_of_black = number_of_black + 1; end
    if (color{1} == 2) number_of_blue = number_of_blue + 1; end
    if (color{1} == 3) number_of_brown = number_of_brown + 1; end
    if (color{1} == 4) number_of_green = number_of_green + 1; end
    if (color{1} == 5) number_of_pink = number_of_pink + 1; end
    if (color{1} == 6) number_of_red = number_of_red + 1; end
    if (color{1} == 7) number_of_white = number_of_white + 1; end
    if (color{1} == 8) number_of_yellow = number_of_yellow + 1; end
end

% Folgendes kann nur vom Benutzer verifiziert werden:
if (number_of_black > 0) disp('Schwarze Kugel gefunden'); end
if (number_of_blue > 0) disp('Blaue Kugel gefunden'); end
if (number_of_brown > 0) disp('Braune Kugel gefunden'); end
if (number_of_green > 0) disp('Gruene Kugel gefunden'); end
if (number_of_pink > 0) disp('Pinke Kugel gefunden'); end
if (number_of_red > 0) disp('Rote Kugel gefunden'); end
if (number_of_white > 0) disp('Weisse Kugel gefunden'); end
if (number_of_yellow > 0) disp('Gelbe Kugel gefunden'); end

% -------------------------------------------------------------------------

% 3. Jede Kugel darf nur hoechstens 1 mal am Tisch erkannt werden

if (number_of_black > 1) 
    fprintf('Die schwarze Kugel wurde zu oft erkannt: %i\n', number_of_black);
    is_ok = false; 
end

if (number_of_blue > 1) 
    fprintf('Die blaue Kugel wurde zu oft erkannt: %i\n', number_of_blue);
    is_ok = false; 
end

if (number_of_brown > 1) 
    fprintf('Die braune Kugel wurde zu oft erkannt: %i\n', number_of_brown);
    is_ok = false; 
end

if (number_of_green > 1) 
    fprintf('Die gruene Kugel wurde zu oft erkannt: %i\n', number_of_green);
    is_ok = false; 
end

if (number_of_pink > 1) 
    fprintf('Die pinke Kugel wurde zu oft erkannt: %i\n', number_of_pink);
    is_ok = false; 
end

if (number_of_red > 15) 
    fprintf('Die rote Kugel wurde zu oft erkannt (max.15): %i\n', number_of_red);
    is_ok = false; 
end

if (number_of_white > 1) 
    fprintf('Die weisse Kugel wurde zu oft erkannt: %i\n', number_of_white);
    is_ok = false; 
end

if (number_of_yellow > 1) 
    fprintf('Die gelbe Kugel wurde zu oft erkannt: %i\n', number_of_yellow);
    is_ok = false; 
end

if ~is_ok
	%return;
end

% -------------------------------------------------------------------------

% 4. Aufnahmewinkel: Der Tisch muss eine bestimmte Form haben (Trapez):

loop = ~isDone(videoReader);

while loop
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
    
    if show_image == true
        imshow(im);
        hold on
    end
    
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
                if show_image == true
                    plot(xi, yi, 'r.', 'MarkerSize', 20);
                end
                
                index = index + 1;
                corners(index, 1) = xi;
                corners(index, 2) = yi;
            end
        end

        if show_image == true
            plot([0,x], [first_y, last_y]);
        end
    end
    
    if show_image == true
        hold off
    end

    is_ok = index == 4;
    if ~is_ok
        disp('Es konnten nicht genau 4 Ecken des Tisches erkannt werden');
        return;
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

    % Die Trapezschenkel muessen mindestens 9/16 der unteren Linie betragen
    % (einer reicht):

    % Laenge der horizontalen Linie ermitteln:
    vert = sqrt((a(1)-b(1))^2+(a(2)-b(2))^2);

    % Laenge der vertikalen Linie ermitteln:
    hor = sqrt((b(1)-c(1))^2+(b(2)-c(2))^2);

    % Offizieller Turniertisch: 3556 mm Ã— 1778 mm (jeweils +/- 13 mm)

    % Laenge vergleichen:
    is_ok = ((hor*9)/16) <= vert;

    if ~is_ok
        disp('Der Aufnahmewinkel passt nicht.');
        return;
    end
    
    if (only_first_frame == true)
        loop = false;
    else
        loop = ~isDone(videoReader);
        if loop
            im = step(converter, step(videoReader));
        end
    end    
end

if is_ok
   disp('Das Video scheint in Ordnung zu sein.');
end

end
