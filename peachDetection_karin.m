clc; clear; close all;
workspace;	% Make sure the workspace panel is showing.
ver % Display user's toolboxes in their command window.

figure;
set(gcf, 'Position', get(0, 'ScreenSize'));
fontSize = 16;
originalFolder = pwd;
folder = 'C:\Users\karin\Documents\JKU Artificial Intelligence\1. Semester\Computer Vision\Projekt\cv_project';
if ~exist(folder, 'dir')
    folder = pwd;
end
cd(folder);
[baseFileName, folder] = uigetfile('*.*', 'Specify an image file');
fullImageFileName = fullfile(folder, baseFileName);
cd(originalFolder);
selectedImage = 'My own image';

[rgbImage storedColorMap] = imread(fullImageFileName);
[rows columns numberOfColorBands] = size(rgbImage);

if strcmpi(class(rgbImage), 'uint8')
    % Flag for 256 gray levels.
    eightBit = true;
else
    eightBit = false;
end
if numberOfColorBands == 1
    if isempty(storedColorMap)
        rgbImage = cat(3, rgbImage, rgbImage, rgbImage);
    else
        rgbImage = ind2rgb(rgbImage, storedColorMap);
        if strcmpi(class(rgbImage), 'uint8')
            rgbImage = uint8(255 * rgbImage);
        end
    end
end

redBand = rgbImage(:, :, 1);
greenBand = rgbImage(:, :, 2);
blueBand = rgbImage(:, :, 3);

[countsR, grayLevelsR] = imhist(redBand);
maxGLValueR = find(countsR > 0, 1, 'last');
maxCountR = max(countsR);
bar(countsR, 'r');

[countsG, grayLevelsG] = imhist(greenBand);
maxGLValueG = find(countsG > 0, 1, 'last');
maxCountG = max(countsG);

[countsB, grayLevelsB] = imhist(blueBand);
maxGLValueB = find(countsB > 0, 1, 'last');
maxCountB = max(countsB);

maxGL = max([maxGLValueR,  maxGLValueG, maxGLValueB]);
if eightBit
    maxGL = 255;
end
maxCount = max([maxCountR,  maxCountG, maxCountB]);

redThresholdLow = graythresh(redBand);
redThresholdHigh = 255;
greenThresholdLow = 0;
greenThresholdHigh = graythresh(greenBand);
blueThresholdLow = 0;
blueThresholdHigh = graythresh(blueBand);
if eightBit
    redThresholdLow = uint8(redThresholdLow * 255);
    greenThresholdHigh = uint8(greenThresholdHigh * 255);
    blueThresholdHigh = uint8(blueThresholdHigh * 255);
end

redMask = (redBand >= redThresholdLow+25) & (redBand <= redThresholdHigh);
greenMask = (greenBand >= greenThresholdLow) & (greenBand <= greenThresholdHigh);
blueMask = (blueBand >= blueThresholdLow) & (blueBand <= blueThresholdHigh);

redObjectsMask = uint8(redMask & greenMask & blueMask);
imshow(redObjectsMask);

smallestAcceptableArea = 200;
redObjectsMask = uint8(bwareaopen(redObjectsMask, smallestAcceptableArea));
imshow(redObjectsMask);

structuringElement = strel('disk', 4);
redObjectsMask = imclose(redObjectsMask, structuringElement);

redObjectsMask = uint8(imfill(redObjectsMask, 'holes'));
imshow(redObjectsMask, []);
title('Regions Filled', 'FontSize', fontSize);

redObjectsMask = cast(redObjectsMask, class(redBand));

maskedImageR = redObjectsMask .* redBand;
maskedImageG = redObjectsMask .* greenBand;
maskedImageB = redObjectsMask .* blueBand;
% imshow(maskedImageR);
% title('Masked Red Image', 'FontSize', fontSize);

% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
% Show masked original image
% imshow(maskedRGBImage);
% imshow(rgbImage);