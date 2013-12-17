function [components_img, labelCount] = ccl_labeling( bw_img )
%
% Diese Funktion ruft die einzelnen Teile des Connected Component Labeling
% auf.
% Mit ccl_runLengthLabeling() wird das Bild runlength Encoded und das
% erste grobe Labeling der Componenten vorgenommen. TopDown-Labeling ist
% hier bereits enthalten.
% Mit ccl_bottomUpLabeling() werden Korrekturen an den Labels vorgenommen,
% sodass eine Komponente auch wirklich nur ein einziges Label hat.
% Bei ccl_labelNormalisation werden die Labels der Komponenten so
% ver�ndert, sodass die Folge der Labels aller Komponenten keine L�cken
% mehr enth�lt. Am Ende soll das gr��te Label die Gesamtanzahl der
% Komponenten haben.
%   
%   @author Theresa Froeschl
%---------------------------------------------

    runlengthTable = ccl_runLengthLabeling( bw_img );
    runlengthTable = ccl_bottomUpLabeling( runlengthTable );
    [components_img, labelCount] = ccl_labelNormalisation(runlengthTable, bw_img);
    
end