clear all; clc; close all;

%% loading data
data.peaches.top.RGB.path = '../data/peaches/top/RGB';
data.peaches.top.thermal.path = '../data/peaches/top/thermal';
data.peaches.bottom.RGB.path = '../data/peaches/bottom/RGB';
data.peaches.bottom.thermal.path = '../data/peaches/bottom/thermal';
data.peaches.calibration.RGB.path = '../data/peaches/calibration/RGB';
data.peaches.calibration.thermal.path = '../data/peaches/calibration/thermal';
data.camParams_RGB = load('../data/camParams_RGB.mat');
data.camParams_thermal = load('../data/camParams_thermal.mat');

data.peaches.top.RGB.ds = datastore(data.peaches.top.RGB.path);
data.peaches.top.thermal.ds = datastore(data.peaches.top.thermal.path);
data.peaches.bottom.RGB.ds = datastore(data.peaches.bottom.RGB.path);
data.peaches.bottom.thermal.ds = datastore(data.peaches.bottom.thermal.path);
data.peaches.calibration.RGB.ds = datastore(data.peaches.calibration.RGB.path);
data.peaches.calibration.thermal.ds = datastore(data.peaches.calibration.thermal.path);

assert(length(data.peaches.top.RGB.ds.Files) == length(data.peaches.top.thermal.ds.Files));
assert(length(data.peaches.bottom.RGB.ds.Files) == length(data.peaches.bottom.thermal.ds.Files));
assert(length(data.peaches.calibration.RGB.ds.Files) == 1);
assert(length(data.peaches.calibration.thermal.ds.Files) == 1);

%% undistortion
data.peaches.top.RGB.undistorted = transform(data.peaches.top.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));
data.peaches.top.thermal.undistorted = transform(data.peaches.top.thermal.ds, @(x) undistort(x, data.camParams_thermal.cameraParams));
data.peaches.bottom.RGB.undistorted = transform(data.peaches.bottom.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));
data.peaches.bottom.thermal.undistorted = transform(data.peaches.bottom.thermal.ds, @(x) undistort(x, data.camParams_thermal.cameraParams));
data.peaches.calibration.RGB.undistorted = transform(data.peaches.calibration.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));
data.peaches.calibration.thermal.undistorted = transform(data.peaches.calibration.thermal.ds, @(x) undistort(x, data.camParams_thermal.cameraParams));

%% shadow reduction
data.peaches.top.RGB.shadowReduced = transform(data.peaches.top.RGB.undistorted, @(x) reduceShadows(x));
data.peaches.bottom.RGB.shadowReduced = transform(data.peaches.bottom.RGB.undistorted, @(x) reduceShadows(x));

%% conversion to grayscale
data.peaches.top.RGB.grayscaled = transform(data.peaches.top.RGB.shadowReduced, @(x) convertToGrayscale(x));
data.peaches.bottom.RGB.grayscaled = transform(data.peaches.bottom.RGB.shadowReduced, @(x) convertToGrayscale(x));

%% noise reduction
data.peaches.top.RGB.noiseReduced = transform(data.peaches.top.RGB.grayscaled, @(x) reduceNoise(x));
data.peaches.bottom.RGB.noiseReduced = transform(data.peaches.bottom.RGB.grayscaled, @(x) reduceNoise(x));

%% calibration
[rgbImagePoints, rgbBoardSize, rgbImagesUsed] = detectCheckerboardPoints(read(data.peaches.calibration.RGB.undistorted));
[thermalImagePoints, thermalBoardSize, thermalImagesUsed] = detectCheckerboardPoints(imcomplement(read(data.peaches.calibration.thermal.undistorted)));
assert(isequal(thermalBoardSize, rgbBoardSize));
tform = fitgeotrans(thermalImagePoints, rgbImagePoints, 'projective');
rgb = readimage(data.peaches.top.RGB.ds, 1);
data.peaches.top.thermal.calibrated = transform(data.peaches.top.thermal.undistorted, @(x) calibrate(x, tform, imref2d(size(rgb))));
data.peaches.bottom.thermal.calibrated = transform(data.peaches.bottom.thermal.undistorted, @(x) calibrate(x, tform, imref2d(size(rgb))));

%% thresholding
data.peaches.top.combined = combine(data.peaches.top.RGB.ds, data.peaches.top.RGB.noiseReduced, data.peaches.top.thermal.calibrated);
data.peaches.bottom.combined = combine(data.peaches.bottom.RGB.ds, data.peaches.bottom.RGB.noiseReduced, data.peaches.bottom.thermal.calibrated);
data.peaches.top.binary = transform(data.peaches.top.combined, @(x) applyThreshold(x{2}, x{3}));
data.peaches.bottom.binary = transform(data.peaches.bottom.combined, @(x) applyThreshold(x{2}, x{3}));

%% small object removal
data.peaches.top.smallObjectsRemoved = transform(data.peaches.top.binary, @(x) removeSmallObjects(x));
data.peaches.bottom.smallObjectsRemoved = transform(data.peaches.bottom.binary, @(x) removeSmallObjects(x));

%% inversion
data.peaches.top.inverted = transform(data.peaches.top.smallObjectsRemoved, @(x) invert(x));
data.peaches.bottom.inverted = transform(data.peaches.bottom.smallObjectsRemoved, @(x) invert(x));

%% display images (for testing)
original = read(data.peaches.top.RGB.ds);
shadowReduced = read(data.peaches.top.RGB.shadowReduced);
grayscaled = read(data.peaches.top.RGB.grayscaled);
preprocessed = read(data.peaches.top.inverted);
figure;
subplot(2,2,1); imshow(original); title('original');
subplot(2,2,2); imshow(shadowReduced); title ('shadow reduced');
subplot(2,2,3); imshow(grayscaled); title('grayscaled');
subplot(2,2,4); imshow(preprocessed); title ('preprocessed');
