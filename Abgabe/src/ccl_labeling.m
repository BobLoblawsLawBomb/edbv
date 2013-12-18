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
% veraendert, sodass die Folge der Labels aller Komponenten keine Luecken
% mehr enthaelt. Am Ende soll das groesste Label die Gesamtanzahl der
% Komponenten haben.
%
% Eingabe: Binaerbild des Bildes fuer das die Components ermittelt werden
% sollen. Auf diesem Bild muss der Tisch bereits mit der TableMask
% ausgeschnitten sein.
%
% Ausgabe: 
% components_img: das veraenderte Logical Eingabebild, in dem die
%                 Komponenten nun gelabelt sind. Jedes Label hat besteht aus einem eindeutigen
%                 ganzen Zahlenwert.
% labelCount: Zahlenwert, das die Anzahl der Labels im Bild angibt.
%   
%   @author Theresa Froeschl
%---------------------------------------------

    runlengthTable = ccl_runLengthLabeling( bw_img );
    runlengthTable = ccl_bottomUpLabeling( runlengthTable );
    [components_img, labelCount] = ccl_labelNormalisation(runlengthTable, bw_img);
    
end