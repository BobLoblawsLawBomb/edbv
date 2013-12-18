function [ component1, component2 ] = coloredComponents( input )
%diese Funktion trennt die Kugeln vom Hintergrund, die einzige Kugel, die
%laut dieser Funktion zum Hintergrund gezählt wir, ist die gelbe.
%die Funktion wird von connectedComponent.m aufgerufen und ist dazu da, die
%farbigen Komponenten zu ermitteln.

%umwandlung in lab-Farbraum
cform = makecform('srgb2lab');
lab = applycform(input,cform);

ab = double(lab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

%Anzahl der Komponenten, die ermittelt werden sollen
nColors = 2;

%Komponenten-Ermittlung durch K-means
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','start','uniform');

pixel_labels = reshape(cluster_idx,nrows,ncols);

segmented_images = cell(1,2);
rgb_label = repmat(pixel_labels,[1 1 3]);

%Komponenten werden getrennt gespeichert
for k = 1:nColors
    color = input;
    color(rgb_label ~= k) = 0;
    bw = im2bw(color);
    bw = bwmorph(bw,'thicken',10);
    bw_mask = repmat( uint8(bw), [1 1 3]);
    color = color .* bw_mask;
    segmented_images{k} = color;
    imshow(color);
    
end

component1 = segmented_images{1};
component2 = segmented_images{2};
  
end
