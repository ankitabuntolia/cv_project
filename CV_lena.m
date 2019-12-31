%% cleaning up
clear all; clc; close all;

%% detection part:
%% loading camera params
rgbParams = load( './data/camParams_RGB.mat' );
cameraParams = rgbParams.cameraParams; % intrinsic parameters of rgb camera

%% top row
rgbpath = './data/peaches/top/RGB';
rgbds = datastore( rgbpath );

all_centers_top = cell(length(rgbds.Files),1);
for useId = 1:length(rgbds.Files)
    all_centers_top{useId} = detect_peaches(useId, rgbds, cameraParams, true, 2);
end

%% bottom row
rgbpath = './data/peaches/bottom/RGB';
rgbds = datastore( rgbpath );

all_centers_bottom = cell(length(rgbds.Files),1);
for useId = 1:length(rgbds.Files)
    all_centers_bottom{useId} = detect_peaches(useId, rgbds, cameraParams, true, 1);
end

%% tracking part:
%% calculate worldPoints of peaches for comparison
centers = all_centers_top{8};
[worldPoints] = centers_to_world_points(useId, rgbds, cameraParams, centers);

%% for testing projections draw world points of peaches from one img to another
draw_peach_centers_in_img(useId, rgbds, cameraParams, worldPoints);

%% functions for my first tracking ideas
% WARNING! something's off with calculation of worldPoints or the inverse (or both), 
% because the reprojection only works into the same image (which isn't useful at all)

% function calculating world points from image points of image with id
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

% function drawing world coordinate points into image with id "useId"
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

% function detecting peaches and returning array with image coordinates of
% centers
function [centers] = detect_peaches(useId, rgbds, cameraParams, showResults, threshold_function)
    %% undistort image
    rgb = undistortImage(readimage(rgbds, useId), cameraParams);

    %% if necessary scale images
    imgscale = .25;
    rgb = imresize(rgb, imgscale);

    %% binarization with generated matlab color thresholding function
    switch threshold_function
        case 1
            [bw, ~] = createMask(rgb);
        case 2
            [bw, ~] = createMask2(rgb);
    end

    %% performing image close and open operation to remove branches
    se = strel('disk',12*imgscale);
    closeBW = imclose(bw, se);
    se2 = strel('disk',20*imgscale);
    openBW = imopen(closeBW, se2);
    
    %% showing morphological operations
    if showResults
        figure('Name',['Morphological operations img ', num2str(useId)]);
        subplot(1,2,1);
        imshow( closeBW );
        title('Closed BW')
        subplot(1,2,2);
        imshow( openBW );
        title('Opened BW')
    end
    
    %% showing original image with results
    if showResults
        figure('Name',['Results img ', num2str(useId)])
        subplot(1,2,1);
        imshow(rgb);
        title('Original image')
        subplot(1,2,2);
        imshow(rgb); hold on;
        title('Results')
    end

    %% detection method 1: find connected pixel regions (centers, bounding boxes and area)
    peaches = regionprops(openBW, 'Centroid', 'BoundingBox', 'Area');

    %% WIP detection method 2: circular hough transform
%     [centers, radii, ~] = imfindcircles(openBW,[40*imgscale 120*imgscale]);
%     viscircles(centers, radii,'EdgeColor','b');

    %% WIP detection method 3: circular hough transform with other parametrization
%     [centers, radii, ~] = imfindcircles(openBW,[24*imgscale 60*imgscale]);
%     viscircles(centers, radii,'EdgeColor','r');

    %% Hough transform detection doesn't improve results
    %% new approach: check with geometric information of border boxes if peach was detected twice
    measurements = peaches;
    
    f = fieldnames(measurements)';
    f{2,1} = {};
    peaches = struct(f{:});
    
    idx = 1;
    for k = 1 : length(measurements)
        thisBB = measurements(k).BoundingBox;
        addPeach = true;
        
        % look for bounding boxes of certain maximum size
        if thisBB(3) <= 12 && thisBB(4) <= 12
            % if bounding box is small enough, look for near centroid in
            % already added data
            for i = 1: length(measurements)
                if k ~= i
                    distanceX = abs(measurements(k).Centroid(1) - measurements(i).Centroid(1));
                    distanceY = abs(measurements(k).Centroid(2) - measurements(i).Centroid(2));
                    distance = sqrt(distanceX^2 + distanceY^2);
                    % add only if no other center is far away enough
                    if distance < 20
                        addPeach = false;
                    end
                end
            end
        end
        
        if addPeach
            peaches(idx) = measurements(k);
            idx = idx+1;
        end
    end
    
    if ~isempty(peaches)
        %% print peaches centers with bounding boxes
        for k = 1 : length(peaches)
            thisBB = peaches(k).BoundingBox;
            rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
            plot( peaches(k).Centroid(1), peaches(k).Centroid(2), 'rx', 'MarkerSize', 10);
        end

        %% put center coordinates (x,y) in separate cell array and rescale them for tracking with sfm
        elements = struct2cell(peaches')';
        centers_scaled = elements(:,2);
        centers = zeros(length(centers_scaled),2);

        for i = 1 : length(centers_scaled)
            x_new = interp1([1 6000*imgscale], [1 6000], centers_scaled{i}(1,1));
            y_new = interp1([1 4000*imgscale], [1 4000], centers_scaled{i}(1,2));
            centers(i,:) = [x_new, y_new];
        end
    else
        centers = [];
    end
end