clear
clc
source = 'RIFLESCLG2';
sourcePath = ['../data/scanned' '/' source];
targetPath = '../data/extracted';
errorPath = '../data/error';
refPath = '../collection/A4';
logPath = '../logs';
groundTruth = '../data/groundTruth.txt';
formIDs = 1:16;

%% Get mask and bounding box
mask = imbinarize(rgb2gray(imread([refPath '/' 'maskThick.png'])));
bw = bwareaopen(mask,800);
s = regionprops(bw,'BoundingBox');
s = struct2cell(s);
s= s';

% clear ref mask bw

%% Extract
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
    dilate = 5; 
    ocrResults = ocrForm(im,roi,dilate,false); % display true
    formID = ocrResults.Words{1};
    formID = strip(formID)
    
    %% if OCR error
    if isnan(str2double(formID))
        %         imwrite(im,[errorPath '/' files(idx).name])
        %         continue;
        formID = '8' % happens only when 8
    elseif ~ismember(str2double(formID),formIDs)
        imwrite(im,[errorPath '/' files(idx).name])
        continue;
    end
    
    %% Load Template and Align
    imRef = imread([refPath '/' 'form_' formID '.jpg']);
    [rec,qual] = surfAlignGPU(imRef,im,true,false); % Nonrigid, disp
%     imshowpair(imRef,rec);
    
    %% Load Ground Truths
    gt = utfRead(groundTruth);
    gt = string(gt{1});
    gt = gt(81*(str2double(formID)-1)+1:81*str2double(formID));
    gt = fliplr(gt');
    gt = reshape(gt, 9,9);
    gt = reshape(gt',81,1);
    
    
    %% Detect Blobs and Extract
    disp(['Extracting From ' files(idx).name])
    
    for i=1:length(s)
        grapheme = imcrop(rec,s{i});
        filename = [targetPath '/' char(gt(i)) '/' source '_' char(split(1:end-1)) '.png'];
        imwrite(grapheme,filename);
    end
end



