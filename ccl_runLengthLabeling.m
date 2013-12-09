function [ runlengthTable ] = ccl_runLengthLabeling( bw_img )

% n Reihen, 4 Spalten: Aktuelle Reihe, start, ende, Label

%img = imread('res/connected1.png');
%bw_img = im2bw(img, 0.50);
% test = [ 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0;
%          0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0;
%          0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0;
%          0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
%          0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
%          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;];
% %imshow(img);

% bw_img Zeilenweise durchgehen und nach Zeichenketten suchen.
% fuer jede Zeichenkette den Anfangswert und den Endwert in der
% runlengthTable speichern
% gleichzeitig die Zeichenkette labeln, d.h. den Labelwert in die Tabelle
% speichern
% fuer jeden Element der Zeichenkette ueberpruefen, ob das Element der in
% dar?berliegenden Zeile bereits gelabelt wurde.

% Tabelle der Zeichenketten der Zeilen
runlengthTable = cell(1);
count = 1;
rows = size(bw_img, 1);

for x = 1:rows
% for x = 1:size(test,1)   
     % x-te zeile aus tabelle holen
     currentRow = bw_img(x,:);
     %currentRow = test(x,:);
      
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
             
             % vorlaeufiges Label
              
%                  label = num + 1;
%              else
%                  label = 1;
%              end
             label = count;
             
             % Schleife laeuft, bis das Ende der Zeichenkette erreicht ist
            % length(currentRow)
            % currentRow(cursor_row)
            % cursor_row
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