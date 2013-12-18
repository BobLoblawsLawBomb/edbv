function [ runlengthTable ] = ccl_runLengthLabeling( bw_img )
%
% Diese Funktion runlength encoded das uebergebene bereits maskierte Bild
% und fuehrt das erste grobe top-down Labeling der Komponenten durch.
%
% Ausgabe: runlengthTable enthaelt pro Eintag einen runlength-encodeten
% String, der in der Binaerdarstellung des Ursprungsbilds nur 1-er enthalten
% hat. Ein Eintrag entspricht einem Vektor mit 4 Elementen. Das erste
% Element gibt die Zeile im Bild an, an der sich der String befindet. Das
% zweite Element gibt die Angangspositon an, das dritte die Endposition.
% Das vierte Element gibt das Label der Komponente an, zu dem der
% Zeichen-String gehoert
%
% Das uebergebene Binaerbild bw_img wird Zeilen fuer Zeile durchgehen.
% Fuer jede Zeichenkette in der Zeile wird der Anfangswert und der Endwert in der
% runlengthTable gespeichert.
% Gleichzeitig wird die Zeichenkette auch gelabelt, d.h. der Labelwert wird
% in die Tabelle geschrieben.
% Zusaetzlich wird fuer jedes Element der Zeichenkette ueberpruefen, ob das Element der in
% darueberliegenden Zeile bereits gelabelt wurde. Wenn dieser Fall
% zutrifft und dieses Label kleiner als das aktuelle ist, wird das Label des 
% daraueberliegenden Elements uebernommen
%   
%   @author Theresa Froeschl
%---------------------------------------------

% Tabelle der Zeichenketten der Zeilen
runlengthTable = cell(0);
count = 1;
rows = size(bw_img, 1);

for x = 1:rows   
     % x-te zeile aus tabelle holen
     currentRow = bw_img(x,:);
      
     % Indizes der nonzero-Elemente des Zeilenvektors
     indices = find(currentRow);
     cursor_row = 1;
     cursor_ind = 1;
     
     if ~isempty(indices)
         while cursor_row <= length(currentRow) && cursor_ind <= length(indices)
             % Start der Zeichenkette und Cursor fuer Reihe und Index-Vektor setzen
             start_string = indices(cursor_ind);
             cursor_row = start_string;
             cursor_ind = cursor_ind + 1;
             
             %vorlaufiges Label setzen
             label = count;
             
             % Schleife laeuft, bis das Ende der Zeichenkette erreicht ist
             % oder bis das Ende der Bild-Reihe erreicht ist
             while (cursor_row <= length(currentRow)) && (currentRow(cursor_row) ~= 0)
                 if x > 1
                    bool = 1;
                    % fuer jede Zeichenkette eine Zeile darueber wird
                    % ueberprueft, ob die Zeichenkette direkt ueber dem
                    % aktuellen Element liegt
                    [~, num] = size(runlengthTable);
                     while bool && num > 0
                         if ~isempty(runlengthTable{1}) && runlengthTable{1,num}(1) >= (x-1)
                             if (runlengthTable{1,num}(2)<cursor_row) && (runlengthTable{1,num}(3)>cursor_row)
                                if label > runlengthTable{1,num}(4)
                                     label = runlengthTable{1,num}(4);
                                end
                             elseif cursor_row == runlengthTable{1,num}(2)
                                if label > runlengthTable{1,num}(4)
                                     label = runlengthTable{1,num}(4);
                                end 
                             elseif cursor_row == runlengthTable{1,num}(3)
                                if label > runlengthTable{1,num}(4)
                                     label = runlengthTable{1,num}(4);
                                end 
                             end
                         else
                             bool = 0;
                         end
                         num = num - 1;
                     end
                 end
                 
                 cursor_row = cursor_row + 1;
                 cursor_ind = cursor_ind + 1;
             end
             
             % Ende der Zeichenkette angeben
             end_string = cursor_row - 1;
             cursor_ind = cursor_ind - 1;
             
             % codierte Zeichenkette in Tabelle speichern
             runlengthTable{count} = [x start_string end_string label];
             count = count + 1;
         end
     end
end

end