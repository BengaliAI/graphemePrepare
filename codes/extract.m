clear
clc
source = 'RIFLESSCH1';
sourcePath = ['../data/scanned' '/' source];
metadataFile = [sourcePath '.csv'];
targetPath = '../data/extracted';
errorPath = '../data/error';
refPath = '../collection/A4';
logPath = '../logs';
groundTruth = '../data/groundTruth.txt';
formIDs = 1:16;

%% Get mask, bounding box and meta
mask = imbinarize(rgb2gray(imread([refPath '/' 'mask.png'])));
bw = bwareaopen(mask,800);
s = regionprops(bw,'BoundingBox');
width_s=s(1).BoundingBox(3);
% Adding 20% of height and reducing yTop by 10% of height
for i=1:length(s)
    s(i).BoundingBox(2)=s(i).BoundingBox(2)-.1*s(i).BoundingBox(4);
    s(i).BoundingBox(4)=s(i).BoundingBox(4)+.2*s(i).BoundingBox(4);
end
s = struct2cell(s);
s= s';
clear mask bw

metaTable = importMeta(metadataFile);
metaTable.formID = zeros(size(metaTable,1),1);
metaTable.formMeta = string(zeros(size(metaTable,1),1));
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
    if sum(sum(~imbinarize(rgb2gray(im))))<400000
        imwrite(im,[errorPath '/' files(idx).name])
        continue;
    end
    
    %% OCR detect formID
    roi = [2100 1 450 500];
    dilate = 5;
    ocrResults = ocrForm(im,roi,dilate,true); % display true
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
    [rec,qual] = surfAlignGPU(imRef,im,true,true); % Nonrigid, disp
    %     imshowpair(imRef,rec);
    
    %% Extract Metadata
    meta = metadataExtract(refPath,rec);
    row = find(metaTable.filename == files(idx).name);
    metaTable.formID(row) = str2double(formID);
    metaTable.formMeta(row) = strjoin(string(meta));
    
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
        % We'll find long straight lines (of the range of 90% of width_s)
        % And remove them
        
        newgrapheme=imbinarize(rgb2gray(grapheme),graythresh(rgb2gray(grapheme)));
        imshow(newgrapheme);
        %% Step 1 : Hough transform to find lines (needs optimization)
        % Currently doesn't work at all, due to imbalance in line widths 
        % Above and below
        [H,T,R] = hough(newgrapheme,'Theta',0);
        P  = houghpeaks(H,2,'threshold',ceil(0.3*max(H(:))));
        lines = houghlines(newgrapheme,T,R,P,'FillGap',.02*width_s,'MinLength',.95*width_s);
        
        %% Step 2: We delete the lines
        
        for k = 1:length(lines)
           xy = [lines(k).point1; lines(k).point2];
           grapheme(min(xy(1,1),xy(2,1)):max(xy(1,1),xy(2,1)),min(xy(1,2),xy(2,2)):max(xy(1,2),xy(2,2)),:)=256;
        end
        filename = [targetPath '/' char(gt(i)) '/' source '_' char(split(1:end-1)) '.png'];
        imwrite(grapheme,filename);
    end
end

%% Save metaData
writetable(metaTable,metadataFile);