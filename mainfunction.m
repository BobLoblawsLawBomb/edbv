function [ output_args ] = mainfunction()%argument:  video_path 
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

iptsetpref('ImshowBorder','tight');

%default test video path
%
% relative pfade scheinen mit dem videfilereader auf
% unix systeme nicht zu funktionieren, siehe http://blogs.bu.edu/mhirsch/2012/04/matlab-r2012a-linux-computer-vision-toolbox-bug/
%
% video_path = [pwd,filesep,'res',filesep,'test_blue.mp4'];
video_path = [pwd,filesep,'res',filesep,'test_short2_3.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_1_short.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_2_short.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_3_short.mp4'];
% video_path = [pwd,filesep,'res',filesep,'test_hd_4_short.mp4'];


%video_path = [pwd,filesep,'res',filesep,video_path];


videoReader = vision.VideoFileReader(video_path,'ImageColorSpace','RGB','VideoOutputDataType','uint8');
videoInfo = VideoReader(video_path);
numberOfFrames = videoInfo.NumberOfFrames;
clear videoInfo;
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

compClass = 0;

compIgnore = 0;
compLostCount = 0;


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
    disp(['next Frame no: ', num2str(frameNo), ' / ', num2str(numberOfFrames)]);
    
    if(frameNo == 1)
        %TODO: Erstes Component Labeling anwenden
        %componenten nach label getrennt, 
        %kann noch fragmente vom tisch bzw. koe enthalten
        [resultBW, resultColor, resultRaw] = connectedComponent(im, 0.5);
        compClasses = colorClassification(resultColor);
        
%         diameterList = zeros(length(resultBW(:)));
        
        %Component Velocities f?r jeden Ball im ersten Frame auf 0 setzen
        for i = 1 : length(resultBW(:))
%             p = getPositionOfComponent(resultBW{i});
%             disp([num2str(frameNo), ' ', num2str(i), ' ',num2str(p)]);
%             disp(sum(sum(resultBW{i})));
            compPosition(:, :, i, frameNo) = getPositionOfComponent(resultBW{i});
            compClass(:, i, frameNo) = compClasses{i};
            compVelocity(:, :, i, 1) = [0 0];
            compIgnore(i) = 0;
            compLostCount(i) = 0;
            
%             s =  regionprops(resultBW{i},'EquivDiameter');
%             diameterList(i) = s.EquivDiameter;
            
        end
                
    else
        %N?chsten Frame auslesen
%         im2 = step(converter, step(videoReader)).*mask;
        im2 = step(converter, step(videoReader));
        
        millis_sum1 = datevec(now);
        
        mask = table_mask(im2);
        im2 = im2.*mask;
        
        im = imresize(im2,[360 NaN]);
        
        gim = single(rgb2gray(im))./255;
        
        %Components im neuen Frame finden und passende Maske speichern.
        im_copy = im;
        
        %for debugging, stores raw mask of all components over a certain
        %velocity-threshold
%         resultRaw = false(size(resultRaw));
%         searchMask = false(size(resultRaw));
        
%         for i=1:length(resultBW(:))
%             %if(i == 3)
%                 pv = compPosition(:, :, i, frameNo - 1);
%                 cv = compVelocity(:, :, i, frameNo - 1)*100;
%                 
%                 %             disp('size(resultBW(i))');
%                 %             disp(size(resultBW(i)));
%                 %             disp('cv');
%                 %             disp(size(cv));
%                 %
%                 %             disp('ismember');
%                 
%                 %if isempty(resultBW(i)) || any(cellfun(@(j)isequal(j,getPositionOfComponent(cell2mat(resultBW(i)))), positions))
%                 %    continue;
%                 %end
%                 
%                 %positions{x}=getPositionOfComponent(cell2mat(resultBW(i)));
%                 %x=x+1;
%                 
%                 cv_length = sqrt(cv(1)*cv(1)+cv(2)*cv(2));
%                 
%                 %disp([int2str(i),', ',int2str(frameNo),', ',num2str(cv),', ',num2str(cv_length)]);
%                 
%                 if(cv_length > 0.01)
%                     %resultBW{i} = getNewMask(cell2mat(resultBW(i)), cv, 50, im_copy);
%                     [resultBW{i}, resultRaw_part, searchMask_part] = getNewMask(pv, cv, 7, im_copy, 0.5);
%                     resultRaw = or(resultRaw, logical(resultRaw_part));
%                     searchMask = or(searchMask, logical(searchMask_part));
%                     %mask3D = repmat( uint8(cell2mat(resultBW(i))), [1 1 3]);
%                     %im_copy = mask3D.*im_copy;
%                 end
%             %end
%         end
        
        %OpticalFlow auf aktuellen Frame, unter ber?ckichtung des vorhergehenden, anwenden.
        tic;
        of = step(opticalFlow, gim, lastgim);
        millis_of = toc*1000;
        
        % --- OPTICAL FLOW TEST OUTPUT ---
%         lines = int32(videooptflowlines(of, 30));
%         
%         if ~isempty(lines)
%             out = step(shapeInserterLine, im, lines);
%             step(videoPlayer, out);
%         end
        % --------------------------------
        
        %      Mit Component-Masken
        %      Positionsvektoren der einzelnen Components ermitteln.
        %      Mit Component-Masken und OpticalFlow-Vektoren
        %      Geschwindigkeitsvektoren der einzelnen Components ermitteln.
        %calcComponentVelocity(of, componentMask);
        
%         %matrix um bereiche zu speichern in denen die geschwindigkeiten der
%         %komponenten gemittelt werden.
%         output_vmask = false(size(im2bw(im)));
%         output_cmask = false(size(im2bw(im)));
%         
%         %matrix um geschwindigkeits-vektor-linien zu speichern
%         vlines = [0 0 0 0];
        
        %berechne positionen der komponenten
%         for k = 1 : length(resultBW(:))
%             compPosition(:, :, k, frameNo) = getPositionOfComponent(resultBW{k});
%         end
        
        %berechne optical-flow komponenten
        %         OpticalFlow_Analysis1(of);
%         OpticalFlow_Analysis2(of);
        
        %Bewegende Komponenten des Bildes finden (wo sich bälle bewegen könnten)
%         disp('SIZES');
        ofVelocity = abs(of);
        ofVelocityFiltered = zeros(size(ofVelocity));
        ofVelocityFiltered(ofVelocity(:,:) > 0.01) = 1;
        
        tic;
        [of_comps, of_comp_count] = ccl_labeling( ofVelocityFiltered );
        millis_of_labeling = toc*1000;
        
        %opticalFlow masks und positions matrix erstellen
%         ofCompMasks = zeros([1, of_comp_count, 1, 1, 1]);
%         ofCompPositions = zeros([1, of_comp_count, 1, 1]);

        %muss mindestens zwei drin haben, damit immer jedenfalls 2 drinnen
        %sind, sonst gibt es probleme bei size() aufrufen und iterationen ueber 
        %die matrizen, weil die matrizen dann automatisch verkleinert werden.
        ofCompMasks(:,:,1,1) = zeros(size(gim));
        ofCompPositions(:,:,1,1) = [-1, -1];
        ofCompMasks(:,:,1,2) = zeros(size(gim));
        ofCompPositions(:,:,1,2) = [-1, -1];

        of_comp2 = double(repmat(zeros(size(of)),[1 1 1]));
        ofpvis = double(repmat(zeros(size(of)),[1 1 3]));
        
        tic; 
        
        ofc_idx = 3;
        for i = 1 : of_comp_count
            of_comp = of_comps;
            of_comp(of_comp < i | of_comp > i) = 0; %lösche alles was nicht zur aktuellen komponente (ID = i) gehört.
            
            if(sum(sum(of_comp)) < 100)
                continue
            end
            
%             disp(sum(sum(of_comp)));
            
            of_comp2 = or(of_comp2, of_comp);%for debugging output
            
            of_comp = logical(of_comp);
            ofCompMasks(:,:,1,ofc_idx) = of_comp;
            ofCompPositions(:,:,1,ofc_idx) = int32(fliplr(getPositionOfComponent(of_comp)));
            point = ofCompPositions(:,:,1,ofc_idx);
            ofpvis(point(1), point(2), 1) = 0;
            ofpvis(point(1), point(2), 2) = 1;
            ofpvis(point(1), point(2), 3) = 1;
%             disp(ofCompPositions(:,:,1,ofc_idx));
            ofc_idx = ofc_idx + 1;
        end
        
        millis_comp_pos = toc*1000;
        
        figure(7)
        of_comp2 = double(repmat(of_comp2, [1 1 3]));
        of_comp2 = (of_comp2 + ofpvis);
        of_comp2 = of_comp2 / max(max(max(of_comp2)));
        imshow(of_comp2);
        
        cppvis = double(repmat(zeros(size(of)),[1 1 3]));
        cppvis_old = double(repmat(zeros(size(of)),[1 1 3]));
        
        %liste der alten Positionen der Bälle
        compPositionSize = size(compPosition);
        for i = 1 : compPositionSize(3)
            oldCompPositions(:, :, i) = int32(fliplr(compPosition(:, :, i, frameNo - 1)));
            oldCompClasses(:, i) = fliplr(compClass(:, i, frameNo - 1));
            %set error code, für den fall das kein neuer eintrag dazu kommt
            compPosition(:, :, i, frameNo) = NaN;
            compClass(:, i, frameNo) = NaN;
            
            %debugging output
%             disp([num2str(i), ': ', num2str(oldCompPositions(:, :, i))]);
            oldCompPosition = oldCompPositions(:, :, i);
%             if(oldCompPosition(1) ~= 0 && oldCompPosition(2) ~= 0)
                cppvis_old(oldCompPosition(1), oldCompPosition(2), 1) = 1;
                cppvis_old(oldCompPosition(1), oldCompPosition(2), 2) = 1;
                cppvis_old(oldCompPosition(1), oldCompPosition(2), 3) = 0;
%             end
        end
        
        %Bälle im neuen Frame finden
        tic;
        [resultBW, resultColor, resultRaw] = connectedComponent(im, 0.5);
        millis_comp_labeling = toc*1000;
        
        tic;
        compClasses = colorClassification(resultColor);
        millis_color_class = toc*1000;
        
        newPositionSize = size(resultBW);
        newCompPositions = zeros(newPositionSize(2), 2);
        newCompClasses = zeros(newPositionSize(2), 1);
%         disp(newCompPositions);
        for i = 1 : newPositionSize(2)
            %             resultRaw = or(resultRaw, logical(resultBW{i}));
%             disp(int32(getPositionOfComponent(resultBW{i})));
            newCompPositions(i,:) = int32(getPositionOfComponent(resultBW{i}));
            newCompClasses(i) = compClasses{i};
            %             disp('newCompPosition');
            %             disp(newCompPosition);
            
            newCompPosition = newCompPositions(i,:);
            cppvis(newCompPosition(2), newCompPosition(1), 1) = 1;
            cppvis(newCompPosition(2), newCompPosition(1), 2) = 0;
            cppvis(newCompPosition(2), newCompPosition(1), 3) = 1;
        end
        
        %Jede neue Position versuchen mit einer alten zu verknüpfen
        tic;
            
        [oldCompIndices, vx, vy, output_vmask, output_cmask, vlines] = tryToLinkComponents(oldCompPositions, newCompPositions, oldCompClasses, newCompClasses, ofCompMasks, ofCompPositions, of, 6, 5, compIgnore);% [5, 4]
        
        for i = 1 : length(resultBW(:))
            oldCompIndex = oldCompIndices(i);
            newCompPosition = newCompPositions(i,:);
            newCompClass = newCompClasses(i);
            
            cppvis(newCompPosition(2), newCompPosition(1), 1) = 1;
            cppvis(newCompPosition(2), newCompPosition(1), 2) = 0;
            cppvis(newCompPosition(2), newCompPosition(1), 3) = 1;
            
            if(oldCompIndex ~= 0)
                compPosition(:, :, oldCompIndex, frameNo) = newCompPosition;
                compClass(:, oldCompIndex, frameNo) = newCompClass;
                
                %draw velocity lines
%                 disp(oldCompIndex);
                p1 = compPosition(:, :, oldCompIndex, frameNo);
                %vlines(oldCompIndex, :) = [p1(1) p1(2) p1(1)+vx*1000 p1(2)+vy*1000];
                vlines(oldCompIndex, :) = [p1(1) p1(2) p1(1)+vx(i) p1(2)+vy(i)];
            
            else
                disp(['create new Component: ', num2str(compPositionSize(3) + 1), ' at ', num2str(newCompPosition(1)), ' ', num2str(newCompPosition(2))]);
                compIgnore(compPositionSize(3) + 1) = 0;
                compLostCount(compPositionSize(3) + 1) = 0;
                for j = 1 : frameNo
                    compPosition(:, :, compPositionSize(3) + 1, j) = newCompPosition;
                    compClass(:, compPositionSize(3) + 1, j) = newCompClass;
                end
            end
        end
        
        compPositionSize = size(compPosition);
        for i = 1 : compPositionSize(3)
            if isnan(compPosition(:, :, i, frameNo))
                compPosition(:, :, i, frameNo) = compPosition(:, :, i, frameNo - 1);
                compClass(:, i, frameNo) = compClass(:, i, frameNo - 1);
                
                compLostCount(i) = compLostCount(i) + 1;
                
                %If a Position was not recognized 3 times in a row, it will
                %be ignored in the future, preventing components being
                %connected to nonexistant artifacts
                if(compLostCount(i) > 3)
                      compIgnore(i) = 1;
%                     compPosition( :, :, i, : ) = [];
%                     compPosition = compPosition( :, :, [1:i-1, i+1:end], : );
%                     complength = complength - 1;
                end
                %TODO check distance to recognized components, if there are
                %none, maybe over several frames, delete the position.
            end
%             disp(size(compPosition));
%             if(i == complength)
%                 break;
%             end
        end
        
        disp(['ignore: ', num2str(sum(compIgnore)), ' / ', num2str(length(compIgnore))]);
        
        millis_linking = toc*1000;
        
        millis_sum2 = datevec(now);
        millis_sum = (millis_sum2(6) - millis_sum1(6))*1000;
        
        %linedraw-debugging-output
        tic;
        %getColors
        cols = zeros(compPositionSize(3), 3);
        for i = 1 : compPositionSize(3)
            cols(i,:) = BucketManager.getBucket(compClass(:,i)).rgbColor/255;
        end
        imsize = size(im);
        lineimg = drawLines(imsize, compPosition, cols, 1);%repmat([0.9 0.9 0.9],[compPositionSize(3), 1, 1]), 1);
%         lineimg = drawLines(imsize, compPosition, zeros(compPositionSize(3), 1, 3), 1);
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
        
%         try
%             clf(10);
%         end
        figure(10);
        imshow(lineimg);
                
%         figure(7)
%         imshow(resultRaw);
        
%         if exist('fig10', 'var') == 1
%             clf(fig10);
%         end
%         fig10 = figure(10);
%         imsize = size(im);
%         lineimg = zeros(imsize);
%         lineimg = drawline(lineimg, compPosition, ones(compPositionSize(3), 1, 3));
%         lineimg = bwmorph(im2bw(lineimg,0.5), 'thicken', 1);
%         lineimg = drawline(repmat(1-(double(lineimg)),[1 1 3]), compPosition, repmat(0.9,[compPositionSize(3), 1, 3]));
%         for i = 1 : imsize(1)
%             for j = 1 : imsize(2)
%                 if lineimg(i,j,1) == 1 && lineimg(i,j,2) == 1 && lineimg(i,j,3) == 1
%                     lineimg(i,j,:) = double(im(i,j,:))/255;
%                 end
%             end
%         end
%         imshow(lineimg);
        
%         compPositionSize = size(compPosition);
        %berechne geschwindigkeiten der komponenten
%         for k = 1 : compPositionSize(3)
%             [vx, vy, vmask] = calcComponentVelocity(of, im, compPosition(:, :, k, frameNo), 20);
%             compVelocity(:, :, k, frameNo) = [vx vy];
%             
%             %draw component-areas
%             output_vmask = or(output_vmask, vmask);
%             
%             %draw component-masks
%             %output_cmask = or(output_cmask, resultBW{k});
%             
%             %draw velocity lines
%             p1 = compPosition(:, :, k, frameNo);
%             vlines(k, :) = [p1(1) p1(2) p1(1)+vx*1000 p1(2)+vy*1000];
%         end
        
        %optical-flow-intensitäten in matrix speichern
%         vof = abs(of);
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
        
%         output_resultRaw = double(repmat(logical(resultRaw), [1 1 3]));
%         output_resultRaw(:,:,1) = output_resultRaw(:,:,1)*0;
%         output_resultRaw(:,:,2) = output_resultRaw(:,:,2)*0.4;
%         output_resultRaw(:,:,3) = output_resultRaw(:,:,3)*0;
        
        %such-masken ebene einfärben
%         output_seachMask = double(repmat(logical(searchMask), [1 1 3]));
%         output_seachMask(:,:,1) = output_seachMask(:,:,1)*0.25;
%         output_seachMask(:,:,2) = output_seachMask(:,:,2)*0;
%         output_seachMask(:,:,3) = output_seachMask(:,:,3)*0;
        
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
%         output_mask = output_mask + output_seachMask;
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
        
        %For movie creation at the end
%         MF(frameNo - 1) = im2frame(output_mask);
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

cols = zeros(compPositionSize(3), 3);
for i = 1 : compPositionSize(3)
    cols(i,:) = BucketManager.getBucket(compClass(:,i)).rgbColor/255;
end
lineimg = drawLines(size(im), compPosition, cols, 1);%zeros(compPositionSize(3), 1, 3), 1);
alphablender = vision.AlphaBlender('Operation','Binary mask', 'Mask', uint8(im2bw(lineimg, 0.99)), 'MaskSource', 'Property');
lineimg = step(alphablender, lineimg, im);

%Version mit Border um die linien
% lineimg = drawLines(size(im), compPosition, zeros(compPositionSize(3), 1, 3), 2);
% lineimg2 = drawLines(imsize, compPosition, repmat([0.9 0.9 0.9],[compPositionSize(3), 1, 1]), 1);
% alphablender = vision.AlphaBlender('Operation','Binary mask', 'Mask', uint8(im2bw(lineimg2, 0.99)), 'MaskSource', 'Property');
% lineimg = step(alphablender, lineimg2, lineimg);
% alphablender = vision.AlphaBlender('Operation','Binary mask', 'Mask', uint8(im2bw(lineimg, 0.99)), 'MaskSource', 'Property');
% lineimg = step(alphablender, lineimg, im);

figure(12);
imshow(lineimg);
        
% imsize = size(im);
% lineimg = zeros(imsize);
% lineimg = drawline(lineimg, compPosition, ones(compPositionSize(3), 1, 3));
% lineimg = bwmorph(im2bw(lineimg,0.5), 'thicken', 1);
% lineimg = drawline(repmat(1-(double(lineimg)),[1 1 3]), compPosition, repmat(0.9,[compPositionSize(3), 1, 3]));
% for i = 1 : imsize(1)
%     for j = 1 : imsize(2)
%         if lineimg(i,j,1) == 1 && lineimg(i,j,2) == 1 && lineimg(i,j,3) == 1
%             lineimg(i,j,:) = double(im(i,j,:))/255;
%         end
%     end
% end
% figure(13)
% imshow(lineimg);

%exports a movie for debugging purposes
% MF(frameNo - 1) = im2frame(im_with_line);
% movie2avi(MF, [pwd,filesep,'results',filesep,'debug_mov.avi'], 'Compression', 'None');

output_args = 'Success!';

end

