function [ runlengthTable ] = ccl_bottomUpLabeling(runlengthTable )
%
% Hier werden Korrekturen des Labeling der Komponenten vorgenommen.
% Dafuer werden die Labels von unten nach oben aneinander angepasst.
% 
% Fuer jede Zeichenkette in der runlengthTable wird ueberprueft, ob es eine
% andere Zeichenkette gibt, die sich direkt unter der aktuellen befindet.
% Sollte das der Fall sein, wird zusaetzlich ueberprueft, ob die untere
% Zeichenketten ein kleineres Label hat - ist das der Fall wird das Label
% der unteren Zeichenkette als neues Label uebernommen.
%   
%   @author Theresa Froeschl
%---------------------------------------------


[~, num] = size(runlengthTable);

for x = drange(num:-1:1)
    bool = 1;
    counter = x + 1;
    while bool && counter < num
        check = 0;
        if (runlengthTable{counter}(1) - runlengthTable{x}(1)) <= 1 && runlengthTable{x}(4) ~= runlengthTable{counter}(4)
            if (runlengthTable{counter}(1) - runlengthTable{x}(1)) == 1
                
                % Ueberpruefung der einzelnen Faelle, wie die Zeichenketten
                % uebereinander liegen können. Trifft einer der Faelle zu,
                % gehoeren beide Zeichenketten zu der selben Komponente.
                if runlengthTable{x}(2) == runlengthTable{counter}(2) && runlengthTable{x}(3) == runlengthTable{counter}(3)
                    check = 1;
                elseif runlengthTable{x}(2) < runlengthTable{counter}(2) && runlengthTable{x}(3) == runlengthTable{counter}(3)
                    check = 1;
                elseif runlengthTable{x}(2) > runlengthTable{counter}(2) && runlengthTable{x}(3) == runlengthTable{counter}(3)
                    check = 1;
                elseif runlengthTable{x}(2) == runlengthTable{counter}(2) && runlengthTable{x}(3) > runlengthTable{counter}(3)
                    check = 1;
                elseif runlengthTable{x}(2) == runlengthTable{counter}(2) && runlengthTable{x}(3) < runlengthTable{counter}(3)
                    check = 1;
                elseif runlengthTable{x}(2) < runlengthTable{counter}(2) && runlengthTable{x}(3) > runlengthTable{counter}(3)
                    check = 1;
                elseif runlengthTable{x}(2) > runlengthTable{counter}(2) && runlengthTable{x}(3) < runlengthTable{counter}(3)
                    check = 1;
                elseif runlengthTable{x}(2) == runlengthTable{counter}(3) 
                    check = 1;
                elseif runlengthTable{x}(3) == runlengthTable{counter}(2) 
                    check = 1;
                end
            end
            % das geaenderte Label wird gespeichert
            if check
                runlengthTable{x} = [runlengthTable{x}(1) runlengthTable{x}(2) runlengthTable{x}(3) runlengthTable{counter}(4)];
            end
        else
            bool = 0;
        end
        counter = counter + 1;
    end
end

end