function [ is_ok ] = test_video()%argument:  video_path 
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%default test video path
%
% relative pfade scheinen mit dem videfilereader auf
% unix systeme nicht zu funktionieren, siehe http://blogs.bu.edu/mhirsch/2012/04/matlab-r2012a-linux-computer-vision-toolbox-bug/
%
video_path = [pwd,filesep,'res',filesep,'test.mp4'];

videoReader = vision.VideoFileReader(video_path,'ImageColorSpace','RGB','VideoOutputDataType','uint8');
converter = vision.ImageDataTypeConverter; 
converter.OutputDataType = 'uint8';

frame = step(videoReader);
im = step(converter, frame);

% Bildauflösung: Minimal 480×360 Bildpunkte

[x,y]=size(image);
is_ok = x >= 480 && y >= 360
if ~is_ok
	return
end

% Farbige Kugeln (nicht rot/weiß) müssen gefunden werden (falls am Tisch vorhanden)

% Jede Kugel darf nur höchstens 1 mal am Tisch erkannt werden

% Aufnahmewinkel: Der Tisch muss eine bestimmte Form haben (Trapez)

% Get Mask:
cform = makecform('srgb2lab');
input_lab = applycform(input, cform); 
rg_chroma = input_lab(:,:,2);
BW = im2bw(rg_chroma, 0.45);

%# get boundary
B = bwboundaries(BW, 8, 'noholes');
B = B{1};

%%# boundary signature
%# convert boundary from cartesian to ploar coordinates
objB = bsxfun(@minus, B, mean(B));
[theta, rho] = cart2pol(objB(:,2), objB(:,1));

%# find corners
%#corners = find( diff(diff(rho)>0) < 0 );     %# find peaks
[~,order] = sort(rho, 'descend');
corners = order(1:10);

ca = corners(1);	% Links oben
cb = corners(2);	% Links unten
cb = corners(3);	% Rechts unten

% Die Trapezschenkel müssen mindestens 2/3 der unteren Linie betragen (einer reicht)
% Länge der horizontalen Linie ermitteln
% Länge der vertikalen Linie ermitteln
% Länge vergleichen


end
