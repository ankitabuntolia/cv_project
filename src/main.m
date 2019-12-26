clear all; clc; close all;

%% loading data
data.peaches.top.RGB.path = '../data/peaches/top/RGB';
data.peaches.top.thermal.path = '../data/peaches/top/thermal';
data.peaches.bottom.RGB.path = '../data/peaches/bottom/RGB';
data.peaches.bottom.thermal.path = '../data/peaches/bottom/thermal';
data.camParams_RGB = load('../data/camParams_RGB.mat');
data.camParams_thermal = load('../data/camParams_thermal.mat');

data.peaches.top.RGB.ds = datastore(data.peaches.top.RGB.path);
data.peaches.top.thermal.ds = datastore(data.peaches.top.thermal.path);
data.peaches.bottom.RGB.ds = datastore(data.peaches.bottom.RGB.path);
data.peaches.bottom.thermal.ds = datastore(data.peaches.bottom.thermal.path);

assert(length(data.peaches.top.RGB.ds.Files) == length(data.peaches.top.thermal.ds.Files));
assert(length(data.peaches.bottom.RGB.ds.Files) == length(data.peaches.bottom.thermal.ds.Files));

%% undistortion
data.peaches.top.RGB.undistorted = transform(data.peaches.top.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));
data.peaches.top.thermal.undistorted = transform(data.peaches.top.thermal.ds, @(x) undistort(x, data.camParams_thermal.cameraParams));
data.peaches.bottom.RGB.undistorted = transform(data.peaches.bottom.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));
data.peaches.bottom.thermal.undistorted = transform(data.peaches.bottom.thermal.ds, @(x) undistort(x, data.camParams_thermal.cameraParams));

%% noise reduction
data.peaches.top.RGB.noiseReduced = transform(data.peaches.top.RGB.undistorted, @(x) reduceNoise(x));
data.peaches.bottom.RGB.noiseReduced = transform(data.peaches.bottom.RGB.undistorted, @(x) reduceNoise(x));

%% shadow reduction
data.peaches.top.RGB.shadowReduced = transform(data.peaches.top.RGB.noiseReduced, @(x) reduceShadows(x));
data.peaches.bottom.RGB.shadowReduced = transform(data.peaches.bottom.RGB.noiseReduced, @(x) reduceShadows(x));

%% conversion to grayscale
data.peaches.top.RGB.grayscaled = transform(data.peaches.top.RGB.shadowReduced, @(x) convertToGrayscale(x));
data.peaches.bottom.RGB.grayscaled = transform(data.peaches.bottom.RGB.shadowReduced, @(x) convertToGrayscale(x));

%% calibration
data.peaches.top.thermal.calibrated = transform(data.peaches.top.thermal.undistorted, @(x) calibrate(x));
data.peaches.bottom.thermal.calibrated = transform(data.peaches.bottom.thermal.undistorted, @(x) calibrate(x));

%% thresholding
data.peaches.top.combined = combine(data.peaches.top.RGB.grayscaled, data.peaches.top.thermal.calibrated);
data.peaches.bottom.combined = combine(data.peaches.bottom.RGB.grayscaled, data.peaches.bottom.thermal.calibrated);
data.peaches.top.binary = transform(data.peaches.top.combined, @(x) applyThreshold(x));
data.peaches.bottom.binary = transform(data.peaches.bottom.combined, @(x) applyThreshold(x));

%% display images (for testing)
image = read(data.peaches.top.RGB.grayscaled);
figure;
imshow(image);
