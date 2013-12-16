function [ output_args ] = mainfunction()%argument:  video_path 
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

debug = false;
debug_linedraw = true;

% default test video path

% relative pfade scheinen mit dem videfilereader auf
% unix systeme nicht zu funktionieren, siehe http://blogs.bu.edu/mhirsch/2012/04/matlab-r2012a-linux-computer-vision-toolbox-bug/

% video_path = [pwd,filesep,'res',filesep,'test_blue.mp4'];
video_path = [pwd,filesep,'res',filesep,'test_short2_3.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_1_short.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_2_short.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_3_short.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_4_short.mp4'];


%video_path = [pwd,filesep,'res',filesep,video_path];

%Initialisierung von notwendigen Parametern und Objekten
iptsetpref('ImshowBorder','tight');
videoReader = vision.VideoFileReader(video_path,'ImageColorSpace','RGB','VideoOutputDataType','uint8');
converter = vision.ImageDataTypeConverter; 
converter.OutputDataType = 'uint8';
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
opticalFlow.ReferenceFrameSource = 'Input port';
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form';
%videoPlayer = vision.VideoPlayer('Name','Motion Vector');
frameNo = 1;

%Frame-Anzahl des Videos auslesen
videoInfo = VideoReader(video_path);
numberOfFrames = videoInfo.NumberOfFrames;
clear videoInfo;

%Ersten Frame laden
frame = step(videoReader);
im2 = step(converter, frame);

%Tisch ausschneiden / Maske erstellen
mask = table_mask(im2);
im2 = im2.*mask;
im = imresize(im2,[360 NaN]);

%Graustufen-Version vom ersten Frame erstellen, wird fuer OpticalFlow benoetigt
gim = single(rgb2gray(im))./255;

%VektorMatrix anlegen die fuer jeden Frame fuer jeden Ball einen Positionsvektor speichert
%Form: 
%A = [1 2]; %Position von Ball 1 in Frame 1
%A(:,:,2) = [2 3];   %Position von Ball 2 in Frame 1
%A(:,:,1,2) = [2 2]; %Position von Ball 1 in Frame 2
%A(:,:,2,2) = [3 3]; %Position von Ball 2 in Frame 2
compPosition = [0 0];

%VektorMatrix anlegen die fuer jeden Ball eine Farbe speichert
%Form:
%BC = [1 0 0];        % Farbe von Ball 1 
%BC(:,:,2) = [1 0 1]; % Farbe von Ball 2
compClass = 0;

%Listen die beim Tracking verwendet werden um irrelevante Positionen zu
%ignorieren
compIgnore = 0;
compLostCount = 0;

%VektorMatrix anlegen die f?r jeden Frame f?r jeden Ball einen Richtungsvektor speichert
%Form: 
%A = [1 2]; %Richtung von Ball 1 in Frame 1
%A(:,:,2) = [2 3];	 %Richtung von Ball 2 in Frame 1
%A(:,:,1,2) = [2 2]; %Richtung von Ball 1 in Frame 2
%A(:,:,2,2) = [3 3]; %Richtung von Ball 2 in Frame 2
compVelocity = [0 0];

%Gehe jeden Frame im geladenen Video durch und Analysiere jeweils 2
%aufeinander folgende
while ~isDone(videoReader)
    
    %Ausgabe des Fortschritts: currentFrame / NumberOfFrames
    disp(['next Frame no: ', num2str(frameNo), ' / ', num2str(numberOfFrames)]);
    
    %Spezialbehandlung fuer den ersten Frame, hier muessen die ersten
    %Komponenten erkannt und Datenstrukturen initialisiert werden, damit in
    %den Folge-Frames das Tracking erfolgen kann.
    if(frameNo == 1)
        %Erstes Component Labeling anwenden.
        %Komponenten nach label getrennt.
        %Anmk.: kann noch fragmente vom tisch bzw. koe enthalten
        [resultBW, resultColor, resultRaw] = connectedComponent(im, 0.5);
        
        %Erste Farb-Klassifizierung anwenden.
        %Jeder Komponente wird eine Farb-Klasse zugewiesen
        compClasses = colorClassification(resultColor);
        
        %Fuer jede erkannte Komponente im ersten Frame werden benötigte
        %Matrizen initialisiert
       
        for i = 1 : length(resultBW(:))
            %Component Positionen werden aus den Masken errechnet
            compPosition(:, :, i, frameNo) = getPositionOfComponent(resultBW{i});
            
            %Component Farb-Klassen werden zugewiesen
            compClass(:, i, frameNo) = compClasses{i};
            
            %Component Velocities werden mit [0 0] initialisiert.
            compVelocity(:, :, i, 1) = [0 0];
            
            %Ignore und LostCount listen für Tracking-Informationen werden
            %mit 0 initialisiert.
            compIgnore(i) = 0;
            compLostCount(i) = 0;
        end
                
    else
        %Naechsten Frame auslesen
        im2 = step(converter, step(videoReader));
        
        %debug-time-measurement
        millis_sum1 = datevec(now);
        
        %Tisch fuer jeden Frame erneut ausschneiden um mit eventuell
        %auftretende Ueberlappungen besser umgehen zu koennen.
        mask = table_mask(im2);
        im2 = im2.*mask;
        im = imresize(im2,[360 NaN]);
        
        %Graustufen-Version von Frame erstellen, wird fuer OpticalFlow
        %benoetigt
        gim = single(rgb2gray(im))./255;
        
        %OpticalFlow mit vorherigen und aktuellen Frame anwenden.
        tic;
        of = step(opticalFlow, gim, lastgim);
        millis_of = toc*1000;
        
        %Aus den Bewegungsvektoren auf dem Bild, welche durch OpticalFlow 
        %generiert wurden, zusammenhaengende Bereiche ueber einem gewissen 
        %geschwindigkeits-niveau via component-labeling segmentieren.
        %Damit kann festgestellt werden in welchen Bereichen des Bildes
        %sich etwas bewegt und wo auf jedenfall etwas still steht.
        
        %Geschwindigkeit pro Pixel berechnen.
        ofVelocity = abs(of);
        
        %Eine Maske erstellen die nur geschwindigkeiten ueber einem
        %gewissen level beinhaltet.
        ofVelocityFiltered = zeros(size(ofVelocity));
        ofVelocityFiltered(ofVelocity(:,:) > 0.01) = 1;
        
        %Connected Component Labeling auf OpticalFlow-Feld anwenden.
        tic;
        [of_comps, of_comp_count] = ccl_labeling( ofVelocityFiltered );
        millis_of_labeling = toc*1000;
        
        %Zur Fehler-Korrektur damit die Matrix nicht automatisch
        %verkleinert wird und immer zumindest eine gewisse groesse hat.
        %Es muessen mindestens zwei eintraege enthalten sein. Sonst gibt es 
        %probleme bei size() aufrufen und iterationen ueber die matrizen.
        ofCompMasks(:,:,1,1) = zeros(size(gim));
        ofCompMasks(:,:,1,2) = zeros(size(gim));
        ofCompPositions(:,:,1,1) = [-1, -1];
        ofCompPositions(:,:,1,2) = [-1, -1];
        
        %for debugging output - initialisiere bild matrizen
        if(debug)
            of_comp2 = double(repmat(zeros(size(of)),[1 1 1]));
            ofpvis = double(repmat(zeros(size(of)),[1 1 3]));
        end
        %--------------------
        
        tic; 
        
        %Erstelle eine Multi-Matrix zum speichern der OpticalFlow-Masken
        %und Positionen der selben. In der Schleife werden relevante Masken
        %hinzugefuegt.
        ofc_idx = 3;
        for i = 1 : of_comp_count
            
            %lösche alles was nicht zur aktuellen komponente (ID = i) gehört.
            of_comp = of_comps;
            of_comp(of_comp < i | of_comp > i) = 0;
            
            %Wenn die flaeche einer OpticalFlow-Komponente unter einem
            %gewissen wert ist, soll sie ignoriert werden, da sie hoechst
            %wahrscheinlich ein artefakt ist.
            if(sum(sum(of_comp)) < 100)
                continue
            end
            
            %for debugging output
            if(debug)
                of_comp2 = or(of_comp2, of_comp);
            end
            %--------------------
            
            of_comp = logical(of_comp);
            ofCompMasks(:,:,1,ofc_idx) = of_comp;
            ofCompPositions(:,:,1,ofc_idx) = int32(fliplr(getPositionOfComponent(of_comp)));
            
            %for debugging output
            if(debug)
                point = ofCompPositions(:,:,1,ofc_idx);
                ofpvis(point(1), point(2), 1) = 0;
                ofpvis(point(1), point(2), 2) = 1;
                ofpvis(point(1), point(2), 3) = 1;
            end
            %--------------------
            
            ofc_idx = ofc_idx + 1;
        end
        
        millis_comp_pos = toc*1000;
        
        %for debugging output
        if(debug)
            figure(7)
            of_comp2 = double(repmat(of_comp2, [1 1 3]));
            of_comp2 = (of_comp2 + ofpvis);
            of_comp2 = of_comp2 / max(max(max(of_comp2)));
            imshow(of_comp2);
        end
        %--------------------
        
        %for debugging output
        if(debug)
            cppvis = double(repmat(zeros(size(of)),[1 1 3]));
            cppvis_old = double(repmat(zeros(size(of)),[1 1 3]));
        end
        %--------------------
        
        %Initialisiere Liste von Compoenten Positionen und Farb-Klassen vom
        %vorherigen Frame.
        compPositionSize = size(compPosition);
        oldCompPositions = zeros(1, 2, compPositionSize(3));
        oldCompClasses = zeros(1, compPositionSize(3));
        
        %Speichere fuer jede Komponente im vorherigen Frame informationen.
        for i = 1 : compPositionSize(3)
            oldCompPositions(:, :, i) = int32(fliplr(compPosition(:, :, i, frameNo - 1)));
            oldCompClasses(:, i) = compClass(:, i, frameNo - 1);
            
            %Setze error code fuer Position und Farb-Klasse der Komponente 
            %im aktuellen Frame, für den Fall, dass sie nicht wieder gefunden 
            %wird und kein neuer Eintrag dazu kommt
            compPosition(:, :, i, frameNo) = NaN;
            compClass(:, i, frameNo) = NaN;
            
            %for debugging output
            if(debug)
                oldCompPosition = oldCompPositions(:, :, i);
                cppvis_old(oldCompPosition(1), oldCompPosition(2), 1) = 1;
                cppvis_old(oldCompPosition(1), oldCompPosition(2), 2) = 1;
                cppvis_old(oldCompPosition(1), oldCompPosition(2), 3) = 0;
            end
            %--------------------
        end
        
        %Ball-Komponenten mit Connected Component Labeling im aktuellen Frame
        %finden.
        tic;
        [resultBW, resultColor, resultRaw] = connectedComponent(im, 0.5);
        millis_comp_labeling = toc*1000;
        
        %Farb-Klassifizierung im aktuellen Frame anwenden.
        %Jeder Komponente wird eine Farb-Klasse zugewiesen
        tic;
        compClasses = colorClassification(resultColor);
        millis_color_class = toc*1000;
        
        %Initialisiere Liste von Compoenten Positionen und Farb-Klassen vom
        %aktuellen Frame.
        newPositionSize = size(resultBW);
        newCompPositions = zeros(newPositionSize(2), 2);
        newCompClasses = zeros(newPositionSize(2), 1);
        
        %Speichere fuer jede Komponente im aktuellen Frame informationen.
        for i = 1 : newPositionSize(2)
            newCompPositions(i,:) = int32(getPositionOfComponent(resultBW{i}));
            newCompClasses(i) = compClasses{i};
            
            %for debugging output
            if(debug)
                newCompPosition = newCompPositions(i,:);
                cppvis(newCompPosition(2), newCompPosition(1), 1) = 1;
                cppvis(newCompPosition(2), newCompPosition(1), 2) = 0;
                cppvis(newCompPosition(2), newCompPosition(1), 3) = 1;
            end
            %--------------------
        end
        
        tic;
        
        %Zu jeder Komponente die im aktuellen Frame gefunden wurde, wird 
        %versucht die selbe Komponente im vorherigen Frame zu finden und
        %zuzuweisen.
        [oldCompIndices, vx, vy, output_vmask, output_cmask, vlines] = tryToLinkComponents(oldCompPositions, newCompPositions, oldCompClasses, newCompClasses, ofCompMasks, ofCompPositions, of, 6, 5, compIgnore);% [5, 4]
        
        %Jede Komponente im aktuellen Frame wird der gefundenen Komponente
        %aus dem vorherigen Frame zugewiesen, falls keine gefunden wurde
        %wird eine neue angelegt, die getrackt werden kann.
        for i = 1 : length(resultBW(:))
            oldCompIndex = oldCompIndices(i);
            newCompPosition = newCompPositions(i,:);
            newCompClass = newCompClasses(i);
            
            %for debugging output
            if(debug)
                cppvis(newCompPosition(2), newCompPosition(1), 1) = 1;
                cppvis(newCompPosition(2), newCompPosition(1), 2) = 0;
                cppvis(newCompPosition(2), newCompPosition(1), 3) = 1;
            end
            %--------------------
            
            %Falls keine entsprechung der aktuellen Komponente im
            %vorherigen Frame gefunden wurde (==0), wird eine neue Angelegt,
            %falls schon (~=0), wird die neue Position der vorherigen
            %Komponente angehaengt.
            if(oldCompIndex > 0)
                compPosition(:, :, oldCompIndex, frameNo) = newCompPosition;
                compClass(:, oldCompIndex, frameNo) = newCompClass;
                
                %for debugging output - draw velocity lines
                if(debug)
                    p1 = compPosition(:, :, oldCompIndex, frameNo);
                    vlines(oldCompIndex, :) = [p1(1) p1(2) p1(1)+vx(i) p1(2)+vy(i)];
                end
                %--------------------
            elseif(oldCompIndex == 0)
                %Es wird eine neue Komponete hinzugefuegt
                
                %Default wert fuer Tracking-Infos setzen
                compIgnore(compPositionSize(3) + 1) = 0;
                compLostCount(compPositionSize(3) + 1) = 0;
                
                %Fuer jeden vergangenen Frame die entsprechende Farbe und
                %Position setzen, als ob die Komponente immer schon da war
                for j = 1 : frameNo
                    compPosition(:, :, compPositionSize(3) + 1, j) = newCompPosition;
                    compClass(:, compPositionSize(3) + 1, j) = newCompClass;
                end
                
                %for debugging output
                if(debug)
                    disp(['create new Component: ', num2str(compPositionSize(3) + 1), ' at ', num2str(newCompPosition(1)), ' ', num2str(newCompPosition(2))]);
                end
                %--------------------
            end
        end
        
        %Falls eine Komponente im neuen Frame nicht gefunden wurde und
        %daher keine entsprechende zuweisung zu einer Komponente vom
        %vorherigen Frame gefunden wurde ist der Positionswert im neuen
        %Frame auf NaN gesetzt. Bei diesen Komponenten koennen die alten
        %Positionen einfach uebernommen werden.
        compPositionSize = size(compPosition);
        for i = 1 : compPositionSize(3)
            if isnan(compPosition(:, :, i, frameNo))
                compPosition(:, :, i, frameNo) = compPosition(:, :, i, frameNo - 1);
                compClass(:, i, frameNo) = compClass(:, i, frameNo - 1);
                
                %Fuer jedes mal wenn die Komponente nicht gefunden wurde
                %wirde der LostCount erhoeht
                compLostCount(i) = compLostCount(i) + 1;
                
                %Wenn eine Komponente 3 mal hintereinander nicht erkannt
                %wurde, wird sie in der zukunft ignoriert. damit wird
                %verhindert, dass komponenten sich beim tracking zu nicht
                %existierenden artefakten verbinden.
                if(compLostCount(i) > 3)
                    compIgnore(i) = 1;
                end
            end
            %TODO eventuell: else compLostCount(i) = 0; damits immer nur 3 mal hintereinander ist, nicht in summe.
        end
        
        %for debugging output
        if(debug)
            disp(['ignore: ', num2str(sum(compIgnore)), ' / ', num2str(length(compIgnore))]);
        end
        %--------------------
        
        millis_linking = toc*1000;
        
        millis_sum2 = datevec(now);
        millis_sum = (millis_sum2(6) - millis_sum1(6))*1000;
        
        %linedraw-debugging-output
        if(debug_linedraw)
            
            tic;
            
            %get Colors
            cols = zeros(compPositionSize(3), 3);
            for i = 1 : compPositionSize(3)
                cols(i,:) = BucketManager.getBucket(compClass(:,i)).rgbColor/255;
            end
            
            imsize = size(im);
            lineimg = drawLines(imsize, compPosition, cols, 1);
        
            millis_linedraw = toc*1000;
            
            alphablender = vision.AlphaBlender('Operation','Binary mask', 'Mask', uint8(im2bw(lineimg, 0.99)), 'MaskSource', 'Property');
            lineimg = step(alphablender, lineimg, im);
            
            textInserter = vision.TextInserter([num2str(frameNo), ' / ', num2str(numberOfFrames)],'Color', [255,255,255], 'FontSize', 24, 'Location', [20 20]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis OF: ', num2str(millis_of)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 55]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis OF Mask: ', num2str(millis_of_labeling)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 70]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis Comp Mask: ', num2str(millis_comp_labeling)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 85]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis Comp Pos: ', num2str(millis_comp_pos)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 100]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis Comp Color: ', num2str(millis_color_class)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 115]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis Linking: ', num2str(millis_linking)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 130]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis Linedraw: ', num2str(millis_linedraw)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 145]);
            lineimg = step(textInserter, lineimg);
            textInserter = vision.TextInserter(['Millis Sum: ', num2str(millis_sum)],'Color', [255,255,255], 'FontSize', 12, 'Location', [20 160]);
            lineimg = step(textInserter, lineimg);
            
            figure(10);
            imshow(lineimg);
        
        end
        %--------------------
        
        %for debugging output
        if(debug)
            
            output_mask = double(lastim)*0.001 + double(repmat(mat2gray(ofVelocity),[1 1 3]));
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
            
            output_cmask = double(repmat(output_cmask, [1 1 3]));
            output_cmask(:,:,1) = output_cmask(:,:,1)*0.15;
            output_cmask(:,:,2) = output_cmask(:,:,2)*0;
            output_cmask(:,:,3) = output_cmask(:,:,3)*0;
            
            %masken ebene einfärben
            %output_resultRaw = double(label2rgb(resultRaw));
            output_resultRaw = double(repmat(resultRaw,[1 1 3]));
            output_resultRaw(output_resultRaw(:,:,1:3) == 255) = 0;
            output_resultRaw(:,:,1) = output_resultRaw(:,:,1)*0;
            output_resultRaw(:,:,2) = output_resultRaw(:,:,2)*1;
            output_resultRaw(:,:,3) = output_resultRaw(:,:,3)*0;
            
            output_complabels = double(label2rgb(resultRaw));
            output_complabels(output_complabels(:,:,1:3) == 255) = 0;
            
            figure(15);
            imshow(output_complabels);
            
            %komponenten nur mit bereichen der optical-flow-intensitäts-matrix
            %mischen bei denen die intensität gering ist, damit diese gut
            %sichtbar bleibt
            output_mask = double(output_mask);
            idx = output_mask < 0.12;
            output_mask(idx) = output_mask(idx) + output_vmask(idx)*2;
            output_mask(idx) = output_mask(idx) + output_cmask(idx);
            
            maxv = max(max(max(output_mask)));
            output_mask = output_mask./maxv;
            
            output_mask = output_mask + (output_resultRaw/125);
            maxv = max(max(max(output_mask)));
            output_mask = output_mask./maxv;
            
            output_mask = output_mask + ofpvis;
            maxv = max(max(max(output_mask)));
            output_mask = output_mask./maxv;
            
            output_mask = output_mask + cppvis/2;
            maxv = max(max(max(output_mask)));
            output_mask = output_mask./maxv;
            
            output_mask = output_mask + cppvis_old/2;
            maxv = max(max(max(output_mask)));
            output_mask = output_mask./maxv;
            
            %masken einzeichnen
            
            %Einzeichnen der geschwindigkeitsvektor-linien der komponenten
            sIL = vision.ShapeInserter('Shape','Lines','BorderColor','Custom', 'CustomBorderColor', [255 0 0]);
            output_mask = step(sIL, output_mask*255, vlines);
            
            maxv = max(max(max(output_mask)));
            output_mask = output_mask./maxv;
            
            figure(1)
            imshow(output_mask);
            
        end
        
        %For movie creation at the end
%         MF(frameNo - 1) = im2frame(output_mask);
    end
    
    %Vorbereitung fuer naechsten Frame
    lastim = im;
    lastgim = gim;
    frameNo = frameNo + 1;
end

% video reader freigeben
release(videoReader);

%Zeichne die Linien der getrackten Komponenten in ihren Farben

%Farben auslesen
compPositionSize = size(compPosition);
cols = zeros(compPositionSize(3), 3);
for i = 1 : compPositionSize(3)
    cols(i,:) = BucketManager.getBucket(compClass(:,i)).rgbColor/255;
end

%Linien zeichnen
lineimg = drawLines(size(im), compPosition, cols, 1);

%Linien ueber letzten Frame zeichnen
alphablender = vision.AlphaBlender('Operation','Binary mask', 'Mask', uint8(im2bw(lineimg, 0.99)), 'MaskSource', 'Property');
lineimg = step(alphablender, lineimg, im);

%Version mit Border um die linien
% lineimg = drawLines(size(im), compPosition, zeros(compPositionSize(3), 1, 3), 2);
% lineimg2 = drawLines(imsize, compPosition, repmat([0.9 0.9 0.9],[compPositionSize(3), 1, 1]), 1);
% alphablender = vision.AlphaBlender('Operation','Binary mask', 'Mask', uint8(im2bw(lineimg2, 0.99)), 'MaskSource', 'Property');
% lineimg = step(alphablender, lineimg2, lineimg);
% alphablender = vision.AlphaBlender('Operation','Binary mask', 'Mask', uint8(im2bw(lineimg, 0.99)), 'MaskSource', 'Property');
% lineimg = step(alphablender, lineimg, im);

%Bild ausgeben
figure(1, 'name', 'Result');
imshow(lineimg);

%exports a movie for debugging purposes
% MF(frameNo - 1) = im2frame(im_with_line);
% movie2avi(MF, [pwd,filesep,'results',filesep,'debug_mov.avi'], 'Compression', 'None');

output_args = 'Success!';

end

