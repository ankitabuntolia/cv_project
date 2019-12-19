clear all; clc; close all;

%load images
rgbpath = './data/peaches/bottom/RGB';
thermalpath = './data/peaches/bottom/thermal';
imgscale = .25;

rgbds = datastore( rgbpath );
thermalds = datastore( thermalpath );
assert( length(rgbds.Files) == length(thermalds.Files) );

rgb = readimage( rgbds, 8 );
figure; imshow(rgb);


%% RGB adjust colors (makes peaches better visible)
gammas = [1 0.5 1];
rgb2 = imadjust(rgb,[.1 .1 0.3 ; .2 .5 1],[],gammas);
figure;
imshow(rgb2);


%% remove green pixels
 val= max(rgb,[],3); 
 mask=uint8(rgb(:,:,2)~=val);
 imshow(rgb.*mask);

 
%% 
I = double(rgb2)/255;
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

imshow(I-G-B);


%% transform to HSI - colorspace
I = double(rgb)/255;
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

numi=1/2*((R-G)+(R-B));
denom=((R-G).^2+((R-B).*(G-B))).^0.5;
H=acosd(numi./(denom+0.000001));
H(B>G)=360-H(B>G);
H=H/360;
S=1- (3./(sum(I,3)+0.000001)).*min(I,[],3);
I=sum(I,3)./3;
HSI=zeros(size(rgb));
HSI(:,:,1)=H;
HSI(:,:,2)=S;
HSI(:,:,3)=I;

figure,imshow(HSI);title('HSI Image');


%% RGB to grayscale
gray = rgb2gray(rgb2);
figure, imshow(gray);


%% RGB to YCbCr
YCBCR = rgb2ycbcr(rgb2);
figure; 
imshow(YCBCR);

%% RGB to LAB
LAB = rgb2lab(rgb) + 10;
figure; 
imshow(LAB);
RGB = lab2rgb(LAB);
figure; 
imshow(RGB);

%% try to remove shadow
se = strel('ball', 5,5);
background = imopen(gray, se);
imshow(background);

gray_new = gray - background;

gray_new2 = imadjust(gray_new);

bw = imbinarize(gray_new2);
bw = bwareaopen(bw,50);
figure;
imshow(bw);