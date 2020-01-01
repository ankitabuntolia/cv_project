function [binary] = applyThreshold(rgb, threshold_function)
  %% binarization with generated matlab color thresholding function
  switch threshold_function
    case 1
      [binary, ~] = createMask(rgb);
    case 2
      [binary, ~] = createMask2(rgb);
  end
end