function y = removeSmallObjects(binary)
    y = bwareaopen(binary, 5000);
end