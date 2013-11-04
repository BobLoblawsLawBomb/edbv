function [ output_args ] = mainfunction()%argument:  video_path 
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%default test video path
video_path = 'res\test.mp4';

videoReader = vision.VideoFileReader(video_path,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
converter = vision.ImageDataTypeConverter; 
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form';
shapeInserterLine = vision.ShapeInserter('Shape','Lines','BorderColor','Custom', 'CustomBorderColor', 255);
%shapeInserterPoint = vision.ShapeInserter('Shape','Circles','BorderColor','Custom', 'CustomBorderColor', 125);
videoPlayer = vision.VideoPlayer('Name','Motion Vector');

%Tisch ausschneiden / Maske erstellen
frame = step(videoReader);
im = step(converter, frame);
mask = table_mask(im);

%TODO: VektorMatrix anlegen die f?r jeden Ball eine Farbe speichert
%Form:
%BC = [1 0 0];        % Farbe von Ball 1 
%BC(:,:,2) = [1 0 1]; % Farbe von Ball 2

%TODO: VektorMatrix anlegen die f?r jeden Frame f?r jeden Ball einen Positionsvektor speichert
%Form: 
%A = [1 2]; %Position von Ball 1 in Frame 1
%A(:,:,2) = [2 3];   %Position von Ball 2 in Frame 1
%A(:,:,1,2) = [2 2]; %Position von Ball 1 in Frame 2
%A(:,:,2,2) = [3 3]; %Position von Ball 2 in Frame 2

%TODO: VektorMatrix anlegen die f?r jeden Frame f?r jeden Ball einen Richtungsvektor speichert
%Form: 
%A = [1 2]; %Richtung von Ball 1 in Frame 1
%A(:,:,2) = [2 3];	 %Richtung von Ball 2 in Frame 1
%A(:,:,1,2) = [2 2]; %Richtung von Ball 1 in Frame 2
%A(:,:,2,2) = [3 3]; %Richtung von Ball 2 in Frame 2

%TODO: Datenstruktur f?r die Component-Masken festlegen (pro Ball separat oder eine Maske f?rs gesamte Bild)

firstframe = 0;

while ~isDone(videoReader)
    
    
    if(firstframe == 0)
        %TODO: Erstes Component Labeling anwenden
    else
        %TODO: Component Labeling unter Ber?cksichtigung vergangener Frames anwenden
        frame = step(videoReader);
        im = step(converter, frame);
    end
    
    %TODO: image und reference Frame an opticalFlow ?bergeben
    %of = step(opticalFlow, im, ref);
    of = step(opticalFlow, im);

    % --- OPTICAL FLOW TEST OUTPUT ---
    lines = videooptflowlines(of, 30);
    %points = lines(1:end, 1:2);
    %points(1:end, 3) = 0.5;
    if ~isempty(lines)
      %out = step(shapeInserterPoint, im, points); 
      out = step(shapeInserterLine, im, lines); 
      step(videoPlayer, out);
    end
    % --------------------------------
    
    %TODO: Mit Component-Masken und OpticalFlow-Vektoren
    %      Geschwindigkeitsvektoren der einzelnen Components ermitteln.
    
    firstframe = 1;
end

% --- FOR OPTICAL FLOW TEST OUTPUT ---
release(videoPlayer);
release(videoReader);
% --------------------------------

%TODO: Linien-Overlay erzeugen und ?ber den letzten Frame legen, sowie als
%      Resultat zur?ckgeben.

output_args = im;

end

