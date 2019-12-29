function y = calibrate(thermal, tform, outputView)
  y = imwarp(thermal, tform, 'OutputView', outputView);
end
