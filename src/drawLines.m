function [ lineimage ] = drawLines(im, A, cols, thickness)
%   Zeichnet farbige Linien über ein Bild.
% 
%   --- INPUT ---
%   
%   im
%    Das Bild über das die Linien gezeichnet werden. Es gibt auch
%    die Skalierung vor.
%   
%   A
%    Matrix mit Punktpositionen pro Linie pro Linien-Schritt (Frame)
%    Sie hat foldende Form: A(x, y, line, frame)
%   
%   cols
%    Matrix mit Farbwerten [r g b] pro Linie.
%    Sie hat folgende Form: [r g b] = cols(linie, :)
%   
%   thickness
%    Die Dicke der gezeichneten Linien in pixel.
%   
%   --- OUTPUT ---
%   
%   lineimage
%    n x m x 3 Matrix welche die Bildinformationen mit farbig darüber 
%    gezeichneten Linien beinhaltet.
%
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

%Plotte die einzelnen Linien.
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