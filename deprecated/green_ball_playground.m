
img = imread('res/table_test.png');
mask = table_mask(img);
masked_img = img .* mask;

%masked_img = rgb2gray(masked_img);

%create color transformation structure
cform = makecform('srgb2lab');

% transform into L*a*b color space
input_lab = applycform(masked_img, cform); 

% extract the red-green chroma component
rg_chroma = input_lab(:,:,2);
by_chroma = input_lab(:,:,3);
luma = input_lab(:,:,1);


I = rg_chroma;
THRESHOLD = 0.45;
I = im2bw(I, THRESHOLD);
I = imcomplement(I);



%BW = edge(rgb2gray(masked_img),'roberts');
%I = imfilter(masked_img,fspecial('unsharp'));
%I = imsharpen(masked_img);
%BW = edge(rgb2gray(I),'canny',0.1);
%BW = edge(rgb2gray(masked_img),'prewitt',0.05);
%BW = edge(rgb2gray(masked_img),'sobel',0.15);
%BW = edge(rgb2gray(masked_img),'log');
%imshow(BW)

imshow(I)
%imshow(masked_img)

%[centers, radii] = imfindcircles(I,[10 15], 'ObjectPolarity','dark', 'Sensitivity',0.97);
[centers, radii] = imfindcircles(I,[10 15], 'ObjectPolarity','bright', 'Sensitivity',0.95);
%[centers, radii] = imfindcircles(I,[10 15], 'ObjectPolarity','dark', 'Sensitivity',0.92,'Method','twostage');

%delete(h);

h = viscircles(centers,radii);

%I = I .* mask(:,:,1);
