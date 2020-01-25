clear; clc; close all;

%% data loading
data.peaches.top.RGB.path = '../data/peaches/top/RGB';
data.peaches.bottom.RGB.path = '../data/peaches/bottom/RGB';
data.camParams_RGB = load('../data/camParams_RGB.mat');
data.sfm_top = load('../data/sfm_top.mat');
data.sfm_bottom = load('../data/sfm_bottom.mat');

data.peaches.top.RGB.ds = datastore(data.peaches.top.RGB.path);
data.peaches.bottom.RGB.ds = datastore(data.peaches.bottom.RGB.path);

data.camParams_RGB.cameraIntrinsics = cameraIntrinsics(data.camParams_RGB.cameraParams.FocalLength, data.camParams_RGB.cameraParams.PrincipalPoint, data.camParams_RGB.cameraParams.ImageSize);

data.results.top.binary.path = '../data/result/top/binary';
data.results.top.smallObjectsRemoved.path = '../data/result/top/smallObjectsRemoved';
data.results.top.markersInserted.path = '../data/result/top/markersInserted';
data.results.top.visualized.path = '../data/result/top/visualized';
data.results.bottom.binary.path = '../data/result/bottom/binary';
data.results.bottom.smallObjectsRemoved.path = '../data/result/bottom/smallObjectsRemoved';
data.results.bottom.markersInserted.path = '../data/result/bottom/markersInserted';
data.results.bottom.visualized.path = '../data/result/bottom/visualized';

[~, ~, ~] = mkdir(data.results.top.binary.path);
[~, ~, ~] = mkdir(data.results.top.smallObjectsRemoved.path);
[~, ~, ~] = mkdir(data.results.top.markersInserted.path);
[~, ~, ~] = mkdir(data.results.top.visualized.path);
[~, ~, ~] = mkdir(data.results.bottom.binary.path);
[~, ~, ~] = mkdir(data.results.bottom.smallObjectsRemoved.path);
[~, ~, ~] = mkdir(data.results.bottom.markersInserted.path);
[~, ~, ~] = mkdir(data.results.bottom.visualized.path);

%% undistortion
data.peaches.top.RGB.undistorted = transform(data.peaches.top.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));
data.peaches.bottom.RGB.undistorted = transform(data.peaches.bottom.RGB.ds, @(x) undistort(x, data.camParams_RGB.cameraParams));

%% binarization
data.peaches.top.binary = transform(data.peaches.top.RGB.undistorted, @(x) createMaskTop(x));
data.peaches.bottom.binary = transform(data.peaches.bottom.RGB.undistorted, @(x) createMaskBottom(x));

%% small object removal
data.peaches.top.smallObjectsRemoved = transform(data.peaches.top.binary, @(x) removeSmallObjects(x));
data.peaches.bottom.smallObjectsRemoved = transform(data.peaches.bottom.binary, @(x) removeSmallObjects(x));

%% center detection
data.peaches.top.centers = transform(data.peaches.top.smallObjectsRemoved, @(x) detectCenters(x));
data.peaches.bottom.centers = transform(data.peaches.bottom.smallObjectsRemoved, @(x) detectCenters(x));

%% markers insertion
data.peaches.top.undistoredWithCenters = combine(data.peaches.top.RGB.ds, data.peaches.top.RGB.undistorted, data.peaches.top.centers);
data.peaches.bottom.undistoredWithCenters = combine(data.peaches.top.RGB.ds, data.peaches.bottom.RGB.undistorted, data.peaches.bottom.centers);
data.peaches.top.markersInserted = transform(data.peaches.top.undistoredWithCenters, @(x) insertMarkers(x));
data.peaches.bottom.markersInserted = transform(data.peaches.bottom.undistoredWithCenters, @(x) insertMarkers(x));

%% intermediate results exraction and saving
data.centers.top.center = cell(length(data.peaches.top.RGB.ds.Files), 1);
data.centers.top.centroid = cell(length(data.peaches.top.RGB.ds.Files), 1);
data.centers.top.boundingBox = cell(length(data.peaches.top.RGB.ds.Files), 1);
for i = 1:length(data.peaches.top.RGB.ds.Files)
  data.centers.top.center{i} = read(data.peaches.top.centers);
  if isempty(data.centers.top.center{i})
    data.centers.top.centroid{i} = [];
    data.centers.top.boundingBox{i} = [];
  else
    data.centers.top.centroid{i} = cell2mat({data.centers.top.center{i}.Centroid}');
    data.centers.top.boundingBox{i} = cell2mat({data.centers.top.center{i}.BoundingBox}');
  end
end

data.centers.bottom.center = cell(length(data.peaches.bottom.RGB.ds.Files), 1);
data.centers.bottom.centroid = cell(length(data.peaches.bottom.RGB.ds.Files), 1);
data.centers.bottom.boundingBox = cell(length(data.peaches.bottom.RGB.ds.Files), 1);
for i = 1:length(data.peaches.bottom.RGB.ds.Files)
  data.centers.bottom.center{i} = read(data.peaches.bottom.centers);
  if isempty(data.centers.bottom.center{i})
    data.centers.bottom.centroid{i} = [];
    data.centers.bottom.boundingBox{i} = [];
  else
    data.centers.bottom.centroid{i} = cell2mat({data.centers.bottom.center{i}.Centroid}');
    data.centers.bottom.boundingBox{i} = cell2mat({data.centers.bottom.center{i}.BoundingBox}');
  end
end

clear i;

data_centers_top_center = data.centers.top.center;
data_centers_top_centroid = data.centers.top.centroid;
data_centers_top_boundingBox = data.centers.top.boundingBox;
data_centers_bottom_center = data.centers.bottom.center;
data_centers_bottom_centroid = data.centers.bottom.centroid;
data_centers_bottom_boundingBox = data.centers.bottom.boundingBox;

save('centers_precomputed', 'data_centers_top_center', 'data_centers_top_centroid', 'data_centers_top_boundingBox', 'data_centers_bottom_center', 'data_centers_bottom_centroid', 'data_centers_bottom_boundingBox');

clear data_centers_top_center;
clear data_centers_top_centroid;
clear data_centers_top_boundingBox;
clear data_centers_bottom_center;
clear data_centers_bottom_centroid;
clear data_centers_bottom_boundingBox;

%% tracking
k_class_top = 20000;
k_class_bottom = 20000;
threshold_top = 10;
threshold_bottom = 35;

[data.results.top.tracked, data.results.top.count] = tracking(data.camParams_RGB.cameraIntrinsics, data.sfm_top.vSet.Views, data.sfm_top.xyzPoints, data.centers.top.centroid, threshold_top, k_class_top, data.centers.top.boundingBox);
[data.results.bottom.tracked, data.results.bottom.count] = tracking(data.camParams_RGB.cameraIntrinsics, data.sfm_bottom.vSet.Views, data.sfm_top.xyzPoints, data.centers.bottom.centroid, threshold_bottom, k_class_bottom, data.centers.bottom.boundingBox);

clear k_class_top;
clear k_class_bottom;
clear threshold_top;
clear threshold_bottom;

%% final results visualization and writing
reset(data.peaches.top.markersInserted);
for i = 1:size(data.peaches.top.RGB.ds.Files)
  imwrite(read(data.peaches.top.binary), strcat(data.results.top.binary.path, '/', data.sfm_top.imagenames{i}));
  imwrite(read(data.peaches.top.smallObjectsRemoved), strcat(data.results.top.smallObjectsRemoved.path, '/', data.sfm_top.imagenames{i}));
  markersInserted = read(data.peaches.top.markersInserted);
  imwrite(markersInserted, strcat(data.results.top.markersInserted.path, '/', data.sfm_top.imagenames{i}));
  visualized = visualize(markersInserted, data.results.top.tracked{i});
  imwrite(visualized, strcat(data.results.top.visualized.path, '/', data.sfm_top.imagenames{i}));
end

for i = 1:length(data.peaches.bottom.RGB.ds.Files)
  imwrite(read(data.peaches.bottom.binary), strcat(data.results.bottom.binary.path, '/', data.sfm_bottom.imagenames{i}));
  imwrite(read(data.peaches.bottom.smallObjectsRemoved), strcat(data.results.bottom.smallObjectsRemoved.path, '/', data.sfm_bottom.imagenames{i}));
  markersInserted = read(data.peaches.bottom.markersInserted);
  imwrite(markersInserted, strcat(data.results.bottom.markersInserted.path, '/', data.sfm_bottom.imagenames{i}));
  visualized = visualize(markersInserted, data.results.bottom.tracked{i});
  imwrite(visualized, strcat(data.results.bottom.visualized.path, '/', data.sfm_bottom.imagenames{i}));
end

clear i;
clear markersInserted;
clear visualized;
