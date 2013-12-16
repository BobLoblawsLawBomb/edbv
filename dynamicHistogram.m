function [ dataUniqueList, dataCountList, count ] = dynamicHistogram( data, variance, threshold, rangemin, rangemax)
%UNTITLED6 Summary of this function goes here
%   if min max are not NaN the its circular going from max to min
%
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

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
    
    edge1 = anglek - variance;
    edge2 = anglek + variance;
    
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

% fig2 = figure(2);
% bar(dataUniqueList, dataCountList, 'BarWidth', 1);
% ylim([0 250]);
% xlim([0 1]);
% 
% elcount = numel(dataCountList);
% 
% if elcount > 2
% %     [pks, locs] = findpeaks(dataCountList, 'MINPEAKHEIGHT', 1, 'THRESHOLD', 3);
%     [C,I] = max(dataCountList);
%     hold on;
%     plot(dataUniqueList(I), C + 0.05, 'k^', 'markerfacecolor', [1 0 0]);
%     hold off;
% end
%print(fig2, '-dpng', [pwd filesep 'results' filesep 'Vert_' num2str(velocityThreshold) '_' num2str(angleVariance) filesep 'Vert_' num2str(frameNo) '.png'])

end