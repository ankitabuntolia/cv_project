%% cleaning up
clear all; clc; close all;

%% loading data: rgb, camera params and sfm data
rgbpath = './data/peaches/top/RGB';
rgbParams = load( './data/camParams_RGB.mat' );
load('./data/sfm_top.mat');

%% load images to datastore
rgbds = datastore( rgbpath );
thermalds = datastore( thermalpath );

%% id of image to work with
useId = 8;

%% intrinsic parameters of rgb camera
cameraParams = rgbParams.cameraParams;

%% undistort image
rgb = undistortImage(readimage(rgbds, useId), cameraParams);

%% if necessary scale images
imgscale = 1;%.25;
rgb = imresize(rgb, imgscale);

%% showing original image
figure(1)
imshow(rgb)
title('Original image')

%% binarization with generated matlab color thresholding function
[bw, maskedRGBImage] = createMask(rgb);

%% performing image close and open operation to remove branches
se = strel('disk',3/0.25*imgscale);
closeBW = imclose(bw, se);
figure(1);
imshow(closeBW);
se2 = strel('disk',5/0.25*imgscale);
openBW = imopen(closeBW, se2);
imshow(openBW); hold on;

%% WIP detection method 1: find connected pixel regions (centers, bounding boxes and area)
peaches = regionprops(openBW, 'Centroid', 'BoundingBox', 'Area');

%% WIP detection method 2: circular hough transform
[centers, radii, metric] = imfindcircles(openBW,[10 30]);
viscircles(centers, radii,'EdgeColor','b');

%% WIP detection method 3: circular hough transform with other parametrization
[centers, radii, metric] = imfindcircles(openBW,[5 30]);
viscircles(centers, radii,'EdgeColor','r');

%% WIP combining info of 3 detection approaches

%% print peaches centers with bounding boxes
for k = 1 : length(peaches)
    thisBB = peaches(k).BoundingBox;
    rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
    plot( peaches(k).Centroid(1), peaches(k).Centroid(2), 'rx', 'MarkerSize', 10);
end

%% put center coordinates (x,y) in separate cell array
elements = struct2cell(peaches)';
centers = elements(:,2);

%% tracking part:
%% compare worldPoints of peaches
[centers1, worldPoints1] = find_peaches(7, rgbds, cameraParams, imgscale);
[centers2, worldPoints2] = find_peaches(8, rgbds, cameraParams, imgscale);

%% for testing projections draw world points of peaches from one img to another
draw_peach_centers_in_img(8, rgbds, cameraParams, worldPoints2);

%% functions encapsulating most of the code from above + my first tracking ideas
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
    I = undistortImage( readimage(rgbds, useId), cameraParams );
	%% convert center world points back to image points to mark the peaches on the selected image
    imshow( I ); hold on; title( 'reproject precomputed RGB points' );
    for i = 1 : length(worldPoints)
        reproj = worldToImage( cameraParams, rot, transl, worldPoints(i,:) );
        scatter( reproj(:,1), reproj(:,2), 80, 'rx');
    end
    drawnow;
end

function [centers, worldPoints] = find_peaches(useId, rgbds, cameraParams, imgscale)
	%% loading sfm data
    load('./data/sfm_top.mat');
	%% assert that correct sfm data is used for loaded img (see sfm scripts from lab for reference)
    [filepath,name,ext] = fileparts(rgbds.Files{useId});
    assert( isequal(imagenames{useId},[name,ext]) );
	%% minimal version of detection algorithm from above
    rgb = undistortImage(readimage(rgbds, useId), cameraParams);
    [bw, ~] = createMask(rgb);
    se = strel('disk',3/0.25*imgscale);
    closeBW = imclose(bw, se);
    se2 = strel('disk',5/0.25*imgscale);
    openBW = imopen(closeBW, se2);
    peaches = regionprops(openBW, 'Centroid', 'BoundingBox', 'Area');
	
	%% put center coordinates (x,y) in separate cell array
    elements = struct2cell(peaches)';
    centers = elements(:,2);
    
	%% using camera poses from sfm data to get rotation and translation
    camPoses = poses(vSet);
    loc = camPoses.Location{useId};
    ori = camPoses.Orientation{useId};
    [rot, transl] = cameraPoseToExtrinsics( ori, loc );
	%% calculate world coordinates for each detected center and store into array -> doesn't work correctly yet!!
    worldPoints = zeros(length(centers), 3);
    for i = 1 : length(centers)
        pt = [centers{i}(1), centers{i}(2)];
        worldPoint = pointsToWorld(cameraParams,rot,transl,pt);
        worldPoints(i,:) = [worldPoint(1), worldPoint(2), 0];
    end
end