clear
sourcePath = '../data/scanned/BUET/EEE18C';
targetPath = '../data/extracted';
errorPath = '../data/error';
refPath = '../collections/Letter';
logPath = '../logs';
formIDs = 1:16;

files = dir(sourcePath);

for idx=1:length(files)
    
    % JPG check
    split = (strsplit(files(idx).name,'.'));
    if ~strcmp(char(split(end)),'jpg')
        continue;
    end
    % empty check
    im = imread([sourcePath '/' files(idx).name]);
    if sum(sum(sum(~imbinarize(im))))<400000
        imwrite(im,[errorPath '/' files(idx).name])
        continue;
    end
    
    %% OCR detect formID
    roi = [2100 1 450 500];
    erode = 15; % digit thinning
    ocrResults = ocrForm(im,roi,erode,false);
    formID = ocrResults.Words{1};
    
    %% if OCR error
    if ~ismember(str2double(formID),formIDs)
        imwrite(im,[errorPath '/' files(idx).name])
        continue;
    end
    if isnan(str2double(formID))
        imwrite(im,[errorPath '/' files(idx).name])
        continue;
    end
end
%% Load Template and Align
imRef = imread([refPath '/' 'form_' formID '.jpg']);
rec = surfAlign(imRef,im);
% imshowpair(imRef,rec);

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




