#include <core.hpp>
#include <highgui.hpp>
#include <imgproc.hpp>
#include <iostream>
#include <climits>
#include <cmath>
#include <ctime>
#include <vector>
#include <algorithm>
#include <functional>
#include <fstream>
#include <boost/tuple/tuple.hpp>

#include "gnuplot-iostream.h"

#define PI 3.141592653589793238463

using namespace cv;
using namespace std;

vector<pair<int, int>> p;
void display(const vector<int>& v)
{
	for (int i = 0; i < v.size(); i++)
	{
		cout << v.at(i) << " ";
	}
	cout << endl;
}
void initialise_pair(int n)
{
	p.resize(0);
	int x = 0, y = 0, count = 0;
	while (x != n - 1 || y != n - 1)
	{
		if (count % 2 == 0)
		{
			while (x >= 0 && x < n && y >= 0 && y < n)
			{
				p.push_back(make_pair(x, y));
				x--; y++;
			}
			if (count < n-1)
			{
				x++;
			}
			else
			{
				y--;
				x += 2;
			}
			count++;
		}
		else
		{
			while (x >= 0 && x < n && y >= 0 && y < n)
			{
				p.push_back(make_pair(x, y));
				x++; y--;
			}
			if (count < n-1)
			{
				y++;
			}
			else
			{
				x--;
				y += 2;
			}
			count++;
		}
	}
	p.push_back(make_pair(n - 1, n - 1));
}
Mat apply_filter(const Mat &src, const Mat &kernal)
{
	int ksize_h = kernal.size().height;
	ksize_h = (ksize_h - 1) / 2;
	int ksize_w = kernal.size().width;
	ksize_w = (ksize_w - 1) / 2;
	Mat dst = Mat::zeros(src.size(), DataType<double>::type);
	for (int i = 0; i < src.rows; i++)
	{
		for (int j = 0; j < src.cols; j++)
		{
			double c = 0.0;
			for (int k = -ksize_h; k <= ksize_h; k++)
			{
				for (int l = -ksize_w; l <= ksize_w; l++)
				{
					if (!(((i + k) <0) || (i + k) >= src.rows || ((j + l) <0) || (j + l) >= src.cols))
					{
						c = c + double(src.at<uchar>(i + k, j + l))*kernal.at<double>(k + ksize_h, l + ksize_w);
					}
				}
			}
			dst.at<double>(i, j) = c;
		}
	}
	return dst;
}
void normalise(Mat& src)
{
	src.convertTo(src, DataType<double>::type);
	int r = src.rows;
	int c = src.cols;
	double max = 0;
	double limit = 255.0;
	for (int i = 0; i < r; i++)
	{
		for (int j = 0; j < c; j++)
		{
			if (src.at<double>(i, j) > max)
			{
				max = src.at<double>(i, j);
			}
		}
	}
	for (int i = 0; i < r; i++)
	{
		for (int j = 0; j < c; j++)
		{
			src.at<double>(i, j) *= (limit / max);
		}
	}
}
Mat add2images(const Mat& src1, const Mat& src2)
{
	Mat dst = Mat::zeros(src1.size(), DataType<double>::type);
	if (src1.size() != src2.size())
	{
		cout << "size of both images not same for add 2 images " << endl;
	}
	else
	{
		for (int i = 0; i < dst.rows; i++)
		{
			for (int j = 0; j < dst.cols; j++)
			{
				dst.at<double>(i, j) = double(src1.at<uchar>(i, j)) + double(src2.at<uchar>(i, j));
			}
		}
	}
	//dst.convertTo(dst, CV_8UC1);
	return dst;
}
double mse(Mat & image1, Mat & image2)
{
	double mse = 0;
	if (image1.size() != image2.size())
	{
		cout << "size of both images not same for add 2 images \nError mse" << endl;
		return 0;
	}
	int height = image1.rows;
	int width = image1.cols;
	for (int i = 0; i < height; i++)
	{
		for (int j = 0; j < width; j++)
		{
			mse += ((image1.at<uchar>(i, j) - image2.at<uchar>(i, j)) * (image1.at<uchar>(i, j) - image2.at<uchar>(i, j)));
		}
	}
	mse /= (height * width);
	return mse;
}
double psnr(Mat & image1, Mat & image2)
{
	int D = 255;
	double denominator = mse(image1, image2);
	if (denominator != 0)
		return (10 * log10((D*D) / denominator));
	else
	{
		cout << "Both are same images Error PSNR" << endl;
		return 0;
	}
}
Mat grayscale(const Mat & colour_image)
{
	Mat gray_image = Mat(colour_image.size(), CV_8UC1);
	int row = colour_image.rows;
	int col = colour_image.cols;
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			Vec3b intensity = colour_image.at<Vec3b>(i, j);
			gray_image.at<uchar>(i, j) = uchar((0.3 * intensity.val[2]) + (0.59 * intensity.val[1]) + (0.11 * intensity.val[0]));
		}
	}
	return gray_image;
}
Mat sobel_merge(Mat& image1, Mat& image2)
{
	image1.convertTo(image1, CV_8UC1);
	image2.convertTo(image2, CV_8UC1);
	Mat merge = Mat(image1.size(), DataType<double>::type);
	if (image1.size() != image2.size())
	{
		cout << "size of both images not same for add 2 images \nError merge" << endl;
		return merge;
	}
	int height = image1.rows;
	int width = image1.cols;
	for (int i = 0; i < height; i++)
	{
		for (int j = 0; j < width; j++)
		{
			merge.at<double>(i, j) = sqrt((image1.at<uchar>(i, j)*image1.at<uchar>(i, j)) + (image2.at<uchar>(i, j)*image2.at<uchar>(i, j)));
		}
	}
	merge.convertTo(merge, CV_8UC1);
	return merge;
}
void apply_Sobel(const Mat& image)
{
	cout << "\nApplying sobel" << endl;
	Mat sobel_h = (Mat_<double>(3, 3) << -1, -2, -1, 0, 0, 0, 1, 2, 1);
	Mat sobel_v = (Mat_<double>(3, 3) << -1, -0, 1, -2, 0, 2, -1, 0, 1);
	Mat horizontal = apply_filter(image,sobel_h), imagex, imagey;
	horizontal.convertTo(horizontal, CV_8UC1);
	imwrite("horizontal gradient.jpg", horizontal);
	Mat vertical = apply_filter(image, sobel_v);
	vertical.convertTo(vertical, CV_8UC1);
	imwrite("vertical gradient.jpg", vertical);
	Mat grad = sobel_merge(horizontal, vertical);
	Sobel(image, imagex, CV_8UC1, 1, 0, 3);
	Sobel(image, imagey, CV_8UC1, 0, 1, 3);
	imwrite("vertical gradient original.jpg", imagex);
	imwrite("horizontal gradient original.jpg", imagey);
	imwrite("gradient magnitude image.jpg", grad);
	threshold(grad, grad, 150.0, 255, CV_8UC1);
	imwrite("thresholded image.jpg", grad);
	cout << "sobel finished\n" << endl;
}
Mat apply_salt_pepper(const Mat & image, double p)
{
	Mat dst = image.clone();
	int height = image.rows;
	int width = image.cols;
	for (int i = 0; i < height; i++)
	{
		for (int j = 0; j < width; j++)
		{
			double f = (double)rand() / RAND_MAX;
			if(f < p/2)
				dst.at<uchar>(i, j) = 0;
			else if(f < p)
				dst.at<uchar>(i, j) = 255;
		}
	}
	return dst;
}
Mat apply_mean(const Mat & image, int size)
{
	size = 2 * size + 1;
	int denominator = size*size;
	Mat kernal = Mat(size, size, DataType<double>::type, Scalar(double(1) / double(denominator)));
	Mat dst = apply_filter(image, kernal);
	dst.convertTo(dst, CV_8UC1);
	return dst;
}
Mat apply_median(const Mat & image, int size)
{
	int vector_size = (2 * size + 1)*(2 * size + 1);
	int row = image.rows;
	int col = image.cols;
	Mat dst = Mat(image.size(), CV_8UC1);
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			vector<int> v;
			for (int k = -size; k <= size; k++)
			{
				for (int l = -size; l <= size; l++)
				{
					if (!(((i + k) <0) || (i + k) >= row || ((j + l) <0) || (j + l) >= col))
					{
						v.push_back(image.at<uchar>(i + k, j + l));
					}
				}
			}
			v.resize(vector_size);
			nth_element(v.begin(), v.begin() + vector_size / 2, v.end());
			dst.at<uchar>(i, j) = v.at(vector_size / 2);
		}
	}
	return dst;
}
Mat apply_dct(const Mat &image)
{
	Mat new_image = Mat(image.size(), DataType<double>::type);
	int row = image.rows;
	int col = image.cols;
	if (row != col)
	{
		cout << "Error in apply dct" << endl;
		return new_image;
	}
	double n = row;
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			double c = 0;
			for (int x = 0; x < row; x++)
			{
				for (int y = 0; y < col; y++)
				{
					c += double(image.at<int>(x, y)) * cos((2 * x + 1)*(i*PI) / (2 * n)) * cos((2 * y + 1)*(j*PI) / (2 * n));
				}
			}
			c /= (sqrt(2 * n));
			if (i == 0)
			{
				c /= sqrt(2);
			}
			if (j == 0)
			{
				c /= sqrt(2);
			}
			new_image.at<double>(i, j) = c;
		}
	}
	new_image.convertTo(new_image, DataType<int>::type);
	return new_image;
}
vector<int> compress(const vector<int>&v)
{
	vector<int> comp;
	int len = int(v.size()), rlen;
	for (int i = 0; i < len; i++)
	{
		comp.push_back(v.at(i));
		rlen = 1;
		while (i + 1 < len && v.at(i) == v.at(i + 1))
		{
			rlen++;
			i++;
		}
		comp.push_back(rlen);
	}
	return comp;
}
vector<int> decompress(const vector<int>&v)
{
	vector<int> decomp;
	int len = int(v.size());
	for (int i = 0; i < len; i+=2)
	{
		decomp.resize(decomp.size() + v.at(i + 1), v.at(i));
	}
	return decomp;
}
Mat inverse_zigzag(const vector<int>&v)
{
	vector<int> decomp = decompress(v);
	int n = int(decomp.size());
	n = int(sqrt(n));
	Mat new_image = Mat(n, n, DataType<int>::type);
	for (int i = 0; i < p.size(); i++)
	{
		new_image.at<int>(p.at(i).first, p.at(i).second) = decomp.at(i);
	}
	return new_image;
}
vector<int> zigzag(const Mat&image)
{
	vector<int> v;
	for (int i = 0; i < p.size(); i++)
	{
		v.push_back(image.at<int>(p.at(i).first, p.at(i).second));
	}
	return compress(v);
}
vector<Mat> divide(const Mat & image, int n)
{
	int row = image.rows;
	int col = image.cols;
	vector<Mat> matrices;
	for (int i = 0; i < row; i += n)
	{
		for (int j = 0; j < col; j += n)
		{
			matrices.push_back(image(Rect(j, i, n, n)));
		}
	}
	return matrices;
}
Mat combine(vector<Mat>& matrices, int n, int row, int col)
{
	int idx = 0;
	Mat image = Mat::zeros(row, col, DataType<int>::type);
	for (int i = 0; i < row; i += n)
	{
		for (int j = 0; j < col; j += n)
		{
			matrices.at(idx).copyTo(image(Rect(j, i, n, n)));
			idx++;
		}
	}
	return image;
}
Mat apply_inverse_dct(const Mat &image)
{
	Mat new_image = Mat(image.size(), DataType<double>::type);
	int row = image.rows;
	int col = image.cols;
	if (row != col)
	{
		cout << "Error in apply inverse_dct" << endl;
		return new_image;
	}
	double n = row;
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			double c = 0;
			for (int x = 0; x < row; x++)
			{
				for (int y = 0; y < col; y++)
				{
					double d = double(image.at<int>(x, y)) * (cos(((2 * i + 1)*x*PI) / (2 * n))) * (cos(((2 * j + 1)*y*PI) / (2 * n)));
					if (x == 0)
					{
						d /= sqrt(2.0);
					}
					if (y == 0)
					{
						d /= sqrt(2.0);
					}
					c += d;
				}
			}
			c *= (double(2) / sqrt(n*n));
			new_image.at<double>(i, j) = c;
		}
	}
	new_image.convertTo(new_image, DataType<int>::type);
	return new_image;
}
vector<vector<int>> DCT(const Mat &image)
{
	int row = image.rows;
	int col = image.cols;
	Mat new_image;
	// padding process here
	int x, y;
	if (row % 8 == 0)
		x = 0;
	else
		x = 8 - (row % 8);
	if (col % 8 == 0)
		y = 0;
	else
		y = 8 - (col % 8);
	copyMakeBorder(image, new_image, 0, x, 0, y, BORDER_CONSTANT, Scalar(0));
	new_image.convertTo(new_image, DataType<int>::type);
	subtract(new_image, 128, new_image);
	// dividing begins here 
	vector<Mat> matrices = divide(new_image, 8);
	// applying dct
	vector<vector<int>> runlength;
	Mat div;
	for (int i = 0; i < matrices.size(); i++)
	{
		matrices.at(i) = apply_dct(matrices.at(i));
		div = matrices.at(i);
		div.convertTo(div, DataType<int>::type);
		runlength.push_back(zigzag(div));
	}
	return runlength;
}
Mat inverse_DCT(const vector<vector<int>> &runlength, int row, int col)
{
	int x = row, y = col;
	if (row % 8 != 0)
		row = row + 8 - (row % 8);
	if (col % 8 != 0)
		col = col + 8 - (col % 8);

	vector<Mat> matrices;
	Mat m;
	for (int i = 0; i < runlength.size(); i++)
	{
		m = inverse_zigzag(runlength.at(i));
		m = apply_inverse_dct(m);
		matrices.push_back(m);
	}
	Mat new_image = combine(matrices, 8, row, col);
	add(new_image, 128, new_image);
	new_image.convertTo(new_image, CV_8UC1);
	return new_image(Rect(0, 0, y, x));
}
Mat original_harris_corner(const Mat &image)
{
	cout << "\nApplying Actual Harris corner " << endl;
	Mat dst, dst_norm, dst_norm_scaled;
	dst = Mat::zeros(image.size(), DataType<double>::type);

	/// Detector parameters
	const int blockSize = 2;
	const int apertureSize = 3;
	const double k = 0.04;
	const int thresh = 200;

	/// Detecting corners
	cornerHarris(image, dst, blockSize, apertureSize, k, BORDER_DEFAULT);

	/// Normalizing
	normalize(dst, dst_norm, 0, 255, NORM_MINMAX, DataType<double>::type, Mat());
	convertScaleAbs(dst_norm, dst_norm_scaled);

	/// Drawing a circle around corners
	for (int j = 0; j < dst_norm.rows; j++)
	{
		for (int i = 0; i < dst_norm.cols; i++)
		{
			if ((int)dst_norm.at<double>(j, i) > thresh)
			{
				circle(dst_norm_scaled, Point(i, j), 5, Scalar(0), 2, 8, 0);
			}
		}
	}
	return dst_norm_scaled;
}
Mat harris_corner(const Mat &image)
{
	cout << "\nApplying Harris corner " << endl;
	const double k = 0.04;
	const double threshold = 170;
	const int row = image.rows;
	const int col = image.cols;
	Mat imagex, imagey, imagex2, imagey2 ,imagexy,blur_imagex2, blur_imagey2, blur_imagexy;
	Sobel(image, imagex, DataType<double>::type, 1, 0, 3);
	Sobel(image, imagey, DataType<double>::type, 0, 1, 3);
	imagex2 = imagex.mul(imagex);
	imagey2 = imagey.mul(imagey);
	imagexy = imagex.mul(imagey);
	GaussianBlur(imagex2, blur_imagex2, Size(5, 5), 1.0);
	GaussianBlur(imagey2, blur_imagey2, Size(5, 5), 1.0);
	GaussianBlur(imagexy, blur_imagexy, Size(5, 5), 1.0);
	imagex.release();
	imagey.release();
	imagex2.release();
	imagey2.release();
	imagexy.release();
	Mat new_image = Mat::zeros(image.size(), CV_8UC1);
	Mat dst1, dst2, dst3, dst4, dst5, dst, dst_norm, dst_norm_scaled;
	dst1 = blur_imagex2.mul(blur_imagey2);
	dst2 = blur_imagexy.mul(blur_imagexy);
	subtract(dst1, dst2, dst3);
	add(blur_imagex2, blur_imagey2, dst4);
	dst5 = dst4.mul(dst4);
	subtract(dst3, k*dst5, dst);
	dst1.release();
	dst2.release();
	dst3.release();
	dst4.release();
	dst5.release();
	normalize(dst, dst_norm, 0, 255, NORM_MINMAX, DataType<double>::type, Mat());
	convertScaleAbs(dst_norm, dst_norm_scaled);
	dst_norm_scaled.convertTo(dst_norm_scaled, CV_8UC1);
	dst.release();
	dst_norm.release();
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			if (dst_norm_scaled.at<uchar>(i, j) > threshold)
			{
				new_image.at<uchar>(i, j) = 255;
				//circle(new_image, Point(i, j), 5, Scalar(255), 2, 8, 0);
			}
		}
	}
	return new_image;
}
void graph(const Mat &image)
{
	cout << "\ncreating graph" << endl;
	Gnuplot gp;
	vector<pair<double,double>> plot_mean;
	vector<pair<double,double>> plot_median;
	Mat new_image, mean, median;
	double psnr1, psnr2;
	for (double i = 0.01; i <= 0.05; i += 0.01)
	{
		new_image = apply_salt_pepper(image, i);
		mean = apply_mean(new_image, 2);
		median = apply_median(new_image, 2);
		psnr1 = psnr(new_image, mean);
		psnr2 = psnr(new_image, median);
		plot_mean.push_back(make_pair(i, psnr1));
		plot_median.push_back(make_pair(i, psnr2));
	}
	gp << "set ylabel 'PSNR'; \nset xlabel 'salt pepper noise percentage'; \nset terminal png size 1200,700 enhanced font 'Helvetica,20'\nset output 'mean.png';";
	gp << "plot" << gp.file1d(plot_mean) << "with lines title 'for mean' " << endl;
	gp << "set ylabel 'PSNR'; \nset xlabel 'salt pepper noise percentage'; \nset terminal png size 1200,700 enhanced font 'Helvetica,20'\nset output 'median.png';";
	gp << "plot" << gp.file1d(plot_median) << "with lines title 'for median' " << endl;
	cout << "finished\n" << endl;
}
void salt_pepper(const Mat &image)
{
	cout << "Enter value for p from 0 to 1" << endl;
	double p;
	cin >> p;
	Mat new_image = apply_salt_pepper(image, p), mean, median, mean_original, median_original;
	imwrite("salt pepper.jpg", new_image);
	cout << "Applying mean" << endl;
	mean = apply_mean(new_image,2);
	imwrite("mean filter.jpg", mean);
	blur(new_image, mean_original, Size(5, 5), Point(-1, -1), BORDER_CONSTANT);
	imwrite("mean filter original.jpg", mean_original);
	cout << "Applying median" << endl;
	median = apply_median(new_image, 2);
	imwrite("median filter.jpg", median);
	medianBlur(new_image, median_original, 5);
	imwrite("median filter original.jpg", median_original);
	cout << "psnr value for mean = " << psnr(new_image, mean) << endl;
	cout << "psnr value for median = " << psnr(new_image, median) << endl;
	cout << "original psnr value for mean = " << psnr(new_image, mean_original) << endl;
	cout << "original psnr value for median = " << psnr(new_image, median_original) << endl;
	graph(image);
}
int main()
{
	initialise_pair(8);
	srand((unsigned int)time(NULL));
	const string img1 = "cap.bmp";
	const string img2 = "lego.tif";
	Mat image1 = imread(img1, CV_LOAD_IMAGE_GRAYSCALE);
	Mat image2 = imread(img2, CV_LOAD_IMAGE_COLOR);
	imshow("image1", image1);
	waitKey(1000); 
	imshow("image2", image2);
	waitKey(1000);
	Mat image2_new = grayscale(image2);
	imwrite("grayscale image.jpg", image2_new);
	cvtColor(image2, image2, CV_BGR2GRAY);
	imwrite("grayscale image original.jpg", image2);
	// salt pepper noise and graph
	salt_pepper(image1);
	// sobel operators
	apply_Sobel(image2);
	imshow("original", image1);
	waitKey(1000);
	cout << "\nApplying DCT and inverse DCT\n" << endl;
	Mat dct_image = inverse_DCT(DCT(image1),image1.rows,image1.cols);
	imwrite("after inverse dct.jpg", dct_image);
	//cout<<"what"<<endl;
	Mat image1_dct, image1_dct2, image1_idct, image1_idct2;
	image1.convertTo(image1, CV_32FC1);
	dct(image1, image1_dct);
	image1_dct.convertTo(image1_dct2, CV_8UC1);
	imwrite("after dct original.jpg", image1_dct2);
	idct(image1_dct, image1_idct);
	image1_idct.convertTo(image1_idct2, CV_8UC1);
	imwrite("after inverse dct original.jpg", image1_idct2);
	
	Mat m1 = original_harris_corner(image2),m2 = harris_corner(image2);
	imwrite("haris corner image.jpg", m2);
	imwrite("harris corner image original.jpg", m1);
	return 0;
}