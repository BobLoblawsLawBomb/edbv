function [ dataUniqueList, dataCountList, count, my , varianz, mcount] = dynamicHistogram( data, tolerance, threshold, rangemin, rangemax)
%    Zur statistischen Analyse von Ähnlichkeiten in einem Datensatz.
%    Erstellt ein Histogramm, dass für jeden einzigartigen Wert in data
%    zählt wieviele ähnliche Werte es im datensatz zu diesem Wert gibt. 
%    Also die Menge der Werte aus data die sich innerhalb des tolerance-
%    Bereichs um den betrachteten Wert befinden.
%    Anschließend werden der statistische Mittelwert und die Varianz dieses
%    Histogramms errechnet.
%    
%   --- INPUT ---
%   
%   data
%    Die Werte welche analysiert werden sollen.
%    Als n x m Matrix.
% 
%   tolerance
%    Distanz wie weit ein Wert von einem Datenwert maximal entfernt sein
%    kann um immernoch als ähnlich gewertet zu werden.
% 
%   threshold
%    Nur Werte über threshold werden vom Datensatz für die Auswertung
%    verwendet.
%    Falls threshold = NaN, wird dieser ignoriert.
%   
%   rangemin
%    Gibt den Wert an der bei einem zirkulär geschlossenem Wertebereich dem
%    gleichen Wert wie rangemax entsprechen soll. (z.B. 0 bei 0-360°)
%   
%   rangemax
%    Gibt den Wert an der bei einem zirkulär geschlossenem Wertebereich dem
%    gleichen Wert wie rangemin entsprechen soll. (z.B. 360 bei 0-360°)
%   
%   Falls rangemin und rangemax nicht NaN sind, wird ein zirkulärer
%   Wertebreich bei der Auswertung angenommen.
%   
%   --- OUTPUT ---
%   
%   dataUniqueList
%    Aufsteigend sortierte Liste mit allen Werten aus dem Datensatz 
%    ohne Mehrfach-Einträge.
%   
%   dataCountList
%    Liste mit gleich vielen Einträgen wie dataUniqueList, beinhaltet zu
%    jeder Position korrespondierend mit dataUniqueList die entsprechende
%    Zählung wieviele ähnliche Werte im Wertebereich gefunden wurden.
%   
%   count
%    Anzahl der Werte im Datensatz oberhalb des threshold.
%   
%   my
%    Der Erwartungswert der Ähnlichkeitsverteilung.
%   
%   varianz
%    Die Varianz der Ähnlichkeitsverteilung.
%   
%   mcount
%    Die mittlere Anzahl an ähnlichen Werten am Erwartungswert.
%   
%   
%   @author Andreas Mursch-Radlgruber
% ---------------------------------------------

debug = false;

%Wertebereich in dem ein Zyklus besteht.
range = rangemax - rangemin;

[w, h] = size(data);

%Falls die Daten eine n x m Matrix sind, werden sie in eine Liste
%konvertiert.
dataListAll = reshape(data, w*h, 1);

%Nur Daten oberhalb des threshold betrachten
if ~isnan(threshold)
    dataListTrim = dataListAll(dataListAll(:) > threshold);
else
    dataListTrim = dataListAll;
end

%Datenwerte aufsteigend sortieren
dataListSorted = sort(dataListTrim); % von bei pos 1 weg: min < value <= max

%Doppelte Datenwerte entfernen und eine aufsteigend sortierte Liste
%einzigartiger Werte erstellen
dataUniqueList = unique(dataListSorted);

%Ergebnis-List fuer die Zähnlung ähnlicher Werte anlegen.
dataCountList = zeros(size(dataUniqueList));

count = length(dataListTrim);

%Fuer jeden Wert im Datensatz werden alle Werte (auch doppelte!) im 
%umliegenden tolerance-Bereich gezählt.
for k = 1 : size(dataUniqueList)
    anglek = dataUniqueList(k);
    
    %Grenzen des tolerance-Bereich festlegen
    edge1 = anglek - tolerance;
    edge2 = anglek + tolerance;
    
    %Falls der Datensatz zyklisch ist, muss dafür gesorgt werden, dass die
    %Grenzen innerhalb des zyklischen Bereichs bleiben.
    if ~isnan(rangemin) && ~isnan(rangemax)
        
        if edge1 <= rangemin
            edge1 = edge1 + range;
        end
        
        if edge2 > rangemax
            edge2 = edge2 - range;
        end
        
    end
    
    %Es wird ein Histogramm mit 1 oder 3 Bins erzeugt, wobei die tolerance-
    %Grenzen die Limits der Bins darstellen. Dann kann einfach der Wert der
    %korrekten Bins als Zählung verwendet werden.
    %Dabei ist zu beachten, dass wir die Äußeren Bins betrachten, falls die
    %range-grenzen überschritten werden und den Inneren falls nicht.
    %Anmk.: Das ganze ließe sich ohne der histc funktion wesentlich
    %performanter implementieren indem wir ausnutzen, dass wir mit
    %sortierten Listen arbeiten, wobei pro wert immer nur ein paar werte
    %mehr oder weniger abgezogen oder dazugezählt werden müssten, statt
    %jedesmal ein neues Histogramm zu berechnen.
    if edge1 > edge2   % achtung, in diesem fall springt der zu betrachtende bereich von max zu min
        n = histc(dataListSorted, [-inf edge2 edge1 inf]);
        dataCountList(k) = n(1) + n(3);
    else
        n = histc(dataListSorted, [edge1 edge2]);
        dataCountList(k) = n(1);
    end
end

elcount = numel(dataCountList);
countsum = sum(dataCountList);

%Erwartungswert und Varianz berechen
%Dabei muss zwischen dem kreisförmigen Fall wo rangemin und rangemax den
%selben Wert darstellen, und dem linearen Fall unterschieden werden um
%korrekte Werte zu erhalten.
my = 0;
varianz = 0;
mcount = 0;
if ~isnan(rangemin) && ~isnan(rangemax)
    %Kreisförmiger Fall
    
    % die richtungs-komponenten berechnen.
    rangemean = range/2;
    pi2 = 2*pi;
    dataUniqueRad_x = zeros(size(dataUniqueList));
    dataUniqueRad_y = zeros(size(dataUniqueList));
    for i = 1 : elcount
        radians = (dataUniqueList(i) - rangemean)*pi2;
        dataUniqueRad_x(i) = cos(radians);
        dataUniqueRad_y(i) = sin(radians);
    end
    
    % Erwartungswert berechnen
    my_x = 0;
    my_y = 0;
    for i = 1 : elcount
        my_x = my_x + dataUniqueRad_x(i)*dataCountList(i);
        my_y = my_y + dataUniqueRad_y(i)*dataCountList(i);
        mcount = mcount + dataCountList(i);
    end
    my = atan2(my_y, my_x)/pi2 + rangemean;
    
    %Varianz berechnen
    my_radians = (my - rangemean)*pi2;
    my_x = cos(my_radians);
    my_y = sin(my_radians);
    var_x = 0;
    var_y = 0;
    for i = 1 : elcount
        var_x = var_x + (dataUniqueRad_x(i) - my_x) * (dataUniqueRad_x(i) - my_x);
        var_y = var_y + (dataUniqueRad_y(i) - my_y) * (dataUniqueRad_y(i) - my_y);
    end
    var_x = var_x/(elcount - 1);
    var_y = var_y/(elcount - 1);
    varianz = sqrt(var_x * var_x + var_y * var_y);
else
    %Linearer Fall
    
    % Erwartungswert berechnen
    for i = 1 : elcount
        my = my + dataUniqueList(i)*dataCountList(i);
        mcount = mcount + dataCountList(i);
    end
    my = my/countsum;
    
    % Varianz berechnen
    for i = 1 : elcount
        varianz = varianz + (dataUniqueList(i) - my) * (dataUniqueList(i) - my);
    end
    varianz = varianz/(elcount - 1);
    
end
mcount = mcount/elcount;

%for debugging output
if(debug)
    disp(['my: ',num2str(my),' ',num2str(mcount),' ',num2str(varianz)]);
    
    fig2 = figure(2);
    bar(dataUniqueList, dataCountList, 'BarWidth', 1);
    ylim([0 150]);
    xlim([0 1]);
    
    if elcount > 2
        hold on;
        plot(my, mcount + 0.05, 'k^', 'markerfacecolor', [1 0 0]);
        v1 = my - varianz/2;
        v2 = my + varianz/2;
        if ~isnan(rangemin) && ~isnan(rangemax)
            if(v1 < rangemin)
                v1 = v1 + range;
            end
            if(v2 > rangemax)
                v2 = v2 - range;
            end
        end
        plot([v1, v1], [0, 150], 'Color', [0 0 1]);
        plot([v2, v2], [0, 150], 'Color', [0 0 1]);
        hold off;
    end
    %print(fig2, '-dpng', [pwd filesep 'results' filesep 'Vert_' num2str(velocityThreshold) '_' num2str(angleVariance) filesep 'Vert_' num2str(frameNo) '.png'])
end

end