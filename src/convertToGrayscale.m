function y = convertToGrayscale(rgb)
    y = 3 * rgb(:,:,1) - 3 * rgb(:,:,2) - rgb(:,:,3);
end