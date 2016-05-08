function out_image = HomographyTransform(image,output,outputSize)
out_image = double(zeros(outputSize));
for i=1:outputSize(1)
    for j=1:outputSize(2)
        temp = output*[i;j;1];
        temp = temp/(temp(3));
        out_image(i,j) = bilinear(image,temp(1),temp(2));
    end
end
end