clear all; clc; close all;

%% loading data
data.peaches.top.RGB.path = '../data/peaches/top/RGB';
data.peaches.bottom.RGB.path = '../data/peaches/bottom/RGB';
data.camParams_RGB = load('../data/camParams_RGB.mat');

data.peaches.top.RGB.ds = datastore(data.peaches.top.RGB.path);
data.peaches.bottom.RGB.ds = datastore(data.peaches.bottom.RGB.path);

%% undistortion
data.peaches.top.RGB.undistorted = transform(data.peaches.top.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));
data.peaches.bottom.RGB.undistorted = transform(data.peaches.bottom.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));

%% binarization
data.peaches.top.binary = transform(data.peaches.top.RGB.undistorted, @(x) applyThreshold(x, 1));
data.peaches.bottom.binary = transform(data.peaches.bottom.RGB.undistorted, @(x) applyThreshold(x, 2));

%% small object removal
data.peaches.top.smallObjectsRemoved = transform(data.peaches.top.binary, @(x) removeSmallObjects(x));
data.peaches.bottom.smallObjectsRemoved = transform(data.peaches.bottom.binary, @(x) removeSmallObjects(x));

%% center detection
data.peaches.top.centers = transform(data.peaches.top.RGB.undistorted, @(x) detectCenters(x));
data.peaches.bottom.centers = transform(data.peaches.top.RGB.undistorted, @(x) detectCenters(x));

%% display images (for testing)
original = read(data.peaches.top.RGB.ds);
undistorted = read(data.peaches.top.RGB.undistorted);
binary = read(data.peaches.top.binary);
smallObjectsRemoved = read(data.peaches.top.smallObjectsRemoved);

figure;
subplot(2,2,1); imshow(original); title('original');
subplot(2,2,2); imshow(undistorted); title ('undistorted');
subplot(2,2,3); imshow(binary); title('binary');
subplot(2,2,4); imshow(smallObjectsRemoved); title ('smallObjectsRemoved');
