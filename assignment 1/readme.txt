g++ -std=c++11 -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L/usr/local/lib/ -g -o binary Source.cpp -lopencv_shape -lopencv_stitching -lopencv_objdetect -lopencv_superres -lopencv_videostab -lopencv_calib3d -lopencv_features2d -lopencv_highgui -lopencv_videoio -lopencv_imgcodecs -lopencv_video -lopencv_photo -lopencv_ml -lopencv_imgproc -lopencv_flann -lopencv_core -lboost_iostreams -lboost_system -lboost_filesystem

./binary

run these 2 commands and you will see all windows having the required desired images and also 2 plots will be saved and all images also 
the image windows will be displayed only for 1 second 
you will also be required to enter the ratio of salt and pepper noise to be added     suggestion keep it 0.01
you need to install openblas and gnuplot and opencv 3.1
there will be one more header file required gnuplot-iostream.h
the 2 images should be in the same folder