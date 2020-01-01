function y = removeSmallObjects(binary)
  %% performing image close and open operation to remove branches
  se = strel('disk', 12);
  closeBW = imclose(binary, se);
  se2 = strel('disk', 20);
  y = imopen(closeBW, se2);
end
