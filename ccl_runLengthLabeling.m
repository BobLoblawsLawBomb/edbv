function [ runlengthTable ] = ccl_runLengthLabeling()
%function [ runlengthTable ] = ccl_runLengthLabeling( bw_img )

% n Reihen, 4 Spalten: Aktuelle Reihe, start, ende, Label

img = imread('res/connected1.png');
bw_img = im2bw(img, 0.50);

% bw_img Zeilenweise durchgehen und nach Zeichenketten suchen.
% f?r jede Zeichenkette den Anfangswert und den Endwert in der
% runlengthTable speichern
% gleichzeitig die Zeichenkette labeln, d.h. den Labelwert in die Tabelle
% speichern
% f?r jeden Element der Zeichenkette ?berpr?fen, ob das Element der in
% dar?berliegenden Zeile bereits gelabelt wurde.

% Tabelle der Zeichenketten der Zeilen
runlengthTable = cell(1);

count = 1;

for x = 1:size(bw_img,2)
     % x-te zeile aus tabelle holen
     currentRow = bw_img(x,:);
      
     % Indizes der nonzero-Elemente des Zeilenvektors
     indices = find(currentRow);
     cursor_row = 1;
     cursor_ind = 1;
     
     if ~isempty(indices)
         while cursor_row <= length(currentRow) && cursor_ind <= length(indices)
             % Start der Zeichenkette und Cursor f?r Reihe und Index-Vektor setzen
             start_string = indices(cursor_ind);
             cursor_row = start_string + 1;
             cursor_ind = cursor_ind + 1;
             
             % vorl?ufiges Label
              [~, num] = size(runlengthTable);
%              if ~isempty(runlengthTable{1})
%                  label = num + 1;
%              else
%                  label = 1;
%              end
             label = count;
             
             % Schleife l?uft, bis das Ende der Zeichenkette erreicht ist
             while (cursor_row <= length(currentRow)) && (currentRow(cursor_row) ~= 0)
                 if x > 1
                    bool = 1;
                    % f?r jede Zeichenkette eine Zeile dar?ber wird
                    % ?berpr?ft, ob die Zeichenkette direkt ?ber dem
                    % aktuellen Element liegt
                     while bool && num > 0
                         if ~isempty(runlengthTable{1}) && runlengthTable{1,num}(1) == (x-1)
                             if (runlengthTable{1,num}(2)<=cursor_row) && (runlengthTable{1,num}(3)>=cursor_row)
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
             
             % codierte Zeichenkette in Tabelle speichern
             runlengthTable{count} = [x start_string end_string label];
             count = count + 1;
         end
     end
end

end