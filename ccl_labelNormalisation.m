function [ components_img, labelCount ] = ccl_labelNormalisation(runlengthTable, bw_img)

% img = imread('res/connected1.png');
% bw_img = im2bw(img, 0.50);
% 
% runlengthTable = ccl_bottomUpLabeling();


% hier werden die Werte der Labels zuerst normalisiert, sodass diese eine
% durchgehende Nummerierung haben,
% anschliessend wird das Ursprungsbild anhand dieser Labels geaendert
% zurueckgegeben wird das gelabelte Logical-Bild und die Anzahl der darin
% enthaltenen Components

[~, num] = size(runlengthTable);

% Wir bauen eine Label Map aus (altemLabel, normalisiertesLabel) auf. 
% Die normalisierten Label beginnen bei 1 und zaehlen ohne Luecke nach oben. 
labelMap = containers.Map('KeyType','int32','ValueType','int32');
normalizedLabelCount = 0;

for x=1:num
    
    currentLabel = runlengthTable{x}(4);
    
    % Exisiert fuer ein altes Label noch kein Eintrag in der Map, so wir
    % einer erstellt und diesem alten Label ein neues normalisiertes Label
    % zugewiesen
    if ~labelMap.isKey(currentLabel) 
       normalizedLabelCount = normalizedLabelCount + 1;
       labelMap(currentLabel) = normalizedLabelCount;
    end
    
    % nun ersetzen wir noch gleich jedes Label durch sein zugehoeriges 
    % normalisiertes Label
    runlengthTable{x}(4) = labelMap(currentLabel);
    
end

% die Anzahl an individuellen Labels istgleichtzeitg die Menge 
% angefunden Components
labelCount = normalizedLabelCount;

% jetzt bauen wir aus unserem Binaerbild noch ein neues Bild auf, in dem
% alle Pixel einer Components mit ihrem Componentlabel versehen ist

components_img = zeros(size(bw_img));

for tableIndex = 1:num
    
    data = runlengthTable{tableIndex};
    row = data(1);
    startX = data(2);
    endX = data(3);
    label = data(4);
    %[row, startX, endX, label] = runlengthTable{tableIndex};
    
    components_img(row, startX:endX) = label;
  
end


% hier werden alle components eliminiert werden, die zu klein/gross sind, 
% und daher keine baelle sein koennen.
% da dadurch die normalisierten labels wieder zerstoert werden, muessen wir
% uns ein weiteres mal eine substitutions map aufbauen, mit der wir
% anschliessend erneut normalisieren koennen
labelMap = containers.Map('KeyType','int32','ValueType','int32');
newLabelCount = 0;

stat = regionprops(components_img,'BoundingBox');

for label=1:labelCount
    
    % fuer jedes label alles ausmaskieren, was nicht das label ist
    comp = components_img(components_img==label);
    temp = components_img;
    temp(temp~=label)=0;
    imshow((temp));

    % die flaeche der component ist somit die anzahl aller
    % pixel ungleich 0
    areaSize = nnz(comp);

    x_width = stat(label).BoundingBox(4)-stat(label).BoundingBox(2);
    y_width = stat(label).BoundingBox(3)-stat(label).BoundingBox(1);
    x_width / y_width

    
    % TODO: hier brauchen wir noch das grnezintervall einer validen
    % ballgroe?e. diese muss klein genug sein, um einen ball zu
    % akzeptieren der nur aus seinem glanzpunkt besteht, sowie die,
    % welche komplett erkannt werde (weiss und gelb)
    if not(20 <= areaSize && areaSize <= 200)   %minSize=20, maxSize=150; die werte funktioniern nicht wirklich
        % falls das nicht gegeben ist, wird das label verworfen
        components_img(components_img == label) = 0;
    elseif (x_width / y_width) >= 2 || (x_width / y_width) <= 0.5
        components_img(components_img == label) = 0;
    else
        % wenn die component erhalten bleibt, weissen wir ihr noch ein
        % neues normalisiertes label zu. das neue normalisierte label ist 
        % immer <=altes normalisiertes label
        newLabelCount = newLabelCount + 1;
        labelMap(label) = newLabelCount;
        fprintf('substituting label %i with %i \n', label,newLabelCount);
    end
end

% da wir jetzt unsere neue label map haben, muessen wir noch einmal ueber
% alle keys in ihr iterieren und substituieren
oldLabels = labelMap.keys();
for i=1:numel(oldLabels)
    oldLabel = oldLabels{i};
    newLabel = labelMap(oldLabel);
    components_img(components_img==oldLabel) = newLabel;
end 

% abschliessend noch den labelCount rueckgabeparameter updaten - nich das
% wir spaeter ueber eine falsche anzahl an components iterieren
labelCount = newLabelCount;

% TEST
%figure(4)
imshow(label2rgb(components_img));
end
     
     

