clear all; clc; close all;

%% loading data
useIdTop = 8;
useIdBottom = 8;

data.peaches.top.RGB.path = '../data/peaches/top/RGB';
data.peaches.bottom.RGB.path = '../data/peaches/bottom/RGB';
data.camParams_RGB = load('../data/camParams_RGB.mat');

data.peaches.top.RGB.ds = datastore(data.peaches.top.RGB.path);
data.peaches.bottom.RGB.ds = datastore(data.peaches.bottom.RGB.path);

data.peaches.top.RGB.original = readimage(data.peaches.top.RGB.ds, useIdTop);
data.peaches.bottom.RGB.original = readimage(data.peaches.bottom.RGB.ds, useIdBottom);

%% undistortion
data.peaches.top.RGB.undistorted = undistort(data.peaches.top.RGB.original, data.camParams_RGB.cameraParams);
data.peaches.bottom.RGB.undistorted = undistort(data.peaches.bottom.RGB.original, data.camParams_RGB.cameraParams);

%% binarization
data.peaches.top.binary = createMaskTop(data.peaches.top.RGB.undistorted);
data.peaches.bottom.binary = createMaskBottom(data.peaches.bottom.RGB.undistorted);

%% small object removal
data.peaches.top.smallObjectsRemoved = removeSmallObjects(data.peaches.top.binary);
data.peaches.bottom.smallObjectsRemoved = removeSmallObjects(data.peaches.bottom.binary);

%% center detection
data.peaches.top.centers = detectCenters(data.peaches.top.smallObjectsRemoved);
data.peaches.bottom.centers = detectCenters(data.peaches.bottom.smallObjectsRemoved);

%% display images (for testing)
figure('Name', 'top');
subplot(2,2,1); imshow(data.peaches.top.RGB.original); title('original');
subplot(2,2,2); imshow(data.peaches.top.RGB.undistorted); title ('undistorted'); hold on;
for k = 1 : length(data.peaches.top.centers)
  thisBB = data.peaches.top.centers(k).BoundingBox;
  rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
  plot(data.peaches.top.centers(k).Centroid(1), data.peaches.top.centers(k).Centroid(2), 'rx', 'MarkerSize', 10);
end
subplot(2,2,3); imshow(data.peaches.top.binary); title('binary');
subplot(2,2,4); imshow(data.peaches.top.smallObjectsRemoved); title ('smallObjectsRemoved');


figure('Name', 'bottom');
subplot(2,2,1); imshow(data.peaches.bottom.RGB.original); title('original');
subplot(2,2,2); imshow(data.peaches.bottom.RGB.undistorted); title ('undistorted'); hold on;
for k = 1 : length(data.peaches.bottom.centers)
  thisBB = data.peaches.bottom.centers(k).BoundingBox;
  rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
  plot(data.peaches.bottom.centers(k).Centroid(1), data.peaches.bottom.centers(k).Centroid(2), 'rx', 'MarkerSize', 10);
end
subplot(2,2,3); imshow(data.peaches.bottom.binary); title('binary');
subplot(2,2,4); imshow(data.peaches.bottom.smallObjectsRemoved); title ('smallObjectsRemoved');
