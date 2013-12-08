function [ result ] = green_ball_detector( masked_img )
%GREEN_BALL_DETECTOR Summary of this function goes here
% Author: Maximilian Irro
%   Detailed explanation goes here

cform = makecform('srgb2lab');

% convert to  L*a*b color space
input_lab = applycform(masked_img, cform); 

rg_chroma = input_lab(:,:,2); % red/green chroma component
by_chroma = input_lab(:,:,3); % blue/yellow chroma component 

% so we build a mask that will let green stuff pass, and eliminate the red
THRESHOLD_RG = 0.5;
greenpass = imcomplement(im2bw(rg_chroma,THRESHOLD_RG));

% now we built one that eliminates the yellow parts
THRESHOLD_BY = 0.6;
bluepass = imcomplement(im2bw(by_chroma,THRESHOLD_BY));

% combine filters, cut out what we can
I = greenpass .* bluepass;

result = I;

%[centers, radii] = imfindcircles(I,[10 15], 'ObjectPolarity','bright', 'Sensitivity',0.95, 'Method', 'TwoStage');


end






