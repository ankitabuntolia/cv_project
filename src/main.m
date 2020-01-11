clear all; clc; close all;

%% loading data
data.peaches.top.RGB.path = '../data/peaches/top/RGB';
data.peaches.bottom.RGB.path = '../data/peaches/bottom/RGB';
data.camParams_RGB = load('../data/camParams_RGB.mat');

data.peaches.top.RGB.ds = datastore(data.peaches.top.RGB.path);
data.peaches.bottom.RGB.ds = datastore(data.peaches.bottom.RGB.path);

load('../data/sfm_top.mat');
camPoses_top = poses(vSet);
load('../data/sfm_bottom.mat');
camPoses_bottom = poses(vSet);

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

%% display images (for testing)
original = read(data.peaches.top.RGB.ds);
undistorted = read(data.peaches.top.RGB.undistorted);
binary = read(data.peaches.top.binary);
smallObjectsRemoved = read(data.peaches.top.smallObjectsRemoved);
centers = read(data.peaches.top.centers);

figure;
subplot(2,2,1); imshow(original); title('original');
subplot(2,2,2); imshow(undistorted); title ('undistorted'); hold on;
for k = 1 : length(centers)
  thisBB = centers(k).BoundingBox;
  rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
  plot(centers(k).Centroid(1), centers(k).Centroid(2), 'rx', 'MarkerSize', 10);
end
reset(data.peaches.top.RGB.ds);
reset(data.peaches.top.RGB.undistorted);
reset(data.peaches.top.binary);
reset(data.peaches.top.smallObjectsRemoved);
reset(data.peaches.top.centers);

%% world points computation
all_centers_top = cell(length(data.peaches.top.RGB.ds.Files), 1);
all_worldPoints_top = cell(length(data.peaches.top.RGB.ds.Files), 1);
for useId = 1:length(data.peaches.top.RGB.ds.Files)
    all_centers_top{useId} = read(data.peaches.top.centers);
    if isempty(all_centers_top{useId})
        all_worldPoints_top{useId} = [];
    else
        loc = camPoses_top.Location{useId};
        ori = camPoses_top.Orientation{useId};
        [rot, transl] = cameraPoseToExtrinsics(ori, loc);
        centroid = cell2mat({all_centers_top{useId}.Centroid}');
        all_worldPoints_top{useId} = pointsToWorld(data.camParams_RGB.cameraParams, rot, transl, centroid);
    end
end
all_centers_bottom = cell(length(data.peaches.bottom.RGB.ds.Files), 1);
all_worldPoints_bottom = cell(length(data.peaches.bottom.RGB.ds.Files), 1);
for useId = 1:length(data.peaches.bottom.RGB.ds.Files)
    all_centers_bottom{useId} = read(data.peaches.bottom.centers);
    if isempty(all_centers_bottom{useId})
        all_worldPoints_bottom{useId} = [];
    else
        loc = camPoses_bottom.Location{useId};
        ori = camPoses_bottom.Orientation{useId};
        [rot, transl] = cameraPoseToExtrinsics(ori, loc);
        centroid = cell2mat({all_centers_bottom{useId}.Centroid}');
        all_worldPoints_bottom{useId} = pointsToWorld(data.camParams_RGB.cameraParams, rot, transl, centroid);
    end
end
save('centers_precomputed', 'all_centers_top', 'all_worldPoints_top', 'all_centers_bottom', 'all_worldPoints_bottom');
