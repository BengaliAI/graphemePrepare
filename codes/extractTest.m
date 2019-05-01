clear
path = '..\data\scanned\BUET\EEE18C';
files = dir(path);

% im = imread('scanned.jpg');
% im = imread('M:\GraphemeDataset\EEE 18 C\EEE 18 C\scan0047.jpg');
%% OCR to detect Form ID
roi = [2100 1 450 500];
erode = 10; % digit thinning
ocrResults = ocrForm(im,roi,erode);
formID = ocrResults.Words{1};

%% Load Template and Align
addpath('C:\Users\prio\Documents\Adobe\FormFinal29.4')
imRef = imread(['form_' formID '.jpg']);
rec = surfAlign(imRef,im);
imshowpair(imRef,rec);

%% Crop mask
mask = imbinarize(rgb2gray(imread('maskThick.jpg')));
imshowpair(rec,mask)
mask = cat(3,mask,mask,mask);

%% Load Ground Truths

gt = utfRead('shuffled.txt');
gt = string(gt{1});
gt = gt(81*(str2double(formID)-1)+1:81*str2double(formID));
gt = fliplr(gt');
gt = reshape(gt, 9,9);
gt = reshape(gt',81,1);

%% Detect Blobs and Extract
% bw = medfilt2(rgb2gray(rec),[5,5]);
bw = bwareaopen(mask(:,:,1),800);
s = regionprops(bw,'BoundingBox');
s = struct2cell(s);
s= s';
for i=1:length(s)
    syl = imcrop(rec,s{i});
    imwrite(syl,['C:\Users\prio\Documents\Adobe\IUBform\sampleExtract\sample_'  char(gt(i)) '.png'])
end




