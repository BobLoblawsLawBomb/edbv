function [ componentColorList , compClassesImage ] = colorClassification( ColorComponents, createImage)
%
% Diese Funktion weist jeder erkannten Component eine Farbklasse zu. Die
% Werte in der Rueckgabeliste enthalten das Index-Attributen der 
% Farbklasse. Der Index jedes Wertes in der Liste korreliert mit dem Index
% der Component im Component Array.
%
% Eingabe:
% ColorComponents:  cell Array der Components. Jedes Element ist ein Bild in
%                   dem alles au?er der Component ausmaskiert ist.  
% createImage: boolean der angibt, ob ein mit eingefarbtes Ausgabebild
% erstellt werden soll.
%
% Ausgabe:
% componentColorList: cell Array mit Farbklassen Indizes. 
% compClassesImage: falls createImage=true, ein Bild in dem die Components
% mit der Klassenfarbe eingefaerbt sind. 
%
%   @author Maximilian Irro
%---------------------------------------------

if(createImage)
    compClassesImage = repmat( uint8(zeros(size(ColorComponents{1},1),size(ColorComponents{1},2))), [1 1 3]);
else
    compClassesImage = [];
end
[~, num] = size(ColorComponents);


% diese Liste enthaelt fuer jede Component einen Eintrag, der mit einem
% colorIndex einer Farbklasse korreliert
componentColorList = cell(1,num);

for x = 1:num
    
    current = ColorComponents{x};
    
    %     figure(50);
    %     imshow(current);
    
    [ballClass, intens] = calcColorClass(current);
    componentColorList{x} = ballClass.colorIndex;

    % Die Component mit der erkannten Farbe einfaerben
    if(createImage)
        comp_mask = im2bw(current,0.00001);
        
        comp_red = current(:,:,1);
        comp_green = current(:,:,2);
        comp_blue = current(:,:,3);
        
        if intens ~= 0
            comp_red(comp_mask>0) = ballClass.rgbColor(1) * intens;
            comp_green(comp_mask>0) = ballClass.rgbColor(2) * intens;
            comp_blue(comp_mask>0) = ballClass.rgbColor(3) * intens;
        else
            comp_red(comp_mask>0) = 160*0.15;%/360;
            comp_green(comp_mask>0) = 154*0.05;%/360;
            comp_blue(comp_mask>0) = 203*0.15;%/360;
        end
        
        new_comp = zeros(size(current));
        new_comp(:,:,1) = comp_red;
        new_comp(:,:,2) = comp_green;
        new_comp(:,:,3) = comp_blue;
        
        % imshow(uint8(new_comp));
        compClassesImage = compClassesImage + uint8(new_comp);
    end
    
end

end
