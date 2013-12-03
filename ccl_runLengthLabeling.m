function [ runlengthTable ] = ccl_runLengthLabeling( bw_img )
% n Reihen, 4 Spalten: Aktuelle Reihe, start, ende, Label

% bw_img Zeilenweise durchgehen und nach Zeichenketten suchen.
% für jede Zeichenkette den Anfangswert und den Endwert in der
% runlengthTable speichern
% gleichzeitig die Zeichenkette labeln, d.h. den Labelwert in die Tabelle
% speichern
% für jeden Element der Zeichenkette überprüfen, ob das Element der in
% darüberliegenden Zeile bereits gelabelt wurde.


end