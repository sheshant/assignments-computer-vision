function d = get_distance(a,b)
%% this function will get the equilidian distance between both the a and b
    % first check whether size is same or not
    if(size(a) ~= size(b))
        fprintf('size not same for a and b\n');
        display(size(a));
        display(size(b));
        d = [];
    else
        %% get the equilidian distance by getting the norm
        d = norm(a - b);
    end
end