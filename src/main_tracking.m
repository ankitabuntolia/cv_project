clear all; clc; close all;

%% loading data
% Load either top or bottom. There are variable name collisions in the two
% files, so loading both will overwrite some variables.
load('../data/sfm_top.mat');
%load('../data/sfm_top.mat');
load('centers_precomputed');

%% extract variables
% This section is not really necessary. It simply transforms the data into
% another representation to simplify access for the tracking.
all_centers_top_Area = cell(length(all_centers_top), 1);
all_centers_top_Centroid = cell(length(all_centers_top), 1);
all_centers_top_BoundingBox = cell(length(all_centers_top), 1);

for useId = 1:length(all_centers_top)
    if isempty(all_centers_top{useId})
        all_centers_top_Area{useId} = [];
        all_centers_top_Centroid{useId} = [];
        all_centers_top_BoundingBox{useId} = [];
   else
       all_centers_top_Area{useId} = cell2mat({all_centers_top{useId}.Area}');
       all_centers_top_Centroid{useId} = cell2mat({all_centers_top{useId}.Centroid}');
       all_centers_top_BoundingBox{useId} = cell2mat({all_centers_top{useId}.BoundingBox}');
    end
end

all_centers_bottom_Area = cell(length(all_centers_bottom), 1);
all_centers_bottom_Centroid = cell(length(all_centers_bottom), 1);
all_centers_bottom_BoundingBox = cell(length(all_centers_bottom), 1);

for useId = 1:length(all_centers_bottom)
    if isempty(all_centers_bottom{useId})
        all_centers_bottom_Area{useId} = [];
        all_centers_bottom_Centroid{useId} = [];
        all_centers_bottom_BoundingBox{useId} = [];
   else
       all_centers_bottom_Area{useId} = cell2mat({all_centers_bottom{useId}.Area}');
       all_centers_bottom_Centroid{useId} = cell2mat({all_centers_bottom{useId}.Centroid}');
       all_centers_bottom_BoundingBox{useId} = cell2mat({all_centers_bottom{useId}.BoundingBox}');
    end
end

%% TODO tracking
% Implement the tracking part here, either for top or bottom. All detected
% peaches are accessible from the all_centers_* variables. Following are
% examples how to use the data for the top peaches.

% get x, y coordinates of all peaches in picture 8
picture = 8;
for peach = 1:length(all_centers_top_Centroid{picture})
   Centroid_x = all_centers_top_Centroid{picture}(peach, 1);
   Centroid_y = all_centers_top_Centroid{picture}(peach, 2);
end

% get bounding boxes of all peaches in picture 8
picture = 8;
for peach = 1:length(all_centers_top_Centroid{picture})
   BoundingBox_ul_corner_x = all_centers_top_BoundingBox{picture}(peach, 1);
   BoundingBox_ul_corner_y = all_centers_top_BoundingBox{picture}(peach, 2);
   BoundingBox_width_x = all_centers_top_BoundingBox{picture}(peach, 3);
   BoundingBox_width_y = all_centers_top_BoundingBox{picture}(peach, 4);
end

% get areas of all peaches in picture 8
picture = 8;
for peach = 1:length(all_centers_top_Centroid{picture})
   Area = all_centers_top_Area{picture}(peach);
end

