function y = insertMarkers(imageWithCenters)
  y = imageWithCenters{2};
  if length(imageWithCenters) > 2
      centers = imageWithCenters{3};
      for i = 1 : length(centers)
          y = insertShape(y, 'Rectangle', centers(i).BoundingBox, 'LineWidth', 20, 'Color', 'blue');
      end
  end
end

