function [ runlengthTable ] = ccl_bottomUpLabeling(runlengthTable )

% labeling von unten nach oben
% für jede Zeichenkette in der runlengthTable wird überprüft, ob die
% Elemente der Zeichenkette darunter an anderes gelabeltes Element haben,
% dass ein kleineres Label hat.

[~, num] = size(runlengthTable);

for x = drange(num:-1:1)
    bool = 1;
    counter = x + 1;
    while bool && counter < num
        check = 0;
        if (runlengthTable{counter}(1) - runlengthTable{x}(1)) <= 1 && runlengthTable{x}(4) ~= runlengthTable{counter}(4)
            if (runlengthTable{counter}(1) - runlengthTable{x}(1)) == 1
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