function y = applyThreshold(gray, thermal)
  y = bitor(imbinarize(gray, 'adaptive'), imbinarize(thermal, 'adaptive'));
end
