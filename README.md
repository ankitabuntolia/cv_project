# cv_project

* Mo will upload a summary of the presentations of the last exercise.
* Lena will upload code for the approach in paper "Color-Based for Tree Yield Fruits Image Counting"

* Hints:
** use algo_test for inspiration on functions to use
** everybody should upload a file with his/her results as reference for the others and to see our current results
** please comment you're files
** if you want to contribute some meaningful changes to files of other, please first comment in telegram to avoid conflicts and merges (because we are all still not too used to git)
** for questions and problems concering git, contact Lena
** please don't upload data, only code!! -> Lena's free file space is very limited!

## Our plan
* load images
* undistort images

* convert the images so that the peaches are visible best:
** try different approaches and compare in which peaches are visible best
** try both rgb and thermal images separately -> we can than maybe add up information by warping the thermal image on the rgb
** ideas
*** converting to other color spaces (HSI, LAB, YCBCR, ...)
*** increasing value of red channel
*** increasing contrast
*** reduction of shadows
*** k-means
** goal for 1st step: 
*** binary image with black peaches and white background
*** more false positive instead of loosing peaches in this phase

* morphological operation to improve found peach shapes and remove branches (e.g. erosion, close, open, dilation, ...)
** goal: get rid of branches before edge detection

* perform circular hough transform
** maybe perform canny edge detection beforehand
** maybe also watershed transform
** goal: pixel coordinates for peach centers in the rgb images

* (blob analysis)
** after getting some type of center information (either directly from CHT or by e.g. 8-bit connectivity (gives you centroids)) we could try to look at dimensions of blobs and decide some rule
** better ideas are appreciated!

* tracking
** use sfm to match pixel coordinates of pictures
** no specific idea yet, left for later

* evaluating results/count
** left for later
