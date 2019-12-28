function y = reduceShadows(rgb)
    y = lab2rgb(rgb2lab(rgb) + 15);
end