function [age_crop, gender_crop, dominant_hand_crop, medium_crop, division_crop]= metadataExtraction(scanned_img, refPath)

%% Load Scanned Image
img=imread(scanned_img);

%% OCR detect formID
roi = [2100 1 450 500];
dilate = 5; 
ocrResults = ocrForm(img,roi,dilate,false); % display true
formID = ocrResults.Words{1};
formID = strip(formID);
if ~formID
    formID= '8';
end

%% Load Template and Align
imRef = imread([refPath '\' 'form_' formID '.jpg']);
[rec,qual] = surfAlignGPU(imRef,img,true,false); % Nonrigid, disp
figure
imshowpair(imRef,rec);

%% Crop Scanned image for the metadata portion with suitable ROI
img=imcrop(rec,[115 185 1900-115 540-185]);
figure
imshow(img)

%% Crop metadataRef with Same ROI
metadata = imread([refPath '\metadataRef.png']);
metadata=imcrop(metadata,[115 185 1900-115 540-185]);
figure
imshow(metadata)

%% Centroids and Bounding Boxes for the OMR options
omr = ~imbinarize(rgb2gray(img));
omr = bwareaopen(omr,800);
CC = bwconncomp(omr);
L = labelmatrix(CC);
s = regionprops(CC,'Extent');
omr = ismember(L, find([s.Extent] >= .7));
s = regionprops(omr,'Centroid', 'BoundingBox');
centroids = cat(1, s.Centroid);
s = struct2cell(s);
s= s';
figure
imshow(omr)
hold(imgca,'on')
plot(imgca,centroids(:,1), centroids(:,2), 'r*')
hold(imgca,'off')

%% Extract
age= s{1,2};
gender= s{2,2};
dominant_hand= s{3,2};
medium= s{4,2};
division= s{5,2};

age_crop=imcrop(img,[age(1)+50 age(2) 105 45]);
gender_crop=imcrop(img,[gender(1)+50 gender(2) 105 45]);
dominant_hand_crop=imcrop(img,[dominant_hand(1)+50 dominant_hand(2) 105 45]);
medium_crop=imcrop(img,[medium(1)+50 medium(2) 105 45]);
division_crop=imcrop(img,[division(1)+50 division(2) 105 45]);

figure
imshow(age_crop)
figure
imshow(gender_crop)
figure
imshow(dominant_hand_crop)
figure
imshow(medium_crop)
figure
imshow(division_crop)
