clear all; clc; close all;

%% loading data
rgbpath = './data/peaches/top/RGB';
rgbParams = load( './data/camParams_RGB.mat' );
thermalpath = './data/peaches/top/thermal'; 
load('./data/sfm_top.mat');

imgscale = .25;

rgbds = datastore( rgbpath );
thermalds = datastore( thermalpath );

useId = 8;
cameraParams = rgbParams.cameraParams;
rgb = undistortImage(readimage(rgbds, useId), cameraParams);
rgb = imresize(rgb, imgscale);

thermal = readimage(thermalds, useId);

figure(1)
imshow(rgb)
title('Original image')

%% binarization
[bw, maskedRGBImage] = createMask(rgb);

%% morph image
se = strel('disk',3/0.25*imgscale);
closeBW = imclose(bw, se);
figure(2);
imshow(closeBW);
se2 = strel('disk',5/0.25*imgscale);
openBW = imopen(closeBW, se2);
imshow(openBW); hold on;
peaches = regionprops(openBW, 'Centroid', 'BoundingBox', 'Area');

%% hough transform circles (no improvement)
%[centers, radii, metric] = imfindcircles(openBW,[10 30]);
%viscircles(centers, radii,'EdgeColor','b');

%% 8-bit connectivity if not opened after close
% CC = bwconncomp(closeBW);
% S = regionprops(CC, 'PixelIdxList', 'Centroid', 'Area');
% figure(2);
% imshow( closeBW ); hold on;
% for k = 1:CC.NumObjects
%     plot( S(k).Centroid(1), S(k).Centroid(2), 'rx', 'MarkerSize', 10);
% end

%% remove false positives if not opened after close
% measurements = regionprops(CC, 'Centroid', 'BoundingBox', 'Area');
% f = fieldnames(measurements)';
% f{2,1} = {};
% peaches = struct(f{:});
% idx = 1;
% for k = 1 : length(measurements)
%     thisBB = measurements(k).BoundingBox;
%     if thisBB(3) >= 19 || thisBB(4) >= 19
%         box_area = thisBB(3)*thisBB(4);
%         if measurements(k).Area/box_area > 0.5 
%             peaches(idx) = measurements(k);
%             idx = idx+1;
%         end
%     end
% end

%% print peaches
for k = 1 : length(peaches)
    thisBB = peaches(k).BoundingBox;
    rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
    plot( peaches(k).Centroid(1), peaches(k).Centroid(2), 'rx', 'MarkerSize', 10);
end