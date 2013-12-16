function [ lineimage ] = drawLines(im, A, cols, thickness)
%UNTITLED Summary of this function goes here
%   imsize = [height width]
%   A = array mit punktpositionen pro ball pro frame
%   cols = farbwerte [r g b] pro ball
%
%   @author Andreas Mursch-Radlgruber
%---------------------------------------------

imsize = size(im);
w = imsize(2);
h = imsize(1);

try
    clf(100);
end
fig = figure(100);
set(fig, 'Visible', 'off');
set(fig, 'Position', [0 0 w h]);
set(fig, 'PaperSize', [w h]);

%Background muss gezeichnet werden, damit die punkte an die richtige stelle
%gezeichnet werden.. irgendwo versteckt sich eine skalierung und/oder
%ein offset der so korrigiert wird.
%background = ones(imsize);
imshow(im);

hold on;

axis manual;
axis([0, w, 0, h]);
axis ij;
axis off;

for  ball_nr = 1 : size( A , 3)
    ball_color(:,:) = cols(ball_nr,:);
    ballPointList(:,:) = A(:, :, ball_nr, :);
    plot(ballPointList(1,:), ballPointList(2,:), 'Color', ball_color, 'Linewidth', thickness, 'Clipping', 'off');
end

hold off;

%create an image from the figure
%Source: http://www.mathworks.com/matlabcentral/answers/99925
set(fig, 'PaperPositionMode', 'auto');
lineimage = hardcopy(fig, '-Dzbuffer', '-r0');

end