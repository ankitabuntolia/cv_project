function [all_peaches_tracked, peachcount] = tracking(intrinsics, camPoses, xyzPoints, all_centers, dist, k_class, all_BB)

% all_centers like the datastructure of main_tracking
% all_centers_top.Centroid{Id} gives us the centers of peaches for image Id
% e.g. all_centers is the same as all_centers_top.Centroid
    
    all_peaches_tracked = cell(length(all_centers),1);
    
    indx = 1; 
    while isempty(all_centers{indx})
        indx = indx + 1;
    end
    
    all_peaches = toWorld(intrinsics, camPoses, indx, all_centers{indx}, xyzPoints, k_class, all_BB{indx});
    all_peaches_tracked{indx} = all_centers{indx};
    peachcount = size(all_peaches,1);
    indx = indx + 1;
    
    for j=indx:size(all_centers,1)
        % imagej_world  refers to all xyz-coordinates of the centers of
        % image j
        
        centers_j_world = toWorld(intrinsics, camPoses, j, all_centers{j}, xyzPoints, k_class, all_BB{j});
        
        p = 0;
        all_peaches_copy = all_peaches;
        
        for k=1:size(centers_j_world,1)
            peach = centers_j_world(k,:);
            
            if isempty(all_peaches_copy)
                peachcount = peachcount + 1;
                p = p + 1;
                all_peaches(peachcount,:) = peach;
                all_peaches_tracked{j}(p,:) = all_centers{j}(k,:);
                continue
            end
            
            [mindist, indx_peach] = distance(peach, all_peaches_copy);
            mindist;
            
            if mindist > dist
                peachcount = peachcount + 1;
                p = p + 1;
                all_peaches(peachcount,:) = peach;
                all_peaches_tracked{j}(p,:) = all_centers{j}(k,:);
                continue
            end
            
            all_peaches_copy(indx_peach,:) = [];
        end
        
    end
end