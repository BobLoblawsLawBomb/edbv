function [ output_args ] = mainfunction()%argument:  video_path 
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
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
opticalFlow.ReferenceFrameSource = 'Input port';
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form';
shapeInserterLine = vision.ShapeInserter('Shape','Lines','BorderColor','Custom', 'CustomBorderColor', [255 255 255]);
videoPlayer = vision.VideoPlayer('Name','Motion Vector');

%Tisch ausschneiden / Maske erstellen
frameNo = 1;
frame = step(videoReader);
im = step(converter, frame);
mask = table_mask(im);
im = im.*mask;
gim = single(rgb2gray(im))./255;

%TODO: Matrix anlegen die f?r jeden Ball die Component-Maske speichert.
%compMask;

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
%compPosition;

%TODO: VektorMatrix anlegen die f?r jeden Frame f?r jeden Ball einen Richtungsvektor speichert
%Form: 
%A = [1 2]; %Richtung von Ball 1 in Frame 1
%A(:,:,2) = [2 3];	 %Richtung von Ball 2 in Frame 1
%A(:,:,1,2) = [2 2]; %Richtung von Ball 1 in Frame 2
%A(:,:,2,2) = [3 3]; %Richtung von Ball 2 in Frame 2
compVelocity = [0 0];

%TODO: Datenstruktur f?r die Component-Masken festlegen (pro Ball separat oder eine Maske f?rs gesamte Bild)

while ~isDone(videoReader)
    
    if(frameNo == 1)
        %TODO: Erstes Component Labeling anwenden
        %componenten nach label getrennt, 
        %kann noch fragmente vom tisch bzw. k? enthalten
        [resultBW, resultColor] = connectedComponent(im);
        
        %Component Velocities f?r jeden Ball im ersten Frame auf 0 setzen
        i = 1;
        while(i <= size(resultBW))
            compVelocity(:, :, i, 1) = [0 0];
            i = i + 1;
        end
    else
        %N?chsten Frame auslesen
        im = step(converter, step(videoReader)).*mask;
        gim = single(rgb2gray(im))./255;
        
        %Components im neuen Frame finden und passende Maske speichern.
        i = 1;
        while(i <= size(resultBW))
            resultBW{i} = getNewMask(resultBW{i}, compVelocity(:, :, i, frameNo - 1), 5, im);
            i = i + 1;
        end
        
        %OpticalFlow auf aktuellen Frame, unter ber?ckichtung des vorhergehenden, anwenden.
        of = step(opticalFlow, gim, lastgim);
        
        % --- OPTICAL FLOW TEST OUTPUT ---
        lines = int32(videooptflowlines(of, 30));
        
        if ~isempty(lines)
            out = step(shapeInserterLine, im, lines);
            step(videoPlayer, out);
        end
        % --------------------------------
        
        %TODO: Mit Component-Masken und OpticalFlow-Vektoren
        %      Geschwindigkeitsvektoren der einzelnen Components ermitteln.
        %calcComponentVelocity(of, componentMask);
        i = 1;
        while(i <= size(resultBW))
            compVelocity(:, :, i, frameNo) = getNewMask(of, resultBW{i});
            i = i + 1;
        end
    end
    
    %TODO: Mit Component-Masken
    %      Positionsvektoren der einzelnen Components ermitteln.
    
    lastim = im;
    lastgim = gim;
    frameNo = frameNo + 1;
end

% --- FOR OPTICAL FLOW TEST OUTPUT ---
release(videoPlayer);
release(videoReader);
% --------------------------------

%TODO: Linien-Overlay erzeugen und ?ber den letzten Frame legen, sowie als
%      Resultat zur?ckgeben.

output_args = im;

end

