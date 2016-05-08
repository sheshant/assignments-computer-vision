function histogram = get_normalized_histogram(image,keys,values)
%% this function will first take the image and map and get the final histogram
    dim = size(keys,1);
    histogram = zeros(dim+359,1);
    % now get the image matrixof angles 
    matrix = get_matrix(image);
    % now iterate through all elements
    row = size(image,1);
    col = size(image,2);
    for i = 1:row
    	for j = 1:col
            temp = abs(keys - matrix(i,j));
            [~,idx] = min(temp);
            histogram(values(idx)) = histogram(values(idx))+1;
        end
    end
    histogram = histogram/(row*col);
end