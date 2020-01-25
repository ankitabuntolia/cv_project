function [mindist, indx] = distance(xyz_center, new_xyz_centers)
    
    diff = new_xyz_centers - xyz_center;
    dist = sqrt(diff(:,1).^2 + diff(:,2).^2 + diff(:,3).^2);
    [mindist, indx] = min(dist);
end