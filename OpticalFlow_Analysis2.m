function [ ] = OpticalFlow_Analysis2( of )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

angleVariance = 5; %ähnlichkeitsumgebung in grad
velocityThreshold = 0.001;

[ofw, ofh] = size(of);
ofAngle = angle(of);
ofVelocity = abs(of);

% ofAngleListAll = reshape(ofAngle, ofw*ofh, 1);
% ofVelocityListAll = reshape(ofVelocity, ofw*ofh, 1);
% ofAngleListTrim = ofAngleListAll(ofVelocityListAll(:) > velocityThreshold);
% ofAngleListSorted = sort(radtodeg(ofAngleListTrim)); % von bei pos 1 weg: -180 < angle <= 180
% ofAngleUniqueList = unique(ofAngleListSorted);
% ofAngleCountList = zeros(size(ofAngleUniqueList));
%
% disp([size(ofAngleUniqueList) size(ofAngleListSorted)]);
%
% for k = 1 : size(ofAngleUniqueList)
%     anglek = ofAngleUniqueList(k);
%     zähle ähnliche richtungen in gewissem bereich
%     edge1 = anglek - angleVariance;
%     if edge1 <= -180
%         edge1 = edge1 + 360;
%     end
%
%     edge2 = anglek + angleVariance;
%     if edge2 > 180
%         edge2 = edge2 - 360;
%     end
%
%     if edge1 > edge2   % achtung: der zu betrachtende bereich springt von 180 zu -180
%         n = histc(ofAngleListSorted, [-inf edge2 edge1 inf]);
%         ofAngleCountList(k) = n(1) + n(3);
%     else
%         n = histc(ofAngleListSorted, [edge1 edge2]);
%         ofAngleCountList(k) = n(1);
%     end
% end

%visualize velocity directions with colors
% fig3 = figure(3);
% of_max = max(max(max(abs(of))));
% color_of = double(repmat(zeros(size(of)), [1 1 3]));
% color_of(:,:,1) = 0.5 + ofAngle/(2*pi);
% color_of(:,:,2) = 1;
% color_of(:,:,3) = abs(of)/of_max;
% imshow(hsv2rgb(color_of));

%visualize velocity intensity

of_max = max(max(max(ofVelocity)));
% ofIntensity = zeros(size(ofVelocity));
ofIntensity = ofVelocity/of_max;

fig7 = figure(7);
imshow(ofIntensity);

ofVelocityFiltered = zeros(size(ofVelocity));
ofVelocityFiltered(ofVelocity(:,:) > 0.01) = 1;

fig5 = figure(5);
imshow(ofVelocityFiltered);

[of_comps, of_comp_count] = ccl_labeling( ofVelocityFiltered );

fig6 = figure(6);
imshow(label2rgb(of_comps));

%TODO: Components mit Gerrys methoden verarbeiten


% ofVelocity_max = max(max(max(ofVelocityFiltered)));
% color_of = double(repmat(zeros(size(ofVelocityFiltered)), [1 1 3]));
% color_of(:,:,1) = 0;
% color_of(:,:,2) = 0;
% color_of(:,:,3) = 1;%ofVelocityFiltered/ofVelocity_max;
% imshow(hsv2rgb(color_of));

%print(fig3, '-dpng', [pwd filesep 'results' filesep 'OF_Color_' num2str(frameNo) '.png'])

% [pks, locs] = findpeaks(ofAngleCountList, 'MINPEAKHEIGHT', 1, 'THRESHOLD', 3);
%
% fig2 = figure(2);
% bar(ofAngleUniqueList, ofAngleCountList, 'BarWidth', 1);
% ylim([0 2000])
% hold on;
% plot(ofAngleUniqueList(locs), pks + 0.05, 'k^', 'markerfacecolor', [1 0 0]);
% hold off;
%print(fig2, '-dpng', [pwd filesep 'results' filesep 'Vert_' num2str(velocityThreshold) '_' num2str(angleVariance) filesep 'Vert_' num2str(frameNo) '.png'])

end