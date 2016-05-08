function new_centers = get_new_center(histograms,centers)
    %% this function will take input as histograms and return all the new centers found
    num = size(histograms,1);
    % here centers are of size kx1 cells
    k = size(centers,1);
    new_centers = cell(k,1);
    new_points = cell(k,1); % to store all the histogram found in their corresponding positions 
    
    %% it will compute which will belong to which center and then solve and get the new center and return 
    % first get the points belong to the center
    for i = 1:num
        min = 100000000000;
        idx = 0;
        for j = 1:k
            %% match the point with all the centers and get the lowest
            n = get_distance(histograms{i},centers{j});
            if(n < min)
                min = n;
                idx = j;
            end
            
        end
        new_points{idx} = [new_points{idx}; histograms{i}'];
        % we are storing each histogram column wise ie horizontal
    end
    
    %% now we need to get the average to get the new centers and return that
    for i = 1:k
        % remember all are horizontal
        new_centers{i} = mean(new_points{i},1)';
        if(isempty(new_centers{i}))
            new_centers{i} = centers{i};
        end
    end
    
end