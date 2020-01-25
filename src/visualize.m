function y = visualize(image, centers)
  y = image;
  for i = 1:size(centers, 1)
    y = insertShape(y, 'Circle', [centers(i, 1), centers(i, 2), 100], 'LineWidth', 20, 'Color', 'red');
  end
end
