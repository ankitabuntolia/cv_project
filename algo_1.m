clear all; clc; close all;

%% loading data
[rgbds_top, thermalds_top] = load_data(true);
[rgbds_bottom, thermalds_bottom] = load_data(false);

%% overlay thermal and rgb images
% calibrate mapping of RGB<->thermal with checkerboard
calibrgbpath = './data/peaches/calibration/RGB';
calibthermalpath = './data/peaches/calibration/thermal';
calibrgbds = datastore( calibrgbpath );
calibthermalds = datastore( calibthermalpath );

rgb = undistortImage( readimage( calibrgbds, 1 ), rgbParams.cameraParams );
[rgb_imagePoints,rgb_boardSize,rgb_imagesUsed] = detectCheckerboardPoints(rgb);
thermal = undistortImage(readimage( calibthermalds, 1 ), thermalParams.cameraParams );
thermal = 255 - thermal; % invert so that it matches the RGB colors
[thermal_imagePoints,thermal_boardSize,thermal_imagesUsed] = detectCheckerboardPoints(thermal);
assert( isequal( thermal_boardSize, rgb_boardSize ) );

% estimate 2D transformation (for imwarp)
tform = fitgeotrans(rgb_imagePoints,thermal_imagePoints,'projective');
warpedthermal = imwarp(thermal,tform.invert(),'OutputView',imref2d(size(rgb)));
figure(); clf;
imshowpair( rgb, warpedthermal, 'falsecolor' ); title( 'original RGB, warped thermal' );

% estimate extrinsics
squareSize = 50;  % 'millimeters'
worldPoints = generateCheckerboardPoints(thermal_boardSize, squareSize);
[thermal_rotation,thermal_transl] = extrinsics(thermal_imagePoints,worldPoints,thermalParams.cameraParams);
[rgb_rotation, rgb_transl] = extrinsics(rgb_imagePoints,worldPoints,rgbParams.cameraParams);

% relative transformation (rotation + translation) from RGB to thermal
R = rgb_rotation' * thermal_rotation;
t = thermal_transl - rgb_transl * R;
% save:
if ~exist( 'results', 'dir' ), mkdir( 'results' ); end
save( './results/rgb2thermal_transf.mat', 'R', 't' );

worldPoints3D = worldPoints;
worldPoints3D(:,3) = 0;
% reproject RGB
rgb_reproj = worldToImage( rgbParams.cameraParams, rgb_rotation, rgb_transl, worldPoints3D );
% reproject on RGB with thermal transformations
thermal2rgb_reproj = worldToImage( rgbParams.cameraParams, thermal_rotation*R', (thermal_transl-t)*R', worldPoints3D );

% estimate transformation from extrinsics (for imwarp)
z = 900; % millimeters
% the checkerboard is ~900 millimeters away
% the tree in the background is ~100000 millimeters (100 m)
P = (inv(rgbParams.cameraParams.IntrinsicMatrix) * R * thermalParams.cameraParams.IntrinsicMatrix ); 
P_transl = (t * thermalParams.cameraParams.IntrinsicMatrix);
P_ = P; % copy
P_(3,:) = P_(3,:) + P_transl./z; % add translation
tform = projective2d( P_ );

% warp thermal on RGB
warpedthermal = imwarp(thermal,tform.invert(),'OutputView',imref2d(size(rgb)));
figure(); clf;
imshowpair( rgb, warpedthermal, 'falsecolor' ); title( 'original RGB, warped thermal' );


%% functions
function [rgbds, thermalds] = load_data(top)
    if top
        rgbpath = './data/peaches/top/RGB';
        thermalpath = './data/peaches/top/thermal'; 
    else
        rgbpath = './data/peaches/bottom/RGB';
        thermalpath = './data/peaches/bottom/thermal'; 
    end
        
    rgbds = datastore( rgbpath );
    thermalds = datastore( thermalpath );
    assert( length(rgbds.Files) == length(thermalds.Files) );
end

function loadCamParams()
    rgbParams = load( './data/camParams_RGB.mat' );
    thermalParams = load( './data/camParams_thermal.mat' );
end

function [rbgImgs, thermalImgs] = loadImgPairs(dirRGB, dirThermal)
    rgbImgs = cell(length(dirRGB.Files));
    thermalImgs = cell(length(dirRGB.Files));
    for i = 1:length(dirRGB.Files)
        rbgImgs(i) = readimage( dirRGB, i );
        thermalImgs(i) = readimage( dirThermal, i );
    end
end

function displayPairs(rbgImgs, thermalImgs)
    for i = 1:length(rbgImgs)
        figure(i); clf;
        subplot(2,1,1); imshow( rbgImgs(i) ); title( 'RGB' );
        subplot(2,1,2); imshow( thermalImgs(i), [] ); title ( 'thermal' );
        drawnow;
    end
end

function [undist_rgbImgs, undist_thermalImgs] = undistortPairs(rgbImgs, thermalImgs)
    undist_rgbImgs = cell(length(dirRGB.Files));
    undist_thermalImgs = cell(length(dirRGB.Files));
    for i = 1:length(dirRGB.Files)
        undist_rgbImgs(i) = undistortImage( rgbImgs(i), rgbParams.cameraParams );
        undist_thermalImgs(i) = undistortImage( thermalImgs(i), thermalParams.cameraParams );
    end
end