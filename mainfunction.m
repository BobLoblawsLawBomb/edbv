function [ output_args ] = mainfunction( video_path )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

videoReader = vision.VideoFileReader(video_path,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
converter = vision.ImageDataTypeConverter; 
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form';
shapeInserterLine = vision.ShapeInserter('Shape','Lines','BorderColor','Custom', 'CustomBorderColor', 255);
shapeInserterPoint = vision.ShapeInserter('Shape','Circles','BorderColor','Custom', 'CustomBorderColor', 125);
videoPlayer = vision.VideoPlayer('Name','Motion Vector');

%TODO: Tisch ausschneiden / Maske erstellen
%TODO: VektorMatrix anlegen die f�r jeden Frame f�r jeden Ball einen Positionsvektor speichert
%TODO: VektorMatrix anlegen die f�r jeden Frame f�r jeden Ball einen Richtungsvektor speichert

while ~isDone(videoReader)
    frame = step(videoReader);
    im = step(converter, frame);
    
    


    
    %TODO: image und reference Frame an opticalFlow �bergeben
    %of = step(opticalFlow, im, ref);
    of = step(opticalFlow, im);

    lines = videooptflowlines(of, 30);
    %points = lines(1:end, 1:2);
    %points(1:end, 3) = 0.5;
    if ~isempty(lines)
      %out =  step(shapeInserterPoint, im, points); 
      out =  step(shapeInserterLine, im, lines); 
      step(videoPlayer, out);
    end
end

release(videoPlayer);
release(videoReader);


end

