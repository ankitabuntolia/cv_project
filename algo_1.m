clear all; clc; close all;

%% loading data
[rgbds_top, thermalds_top] = load_data(true);
[rgbds_bottom, thermalds_bottom] = load_data(false);

%% 

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
    rgbImgs = 
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

function undistortPairs(dirRGB, dirThermal)
    for i = 1:length(dirRGB.Files)
        rgb = undistortImage( readimage( dirRGB, i ), rgbParams.cameraParams );
        thermal = undistortImage( readimage( dirThermal, i ), thermalParams.cameraParams );

        figure(i); clf;
        subplot(2,1,1); imshow( rgb ); title( 'RGB' );
        subplot(2,1,2); imshow( thermal, [] );  title ( 'thermal' );
        colormap( 'parula' );
        drawnow;
    end
end