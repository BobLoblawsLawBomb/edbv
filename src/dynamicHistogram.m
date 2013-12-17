function [ dataUniqueList, dataCountList, count, my , varianz, mcount] = dynamicHistogram( data, tolerance, threshold, rangemin, rangemax)
%UNTITLED6 Summary of this function goes here
%   if min max are not NaN the its circular going from max to min
%
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

debug = false;

range = rangemax - rangemin;

[w, h] = size(data);

dataListAll = reshape(data, w*h, 1);
dataListTrim = dataListAll(dataListAll(:) > threshold);
dataListSorted = sort(dataListTrim); % von bei pos 1 weg: min < value <= max
dataUniqueList = unique(dataListSorted);
dataCountList = zeros(size(dataUniqueList));

count = length(dataListTrim);

% disp([size(dataUniqueList) size(dataListSorted)]);

for k = 1 : size(dataUniqueList)
    anglek = dataUniqueList(k);
    % count similiar data in the variance-range
    
    edge1 = anglek - tolerance;
    edge2 = anglek + tolerance;
    
    if ~isnan(rangemin) && ~isnan(rangemax)
        
        if edge1 <= rangemin
            edge1 = edge1 + range;
        end
        
        if edge2 > rangemax
            edge2 = edge2 - range;
        end
        
    end

    if edge1 > edge2   % achtung, in diesem fall springt der zu betrachtende bereich von max zu min
        n = histc(dataListSorted, [-inf edge2 edge1 inf]);
        dataCountList(k) = n(1) + n(3);
    else
        n = histc(dataListSorted, [edge1 edge2]);
        dataCountList(k) = n(1);
    end
end

%visualize velocity directions with colors
% fig3 = figure(3);
% data_max = max(dataUniqueList);
% color_data = double(repmat(zeros(size(data)), [1 1 3]));
% color_data(:,:,1) = data;
% color_data(:,:,2) = 1;
% color_data(:,:,3) = 1;%abs(data)/data_max;
% imshow(hsv2rgb(color_data));

%visualize velocity intensity


% ofVelocity_max = max(max(max(ofVelocityFiltered)));
% color_of = double(repmat(zeros(size(ofVelocityFiltered)), [1 1 3]));
% color_of(:,:,1) = 0;
% color_of(:,:,2) = 0;
% color_of(:,:,3) = 1;%ofVelocityFiltered/ofVelocity_max;
% imshow(hsv2rgb(color_of));

%print(fig3, '-dpng', [pwd filesep 'results' filesep 'OF_Color_' num2str(frameNo) '.png'])

% try
%     clf(2);
% end

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

if(debug)
    disp(['my: ',num2str(my),' ',num2str(mcount),' ',num2str(varianz)]);
    
    fig2 = figure(2);
    bar(dataUniqueList, dataCountList, 'BarWidth', 1);
    ylim([0 150]);
    xlim([0 1]);
    
    if elcount > 2
        %     [pks, locs] = findpeaks(dataCountList, 'MINPEAKHEIGHT', 1, 'THRESHOLD', 3);
        %     [C,I] = max(dataCountList);
        hold on;
        %     plot(dataUniqueList(I), C + 0.05, 'k^', 'markerfacecolor', [1 0 0]);
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