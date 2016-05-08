function display_matrix(fileID,m,s)
    % it will display matrix in the corresponding file ID
    row = size(m,1);
    col = size(m,2);
    fprintf(fileID,'\n');
    fprintf(fileID,s);
    fprintf(fileID,'\n\n');
    for i = 1:row
        for j = 1:col
            fprintf(fileID,'%d  ',m(i,j));
        end
        fprintf(fileID,'\n');
    end
    fprintf(fileID,'\n\n');
end