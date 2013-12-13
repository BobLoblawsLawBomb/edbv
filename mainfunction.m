function [ output_args ] = mainfunction(video_path)%argument:  video_path 
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%default test video path
%
% relative pfade scheinen mit dem videfilereader auf
% unix systeme nicht zu funktionieren, siehe http://blogs.bu.edu/mhirsch/2012/04/matlab-r2012a-linux-computer-vision-toolbox-bug/
%
video_path = [pwd,filesep,'res',filesep,video_path];




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
im2 = step(converter, frame);
mask = table_mask(im2);
im2 = im2.*mask;

im = imresize(im2,[360 NaN]);

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
compPosition = [0 0];

%TODO: VektorMatrix anlegen die f?r jeden Frame f?r jeden Ball einen Richtungsvektor speichert
%Form: 
%A = [1 2]; %Richtung von Ball 1 in Frame 1
%A(:,:,2) = [2 3];	 %Richtung von Ball 2 in Frame 1
%A(:,:,1,2) = [2 2]; %Richtung von Ball 1 in Frame 2
%A(:,:,2,2) = [3 3]; %Richtung von Ball 2 in Frame 2
compVelocity = [0 0];

%TODO: Datenstruktur f?r die Component-Masken festlegen (pro Ball separat oder eine Maske f?rs gesamte Bild)
positions=cell(0);
x=1;
while ~isDone(videoReader)
    if(frameNo == 1)
        %TODO: Erstes Component Labeling anwenden
        %componenten nach label getrennt, 
        %kann noch fragmente vom tisch bzw. k? enthalten
        [resultBW, resultColor, resultRaw] = connectedComponent(im);
                
        
      
%         diameterList = zeros(length(resultBW(:)));
        
        %Component Velocities f?r jeden Ball im ersten Frame auf 0 setzen
        for i=1:length(resultBW(:))
            compPosition(:, :, i, frameNo) = getPositionOfComponent(resultBW{i});
            compVelocity(:, :, i, 1) = [0 0];
            
%             s =  regionprops(resultBW{i},'EquivDiameter');
%             diameterList(i) = s.EquivDiameter;
            
        end
                
    else
        %N?chsten Frame auslesen
%         im2 = step(converter, step(videoReader)).*mask;
        im2 = step(converter, step(videoReader));
        
        mask = table_mask(im2);
        im2 = im2.*mask;
        
        im = imresize(im2,[360 NaN]);
        
        gim = single(rgb2gray(im))./255;
        
        %Components im neuen Frame finden und passende Maske speichern.
        im_copy = im;
        
        %for debugging, stores raw mask of all components over a certain
        %velocity-threshold
        resultRaw = false(size(resultRaw));
        searchMask = false(size(resultRaw));
        
        for i=1:length(resultBW(:))
            %if(i == 3)
                pv = compPosition(:, :, i, frameNo - 1);
                cv = compVelocity(:, :, i, frameNo - 1)*100;
                
                %             disp('size(resultBW(i))');
                %             disp(size(resultBW(i)));
                %             disp('cv');
                %             disp(size(cv));
                %
                %             disp('ismember');
                
                %if isempty(resultBW(i)) || any(cellfun(@(j)isequal(j,getPositionOfComponent(cell2mat(resultBW(i)))), positions))
                %    continue;
                %end
                
                %positions{x}=getPositionOfComponent(cell2mat(resultBW(i)));
                %x=x+1;
                
                cv_length = sqrt(cv(1)*cv(1)+cv(2)*cv(2));
                
                %disp([int2str(i),', ',int2str(frameNo),', ',num2str(cv),', ',num2str(cv_length)]);
                
                if(cv_length > 0.01)
                    %resultBW{i} = getNewMask(cell2mat(resultBW(i)), cv, 50, im_copy);
                    [resultBW{i}, resultRaw_part, searchMask_part] = getNewMask(pv, cv, 7, im_copy);
                    resultRaw = or(resultRaw, logical(resultRaw_part));
                    searchMask = or(searchMask, logical(searchMask_part));
                    %mask3D = repmat( uint8(cell2mat(resultBW(i))), [1 1 3]);
                    %im_copy = mask3D.*im_copy;
                end
            %end
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
        
        %      Mit Component-Masken
        %      Positionsvektoren der einzelnen Components ermitteln.
        %      Mit Component-Masken und OpticalFlow-Vektoren
        %      Geschwindigkeitsvektoren der einzelnen Components ermitteln.
        %calcComponentVelocity(of, componentMask);
        
        %matrix um bereiche zu speichern in denen die geschwindigkeiten der
        %komponenten gemittelt werden.
        output_vmask = false(size(im2bw(im)));
        %output_cmask = false(size(im2bw(im)));
        
        %matrix um geschwindigkeits-vektor-linien zu speichern
        vlines = [0 0 0 0];
        
        %berechne positionen der komponenten
        for k = 1 : length(resultBW(:))
            compPosition(:, :, k, frameNo) = getPositionOfComponent(resultBW{k});
        end
        
        %berechne geschwindigkeiten der komponenten
        for k = 1 : length(resultBW(:))
            [vx, vy, vmask] = calcComponentVelocity(of, im, compPosition(:, :, k, frameNo), 20);
            compVelocity(:, :, k, frameNo) = [vx vy];
            
            %draw component-areas
            output_vmask = or(output_vmask, vmask);
            
            %draw component-masks
            %output_cmask = or(output_cmask, resultBW{k});
            
            %draw velocity lines
            p1 = compPosition(:, :, k, frameNo);
            vlines(k, :) = [p1(1) p1(2) p1(1)+vx*1000 p1(2)+vy*1000];
        end
        
        %optical-flow-intensitäten in matrix speichern
        vof = abs(of);
        output_mask = double(im)*0.001 + double(repmat(mat2gray(vof),[1 1 3]));
        maxv = max(max(max(output_mask)));
        if maxv > 1
            output_mask = output_mask./maxv;
        end
        
        %bereiche in denen geschwindigkeiten der komponenten gemittelt
        %werden einfärben
        output_vmask = double(repmat(output_vmask, [1 1 3]));
        output_vmask(:,:,1) = output_vmask(:,:,1)*0;
        output_vmask(:,:,2) = output_vmask(:,:,2)*0.075;
        output_vmask(:,:,3) = output_vmask(:,:,3)*0.25;
        
        %masken ebene einfärben
        output_resultRaw = double(repmat(logical(resultRaw), [1 1 3]));
        output_resultRaw(:,:,1) = output_resultRaw(:,:,1)*0;
        output_resultRaw(:,:,2) = output_resultRaw(:,:,2)*0.4;
        output_resultRaw(:,:,3) = output_resultRaw(:,:,3)*0;
        
        %such-masken ebene einfärben
        output_seachMask = double(repmat(logical(searchMask), [1 1 3]));
        output_seachMask(:,:,1) = output_seachMask(:,:,1)*0.25;
        output_seachMask(:,:,2) = output_seachMask(:,:,2)*0;
        output_seachMask(:,:,3) = output_seachMask(:,:,3)*0;
        
        %komponenten nur mit bereichen der optical-flow-intensitäts-matrix
        %mischen bei denen die intensität gering ist, damit diese gut
        %sichtbar bleibt
        output_mask = double(output_mask);
        idx = output_mask < 0.12;
        output_mask(idx) = output_mask(idx) + output_vmask(idx);
        output_mask = output_mask + output_resultRaw;
        output_mask = output_mask + output_seachMask;
        maxv = max(max(max(output_mask)));
        output_mask = output_mask./maxv;
        
        %masken einzeichnen
        
        %Einzeichnen der geschwindigkeitsvektor-linien der komponenten
        sIL = vision.ShapeInserter('Shape','Lines','BorderColor','Custom', 'CustomBorderColor', [255 0 0]);
        output_mask = step(sIL, output_mask*255, vlines);
        
        maxv = max(max(max(output_mask)));
        output_mask = output_mask./maxv;
        
        imshow(output_mask);
        
        %For movie creation at the end
        %MF(frameNo - 1) = im2frame(output_mask);
    end
    
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

im_with_line = drawline(im, compPosition);

%exports a movie for debugging purposes
%MF(frameNo - 1) = im2frame(im_with_line);
%movie2avi(MF, [pwd,filesep,'results',filesep,'debug_mov.avi'], 'Compression', 'None');

output_args = 'Success!';

end

