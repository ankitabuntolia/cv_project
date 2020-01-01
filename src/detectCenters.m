function [peaches] = detectCenters(binary)
  %% detection method 1: find connected pixel regions (centers, bounding boxes and area)
  peaches = regionprops(binary, 'Centroid', 'BoundingBox', 'Area');

  %% WIP detection method 2: circular hough transform
%  [centers, radii, ~] = imfindcircles(openBW,[40*imgscale 120*imgscale]);
%  viscircles(centers, radii,'EdgeColor','b');

  %% WIP detection method 3: circular hough transform with other parametrization
%  [centers, radii, ~] = imfindcircles(openBW,[24*imgscale 60*imgscale]);
%  iscircles(centers, radii,'EdgeColor','r');

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
    %% put center coordinates (x,y) in separate cell array and rescale them for tracking with sfm
    elements = struct2cell(peaches')';
    centers_scaled = elements(:,2);
    centers = zeros(length(centers_scaled),2);

    for i = 1 : length(centers_scaled)
      x_new = interp1([1 6000], [1 6000], centers_scaled{i}(1,1));
      y_new = interp1([1 4000], [1 4000], centers_scaled{i}(1,2));
      centers(i,:) = [x_new, y_new];
    end
  else
    centers = [];
  end
end
