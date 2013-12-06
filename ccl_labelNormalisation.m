function [ components_img, num ] = ccl_labelNormalisation(runlengthTable, bw_img)

% hier werden die Werte der Labels zuerst normalisiert, sodass diese eine
% durchgehende Nummerierung haben,
% anschlie?end wird das Ursprungsbild anhand dieser Labels ge?ndert
% zur?ckgegeben wird das gelabelte Logical-Bild und die Anzahl der darin
% enthaltenen Components

[~, num] = size(runlengthTable);

% Wir bauen eine Label Map aus (altemLabel, normalisiertesLabel) auf. 
% Die normalisierten Label beginnen bei 1 und zaehlen ohne Luecke nach oben. 
labelMap = containers.Map('KeyType','int32','ValueType','int32');
normalizedLabelCount = 1;

for x=1:num
    
    currentLabel = runlengthTable{x}(4);
    
    % Exisiert fuer ein altes Label noch kein Eintrag in der Map, so wir
    % einer erstellt und diesem alten Label ein neues normalisiertes Label
    % zugewiesen
    if ~labelMap.isKey(currentLabel) 
       labelMap(currentLabel) = normalizedLabelCount;
       normalizedLabelCount = normalizedLabelCount + 1;
    end
    
    % nun ersetzen wir noch gleich jedes Label durch sein zugehoeriges 
    % normalisiertes Label
    runlengthTable{x}(4) = labelMap(currentLabel);
    
end