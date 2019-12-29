
clear all; clc; close all;

%% loading one image

rgbpath = fullfile('.', 'data','top','RGB', 'DSC06220.JPG');
thermalpath = fullfile('.', 'data', 'top', 'thermal', '20190726_185902.tiff');
imgscale = .25;

rgb = imread(rgbpath);
rgb = imresize(rgb, imgscale);

figure(1)
imshow(rgb)
title('Original image')

% save original image 
original = rgb;


%% stretch red values
% stretch red values (from Lena)
gray_rgb = rgb2gray(original);
red_channel = original(:,:,1);
red_min = min(red_channel(:));
red_max = max(red_channel(:));
red_stretched = 255*((red_channel-red_min)/(red_max-red_min));
rgb_stretched = rgb;
rgb_stretched(:,:,1) = red_stretched;
figure;
imshow(rgb_stretched)

%% compute first "prohabilities" from stretching

proh_one = zeros(size(gray_rgb));
proh_one(2*rgb_stretched(:,:,1)-(rgb_stretched(:,:,2)+2*rgb_stretched(:,:,3))>50) = .25;
proh_one(2*rgb_stretched(:,:,1)-(rgb_stretched(:,:,2)+2*rgb_stretched(:,:,3))>80) = .5;
proh_one(2*rgb_stretched(:,:,1)-(rgb_stretched(:,:,2)+2*rgb_stretched(:,:,3))>105) = .75;
proh_one(2*rgb_stretched(:,:,1)-(rgb_stretched(:,:,2)+2*rgb_stretched(:,:,3))>130) = 1;
imshow(proh_one)


%% RGB adjust colors (makes peaches better visible) (Johanna)
gammas = [1 0.4 1];
rgb2 = imadjust(rgb,[.1 .1 0.3 ; .2 .5 1],[],gammas);
figure;
imshow(rgb2)

%% stretch red values
% stretch red values (from Lena)
%gray_rgb2 = rgb2gray(rgb2);
%red_channel2 = rgb2(:,:,1);
%red_min2 = min(red_channel2(:));
%red_max2 = max(red_channel2(:));
%red_stretched2 = 255*((red_channel2-red_min2)/(red_max2-red_min2));
%rgb_stretched2 = rgb2;
%rgb_stretched2(:,:,1) = red_stretched2;
%figure;
%imshow(rgb_stretched2)

%% compute second "prohabilities"

rgb_stretched2 = rgb2;
proh_two = zeros(size(gray_rgb2));
proh_two(rgb_stretched2(:,:,1)-(1.5*rgb_stretched2(:,:,2)+2*rgb_stretched2(:,:,3))>75) = .25;
proh_two(rgb_stretched2(:,:,1)-(1.5*rgb_stretched2(:,:,2)+2*rgb_stretched2(:,:,3))>95) = .5;
proh_two(rgb_stretched2(:,:,1)-(1.5*rgb_stretched2(:,:,2)+2*rgb_stretched2(:,:,3))>110) = .75;
proh_two(rgb_stretched2(:,:,1)-(1.5*rgb_stretched2(:,:,2)+2*rgb_stretched2(:,:,3))>130) = 1;
figure;
imshow(proh_two)


%% RGB to LAB (Johanna)

LAB = rgb2lab(rgb) + 10;
%figure; 
%imshow(LAB);
RGB = lab2rgb(LAB);
figure; 
imshow(RGB);
% here we get different rgb values

%% stretch red values (does not operate)
% stretch red values (from Lena)
gray_rgb3 = rgb2gray(RGB);
red_channel3 = RGB(:,:,1);
red_min3 = min(red_channel3(:));
red_max3 = max(red_channel3(:));
red_stretched3 = 255*((red_channel3-red_min3)/(red_max3-red_min3));
rgb_stretched3 = RGB;
rgb_stretched3(:,:,1) = red_stretched3;
figure;
imshow(rgb_stretched3)

%% compute third "prohabilities" 
% this approach with LAB works really well
proh_three = zeros(size(gray_rgb));
proh_three(1.1*RGB(:,:,1)-(RGB(:,:,2)+2*RGB(:,:,3))>0) = .25;
proh_three(1.1*RGB(:,:,1)-(RGB(:,:,2)+2*RGB(:,:,3))>.13) = .5;
proh_three(1.1*RGB(:,:,1)-(RGB(:,:,2)+2*RGB(:,:,3))>.2) = .75;
proh_three(1.1*RGB(:,:,1)-(RGB(:,:,2)+2*RGB(:,:,3))>.3) = 1;
imshow(proh_three)


%% resulting image of "prohabilities"

proh_mean = (proh_one + proh_two + proh_three) /3;

proh_res1 = zeros(size(proh_mean));
proh_res1(proh_mean(:,:) > 0.3) = 1;

figure;
imshow(proh_res1)

proh_weighted_mean = (0.2*proh_one + 0.2*proh_two + 0.6*proh_three);
proh_res2 = zeros(size(proh_mean));
proh_res2(proh_mean(:,:) > 0.3) = 1;

figure;
imshow(proh_res2)