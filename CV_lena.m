%% cleaning up
clear all; clc; close all;

%% loading data: rgb, camera params and sfm data
rgbpath = './data/peaches/top/RGB';
rgbParams = load( './data/camParams_RGB.mat' );
load('./data/sfm_top.mat');

%% load images to datastore
rgbds = datastore( rgbpath );

%% id of image to work with
useId = 8;

%% intrinsic parameters of rgb camera
cameraParams = rgbParams.cameraParams;

%% undistort image
rgb = undistortImage(readimage(rgbds, useId), cameraParams);

%% if necessary scale images
imgscale = .25;
rgb = imresize(rgb, imgscale);

%% showing original image
figure(1)
imshow(rgb)
title('Original image')

%% binarization with generated matlab color thresholding function
[bw, maskedRGBImage] = createMask(rgb);

%% performing image close and open operation to remove branches
se = strel('disk',12*imgscale);
closeBW = imclose(bw, se);
imshow(closeBW);
se2 = strel('disk',20*imgscale);
openBW = imopen(closeBW, se2);
figure(2);
imshow(openBW); hold on;

%% WIP detection method 1: find connected pixel regions (centers, bounding boxes and area)
peaches = regionprops(openBW, 'Centroid', 'BoundingBox', 'Area');

%% WIP detection method 2: circular hough transform
[centers, radii, ~] = imfindcircles(openBW,[40*imgscale 120*imgscale]);
viscircles(centers, radii,'EdgeColor','b');

%% WIP detection method 3: circular hough transform with other parametrization
[centers, radii, ~] = imfindcircles(openBW,[20*imgscale 120*imgscale]);
viscircles(centers, radii,'EdgeColor','r');

%% WIP combining info of 3 detection approaches

%% print peaches centers with bounding boxes
for k = 1 : length(peaches)
    thisBB = peaches(k).BoundingBox;
    rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
    plot( peaches(k).Centroid(1), peaches(k).Centroid(2), 'rx', 'MarkerSize', 10);
end

%% put center coordinates (x,y) in separate cell array and rescale them for tracking with sfm
elements = struct2cell(peaches)';
centers_scaled = elements(:,2);
centers = zeros(length(centers_scaled),2);

for i = 1 : length(centers_scaled)
    x_new = interp1([1 6000*imgscale], [1 6000], centers_scaled{i}(1,1));
    y_new = interp1([1 4000*imgscale], [1 4000], centers_scaled{i}(1,2));
    centers(i,:) = [x_new, y_new];
end

%% tracking part:
%% compare worldPoints of peaches
[worldPoints] = centers_to_world_points(useId, rgbds, cameraParams, centers);

%% for testing projections draw world points of peaches from one img to another
draw_peach_centers_in_img(useId, rgbds, cameraParams, worldPoints);

%% functions for my first tracking ideas
function [worldPoints] = centers_to_world_points(useId, rgbds, cameraParams, centers)
    %% loading sfm data
    load('./data/sfm_top.mat');
	%% assert that correct sfm data is used for loaded img (see sfm scripts from lab for reference)
    [filepath,name,ext] = fileparts(rgbds.Files{useId});
    assert( isequal(imagenames{useId},[name,ext]) );
    
	%% using camera poses from sfm data to get rotation and translation
    camPoses = poses(vSet);
    loc = camPoses.Location{useId};
    ori = camPoses.Orientation{useId};
    [rot, transl] = cameraPoseToExtrinsics( ori, loc );
    
	%% calculate world coordinates for each detected center and store into array -> doesn't work correctly yet!!
    worldPoints = [pointsToWorld(cameraParams,rot,transl,centers) zeros(length(centers), 1)];
end

function draw_peach_centers_in_img(useId, rgbds, cameraParams, worldPoints)
	%% loading sfm data
    load('./data/sfm_top.mat');
	%% assert that correct sfm data is used for loaded img (see sfm scripts from lab for reference)
    [filepath,name,ext] = fileparts(rgbds.Files{useId});
    assert( isequal(imagenames{useId},[name,ext]) );
	%% using camera poses from sfm data to get rotation and translation
    camPoses = poses(vSet);
    loc = camPoses.Location{useId};
    ori = camPoses.Orientation{useId};
    [rot, transl] = cameraPoseToExtrinsics( ori, loc );
    reprojPoints = worldToImage( cameraParams, rot, transl, xyzPoints );
    I = undistortImage( readimage(rgbds, useId), cameraParams );
	%% convert center world points back to image points to mark the peaches on the selected image
    imshow( I ); hold on; title( 'reproject precomputed RGB points' );
    scatter( reprojPoints(:,1), reprojPoints(:,2), 1, double(rgbPoints)./255, 'filled' );
    for i = 1 : length(worldPoints)
        reproj = worldToImage( cameraParams, rot, transl, worldPoints(i,:) );
        scatter( reproj(:,1), reproj(:,2), 80, 'rx');
    end
    drawnow;
end