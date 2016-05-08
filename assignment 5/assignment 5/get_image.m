function im = get_image(image)
    
    new_new_image = zeros(size(image));
    m = max(max(image));
    x = 0;
    for i = 1:m
        new_image = image;
        new_image(new_image ~= i) = 0;
        new_image(new_image ~= 0) = 1;
%% we got now we need to get the connected components and also label them 
        [label_image,num] = bwlabel(new_image);
        new_new_image = new_new_image + (label_image + x * new_image);
        x = x + num;
    end
    %% done here now we need to assign color to each image 
    m = max(max(new_new_image));
    num = ceil(nthroot(m, 3));
    R = uint8(zeros(size(image)));
    G = uint8(zeros(size(image)));
    B = uint8(zeros(size(image)));
    r = uint8(randi(255,num,1));
    idx = 1;
    for i = 1:num
        for j = 1:num
            for k = 1:num
                
                R(new_new_image == idx) = r(i);
                G(new_new_image == idx) = r(j);
                B(new_new_image == idx) = r(k);
                idx = idx + 1;
            end
        end
    end
    im = cat(3,R,G,B);
end