#include <vector>
#include <iostream>
#include <cstdlib>
#include <algorithm>
#include <functional>
#include <numeric>
#include <opencv2/core/core.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/stitching/stitcher.hpp>

using namespace cv;
using namespace std;

Point2f mean_of_points(const vector< Point2f > & img)
{
	Point2f zero(0.0f, 0.0f);
	Point2f sum = accumulate(img.begin(), img.end(), zero);
	Point2f mean_point(sum.x / img.size(), sum.y / img.size());
	return mean_point;
}
void compute_match_points(const vector<KeyPoint> & keypoints1, const vector<KeyPoint> & keypoints2, const Mat & descriptors1, const Mat & descriptors2, vector< Point2f > & img1, vector< Point2f > & img2)
{
	img1.resize(0);
	img2.resize(0);
	// Matching descriptor vectors using FLANN matcher
	FlannBasedMatcher matcher;
	vector<DMatch> matches;
	matcher.match(descriptors1, descriptors2, matches);

	// filter out only good matches 
	// get the max and min
	double max_dist = 0, min_dist = 100000;
	for (int i = 0; i < descriptors1.rows; i++)
	{
		double dist = matches.at(i).distance;
		if (dist < min_dist)
			min_dist = dist;
		if (dist > max_dist)
			max_dist = dist;
	}
	// get all the good matches 
	vector<DMatch> good_matches;
	for (int i = 0; i < descriptors1.rows; i++)
	{
		if (matches.at(i).distance < 2 * min_dist)
		{
			good_matches.push_back(matches.at(i));
		}
	}
	//now get the points
	for (int i = 0; i < int(good_matches.size()); i++)
	{
		// Get the keypoints from the good matches
		img1.push_back(keypoints1[good_matches[i].queryIdx].pt);
		img2.push_back(keypoints2[good_matches[i].trainIdx].pt);
	}
}
Mat match_compute_homo(const vector<KeyPoint> & keypoints1, const vector<KeyPoint> & keypoints2, const Mat & descriptors1, const Mat & descriptors2)
{
	// this function will return the homography 
	//now get the points
	vector< Point2f > img1;
	vector< Point2f > img2;
	compute_match_points(keypoints1, keypoints2, descriptors1, descriptors2, img1, img2);
	Mat Homo = findHomography(img1, img2, CV_RANSAC);
	return Homo;
}
pair<int, int> get_padding_size(const vector<KeyPoint> & keypoints1, const vector<KeyPoint> & keypoints2, const Mat & descriptors1, const Mat & descriptors2)
{
	// 
	//now get the points
	vector< Point2f > img1;
	vector< Point2f > img2;
	compute_match_points(keypoints1, keypoints2, descriptors1, descriptors2, img1, img2);
	Point2f mean1 = mean_of_points(img1);
	Point2f mean2 = mean_of_points(img2);
	pair<int, int> c = make_pair(int(abs(mean1.x - mean2.x)), int(abs(mean1.y - mean2.y)));
	return c;
}
int main()
{
	int row, col;
	Mat image_blur = imread("Ajanta_blurred.jpg");
	Mat image1 = imread("Ajanta_1.jpg");
	Mat image2 = imread("Ajanta_2.jpg");
	Mat gray_image1, gray_image2, gray_image_blur, output;

	// Convert to Grayscale
	cvtColor(image1, gray_image1, CV_RGB2GRAY);
	cvtColor(image2, gray_image2, CV_RGB2GRAY);
	cvtColor(image_blur, gray_image_blur, CV_RGB2GRAY);

	// SIFT operations
	SiftFeatureDetector detector;
	vector<KeyPoint> keypoints1;
	vector<KeyPoint> keypoints2;
	vector<KeyPoint> keypoints_blur;
	detector.detect(gray_image1, keypoints1);
	detector.detect(gray_image2, keypoints2);
	detector.detect(gray_image_blur, keypoints_blur);

	// get descriptors
	SiftDescriptorExtractor extractor;
	Mat descriptors1, descriptors2, descriptors_blur;
	extractor.compute(gray_image1, keypoints1, descriptors1);
	extractor.compute(gray_image2, keypoints2, descriptors2);
	extractor.compute(gray_image_blur, keypoints_blur, descriptors_blur);

	// get the homography and combine
	Mat out_image1, out_image2;
	Mat Homo1 = match_compute_homo(keypoints1, keypoints_blur, descriptors1, descriptors_blur);
	Mat Homo2 = match_compute_homo(keypoints2, keypoints_blur, descriptors2, descriptors_blur);
	warpPerspective(image1, out_image1, Homo1, Size(image_blur.cols, image_blur.rows));
	warpPerspective(image2, out_image2, Homo2, Size(image_blur.cols, image_blur.rows));

	// now improving the original image begins 
	// get pixel value from result 2 first and if it is completely black ther from result 1 
	// even that is black then from original blurred image
	row = image_blur.rows;
	col = image_blur.cols;
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			int val2 = out_image2.at<Vec3b>(i, j)[0] + out_image2.at<Vec3b>(i, j)[1] + out_image2.at<Vec3b>(i, j)[2];
			int val1 = out_image1.at<Vec3b>(i, j)[0] + out_image1.at<Vec3b>(i, j)[1] + out_image1.at<Vec3b>(i, j)[2];
			if (val1 > 10 || val2 > 10)
			{
				if (val2 > val1)
				{
					image_blur.at<Vec3b>(i, j) = out_image2.at<Vec3b>(i, j);
				}
				else
				{
					image_blur.at<Vec3b>(i, j) = out_image1.at<Vec3b>(i, j);
				}
			}
		}
	}
	imwrite("new deblurred image.jpg", image_blur);
	// delete things that are not going to be used
	Homo1.release();
	Homo2.release();
	out_image1.release();
	out_image2.release();
	image_blur.release();

	// stiching begins
	// we will find homography of ajanta 1 in terms of ajanta 2

	pair<int, int> c = get_padding_size(keypoints1, keypoints2, descriptors1, descriptors2);
	// in image1 we have to padd zeros down and right and in next image up and left
	Mat new_image1, new_image2;
	copyMakeBorder(image1, new_image1, 0, c.second, 0, c.first, cv::BORDER_CONSTANT, Scalar::all(0));
	copyMakeBorder(image2, new_image2, c.second, 0, c.first, 0, cv::BORDER_CONSTANT, Scalar::all(0));

	// now combining begins 
	// transform image 1 in terms of image 2
	resize(new_image1, new_image1, Size(int(new_image1.cols / 1.1), int(new_image1.rows / 1.1)), 0, 0, INTER_CUBIC);
	resize(new_image2, new_image2, Size(int(new_image2.cols / 1.1), int(new_image2.rows / 1.1)), 0, 0, INTER_CUBIC);
	Mat new_gray_image1, new_gray_image2;
	cvtColor(new_image1, new_gray_image1, CV_RGB2GRAY);
	cvtColor(new_image2, new_gray_image2, CV_RGB2GRAY);

	detector.detect(new_gray_image1, keypoints1);
	detector.detect(new_gray_image2, keypoints2);
	extractor.compute(new_gray_image1, keypoints1, descriptors1);
	extractor.compute(new_gray_image2, keypoints2, descriptors2);
	Mat Homo = match_compute_homo(keypoints1, keypoints2, descriptors1, descriptors2);
	warpPerspective(new_image1, new_image1, Homo, new_image1.size());

	row = new_image1.rows;
	col = new_image1.cols;
	Mat final_image = Mat::zeros(new_image1.size(), new_image1.type());
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			int val2 = new_image2.at<Vec3b>(i, j)[0] + new_image2.at<Vec3b>(i, j)[1] + new_image2.at<Vec3b>(i, j)[2];
			int val1 = new_image1.at<Vec3b>(i, j)[0] + new_image1.at<Vec3b>(i, j)[1] + new_image1.at<Vec3b>(i, j)[2];
			if (val2 > val1)
			{
				final_image.at<Vec3b>(i, j) = new_image2.at<Vec3b>(i, j);
			}
			else
			{
				final_image.at<Vec3b>(i, j) = new_image1.at<Vec3b>(i, j);
			}
		}
	}
	imwrite("final stitched image.jpg", final_image);
	// delete data not to be used further
	new_gray_image1.release();
	new_gray_image2.release();
	Homo.release();
	final_image.release();
	new_image1.release();
	new_image2.release();
	descriptors1.release();
	descriptors2.release();

	// 3 rd part 
	Mat upscale_image1, gray_upscale_image1;
	const double upscale_factror = 1.1;
	resize(image1, upscale_image1, Size(int(image1.cols * upscale_factror), int(image1.rows * upscale_factror)), 0, 0, INTER_LINEAR);
	cvtColor(upscale_image1, gray_upscale_image1, CV_RGB2GRAY);
	detector.detect(gray_upscale_image1, keypoints1);
	detector.detect(gray_image2, keypoints2);
	extractor.compute(gray_upscale_image1, keypoints1, descriptors1);
	extractor.compute(gray_image2, keypoints2, descriptors2);
	gray_upscale_image1.release();
	Homo = match_compute_homo(keypoints2, keypoints1, descriptors2, descriptors1);
	warpPerspective(image2, new_image2, Homo, upscale_image1.size(), INTER_LANCZOS4);

	// now combining
	row = upscale_image1.rows;
	col = upscale_image1.cols;
	for (int i = 0; i < row; i++)
	{
		for (int j = 0; j < col; j++)
		{
			int val1 = upscale_image1.at<Vec3b>(i, j)[0] + upscale_image1.at<Vec3b>(i, j)[1] + upscale_image1.at<Vec3b>(i, j)[2];
			int val2 = new_image2.at<Vec3b>(i, j)[0] + new_image2.at<Vec3b>(i, j)[1] + new_image2.at<Vec3b>(i, j)[2];
			if (val2 > val1)
			{
				upscale_image1.at<Vec3b>(i, j) = new_image2.at<Vec3b>(i, j);
			}
		}
	}
	imwrite("new upscale image.jpg", upscale_image1);

	// deletion 
	Homo.release();
	descriptors1.release();
	descriptors2.release();
	upscale_image1.release();
	new_image2.release();
	image1.release();
	image2.release();
	return 0;
}