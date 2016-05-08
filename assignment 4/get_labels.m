function labels = get_labels(k,histograms)
%% this function will take the histograms and label it that it belong to which cluster 
% number of clusters is given by k
    labels = zeros(k,1);
    centers = cell(k,1);
    new_centers = cell(k,1);
    num = size(histograms,1);
    h = cell2mat(histograms');
    center = mean(h,2);
    dev = std(h,0,2);
    
    %% we got the mean and deviation
    % now get the normal distribution 
    for i = 1:k;
        centers{i} = normrnd(center,dev);
        new_centers{i} = zeros(size(centers{i}));
    end
    
    %% there is no do while loop in matlab
    new_centers = get_new_center(histograms,centers);
    
    %% good we get the new centers and now we need to get the new centers
    while( ~(isequal(cell2mat(centers),cell2mat(new_centers))))
        centers = new_centers;
        new_centers = get_new_center(histograms,centers);
        % update centers also you idiot
    end
    
    %% cool we got the new final centers now we need to assign each label 
    %     using for loop
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
        labels(i) = idx;
    end
end 
