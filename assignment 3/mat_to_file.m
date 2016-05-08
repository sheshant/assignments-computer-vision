function mat_to_file(matrix,fileID)
    row = size(matrix,1);
    col = size(matrix,2);
    for i = 1:row
        for j = 1:col
            fprintf(fileID,' %f ',matrix(i,j));
        end
        fprintf(fileID,'\n ');
    end
    fprintf(fileID,'\n');
end