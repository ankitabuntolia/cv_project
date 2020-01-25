%% function for finding double peaches

function [xyz_centers] = toWorld(intrinsics, camPoses, useId, centers_Id, xyzPoints, k_class, BB_Id)

    newCamParams = cameraParameters( 'IntrinsicMatrix', intrinsics.IntrinsicMatrix );
    [rot, trans] = cameraPoseToExtrinsics( camPoses.Orientation{useId}, camPoses.Location{useId} );

    reprojPoints = worldToImage( newCamParams, rot, trans, xyzPoints );
    
    xyz_centers = zeros(size(centers_Id,1), 3);
    
    for i=1:size(centers_Id,1)
        rad = norm(BB_Id(i,3:4));
        center = centers_Id(i,:);
        
        diff = reprojPoints - center;
        dist = sqrt(diff(:,1).^2 + diff(:,2).^2);
        
        for j=1:k_class
            [minval, minindx_arr(j)] = min(dist);
            dist(minindx_arr(j)) = rad; % the maximal distance 
            
            if minval >= rad
                break
            end
        end
        
        sum_pts = zeros(1,3);
        minindx_arr_unique = unique(minindx_arr,'first');
        %length(minindx_arr_unique)
        % could be used to check how many points are available in sfm
        
        for j=1:size(minindx_arr_unique,2)
            pt = xyzPoints(minindx_arr_unique(j),:);
            sum_pts = sum_pts + pt;
        end
        
        xyz_centers(i,:) = sum_pts/size(minindx_arr_unique,2);
    end
end