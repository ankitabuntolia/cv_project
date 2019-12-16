clear all; clc; close all;

%% loading data
rgbpath = './data/peaches/top/RGB';
thermalpath = './data/peaches/top/thermal'; 
imgscale = .25;

rgbds = datastore( rgbpath );
thermalds = datastore( thermalpath );

rgb = readimage(rgbds, 8);
rgb = imresize(rgb, imgscale);

thermal = readimage(thermalds, 8);

figure(1)
imshow(rgb)
title('Original image')
%% 

%% paper 3
% stretch red values
gray_rgb = rgb2gray(rgb);
red_channel = rgb(:,:,1);
red_min = min(red_channel(:));
red_max = max(red_channel(:));
red_stretched = 255*((red_channel-red_min)/(red_max-red_min));
rgb_stretched = rgb;
rgb_stretched(:,:,1) = red_stretched;
imshow(rgb_stretched)
segmented_image = zeros(size(gray_rgb));
segmented_image(rgb_stretched(:,:,1)-(rgb_stretched(:,:,2)+rgb_stretched(:,:,3))>100) = 1;
imshow(segmented_image)

%% hough
[centers, radii, ~] = imfindcircles(segmented_image, 20);
figure(); clf;
imshow(segmented_image)
viscircles(centers, radii,'EdgeColor','b');

%% 8-bit connectivity
CC = bwconncomp(segmented_image);
S = regionprops(CC, 'PixelIdxList', 'Centroid');
figure(); clf;
imshow( rgb ); hold on;
for k = 1:CC.NumObjects
    plot( S(k).Centroid(1), S(k).Centroid(2), 'rx', 'MarkerSize', 10);
end

%% k-means clustering
L = imsegkmeans(rgb, 2);
knn_rgb = labeloverlay(rgb, L);
figure(2)
imshow(knn_rgb)

L = imsegkmeans(thermal, 4);
knn_thermal = labeloverlay(thermal, L);
figure(3)
imshow(knn_thermal)
%%

%% apply spatial filters
h = fspecial('average', [10 10]);
avgImage = imfilter(rgb, h);
%imshow(avgImage)

% greyscale + edge detection
h = fspecial('sobel');
grey_rgb = rgb2gray(rgb);
sobelImg = imfilter(grey_rgb, h);
%imshow(sobelImg)
edgeImg = edge(grey_rgb, 'canny');
imshow(edgeImg)

% sharpen
sharp_rgb = imsharpen(rgb);
%imshow(sharp_rgb)
%%

%% circular hough transform
[centers, radii, metric] = imfindcircles(thermal,[10 30]);
imshow(thermal, [])
viscircles(centers, radii,'EdgeColor','b');

% watershed transform
I = rgb2gray(rgb);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
imshow(gradmag,[]), title('Gradient magnitude (gradmag)')
L = watershed(gradmag);
Lrgb = label2rgb(L);
imshow(imfuse(I, Lrgb)), title('Watershed transform of gradient magnitude (Lrgb)')
%%

%% Normalize.
I = rgb2gray(rgb);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
g = gradmag - min(gradmag(:));
g = g / max(g(:));

th = graythresh(g); %# Otsu's method.
a = imhmax(g,th/2); %# Conservatively remove local maxima.
th = graythresh(a);
b = a > th/4; %# Conservative global threshold.
c = imclose(b,ones(6)); %# Try to close contours.
d = imfill(c,'holes'); %# Not a bad segmentation by itself.
imshow(imfuse(I, d))
%%

%% otsu
level = graythresh(rgb2gray(rgb));
BW = imbinarize(I,level);
imshowpair(rgb,BW,'montage')
%%

%% lab color space
lab_tree = rgb2lab(rgb);
figure()
imshow(lab_tree)
nColors = 2;
color_markers = zeros([nColors, 2]); 
% a, b values read out of lab image
a = lab_tree(:,:,2);
b = lab_tree(:,:,3);
% peaches
color_markers(1,1) = a(669, 597);
color_markers(1,2) = b(669, 597);
% leaves
color_markers(2,1) = a(706, 699);
color_markers(2,2) = b(706, 699);
color_labels = 0:nColors-1;
a = double(a);
b = double(b);
distance = zeros([size(a), nColors]);

for count = 1:nColors
  distance(:,:,count) = ( (a - color_markers(count,1)).^2 + ...
                      (b - color_markers(count,2)).^2 ).^0.5;
end

[~,label] = min(distance,[],3);
label = color_labels(label);
clear distance;

rgb_label = repmat(label,[1 1 3]);
segmented_images = zeros([size(rgb), nColors],'uint8');

for count = 1:nColors
  color = rgb;
  color(rgb_label ~= color_labels(count)) = 0;
  segmented_images(:,:,:,count) = color;
end 

figure()
montage({segmented_images(:,:,:,2),segmented_images(:,:,:,1)});
title("Montage of Red and Green Objects")
%%

%% rgb color space
rgb_tree = rgb;
figure()
imshow(rgb_tree)
nColors = 2;
color_markers = zeros([nColors, 3]); 
% r, g, b values read out of rgb image
r = rgb_tree(:,:,1);
g = rgb_tree(:,:,2);
b = rgb_tree(:,:,3);
% peaches
color_markers(1,1) = r(663, 596);
color_markers(1,2) = g(663, 596);
color_markers(1,3) = b(663, 596);
% leaves
color_markers(2,1) = r(706, 699);
color_markers(2,2) = g(706, 699);
color_markers(2,3) = b(706, 699);
color_labels = 0:nColors-1;
r = double(r);
g = double(g);
b = double(b);
distance = zeros([size(r), nColors]);

for count = 1:nColors
  distance(:,:,count) = ( (r - color_markers(count,1)).^2 + ...
                      (g - color_markers(count,2)).^2 + ...
                      (b - color_markers(count,3)).^2).^0.5;
end

[~,label] = min(distance,[],3);
label = color_labels(label);
clear distance;

rgb_label = repmat(label,[1 1 3]);
segmented_images = zeros([size(rgb), nColors],'uint8');

for count = 1:nColors
  color = rgb;
  color(rgb_label ~= color_labels(count)) = 0;
  segmented_images(:,:,:,count) = color;
end 

figure()
montage({segmented_images(:,:,:,2),segmented_images(:,:,:,1)});
title("Montage of Red and Green Objects")
%%

%% svm classifier
[imds,pxds] = pixelLabelTrainingData(gTruth);

%%