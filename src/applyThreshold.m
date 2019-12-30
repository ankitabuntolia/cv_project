function y = applyThreshold(gray, thermal)
  %y = bitor(imbinarize(gray, 0.9), imbinarize(thermal, 0.123));
  y = imbinarize(gray, 0.9);
end
