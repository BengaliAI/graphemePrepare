clear
clc
source = 'BUETEEE';
sourcePath = ['../data/scanned' '/' source];
metadataFile = [sourcePath '.csv'];
targetPath = '../data/extracted';
errorPath = '../data/error';
refPath = '../collection/A4';
logPath = '../logs';
groundTruth = '../data/groundTruth.txt';
formIDs = 1:16;

%% Get mask, bounding box and meta
mask = imbinarize(rgb2gray(imread([refPath '/' 'maskThick.png'])));
bw = bwareaopen(mask,800);
s = regionprops(bw,'BoundingBox');
s = struct2cell(s);
s= s';
clear mask bw
%
metaTable = importMeta(metadataFile);
metaTable.formID = zeros(size(metaTable,1),1);
metaTable.formMeta = string(zeros(size(metaTable,1),1));
% log file
logfiles = dir(logPath);
files = dir(sourcePath);
logObj = Logs(logfiles,files);
validiFileIdx = logObj.txtCheck;
logtxtFile = fullfile(logPath, logfiles(validiFileIdx).name);
logObj.logFilePrint(logtxtFile,true,'Starting.....',false)
pilotIdx = logObj.pilotIdxFinder(logtxtFile);
validIdx= 0;
%% Extract

for idx=1:length(files)
    
    % JPG check
    split = (strsplit(files(idx).name,'.'));
    if ~strcmp(char(split(end)),'jpg')
        continue;
    end
    validIdx = validIdx+1;
    if validIdx >= pilotIdx
        % empty check
        logObj.logFilePrint(logtxtFile,true,files(idx).name,true)
        im = imread([sourcePath '/' files(idx).name]);
        if sum(sum(~imbinarize(rgb2gray(im))))<400000
            imwrite(im,[errorPath '/' files(idx).name])
            logObj.logFilePrint(logtxtFile,false,'emptyFile',true)
            continue;
        end
        %% OCR detect formID
        roi = [2100 1 450 500];
        dilate = 5;
        formID = ocrForm(im,roi,dilate,true); % display true

        %% if OCR error
        if ~ismember(str2double(formID),formIDs)
            imwrite(im,[errorPath '/' files(idx).name])
            logObj.logFilePrint(logtxtFile,false,'OCR error',true)
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

        count = 0;
        for i=1:length(s)
            grapheme = imcrop(rec,s{i});
            if ~isOutlierGrapheme(grapheme)
                filename = [targetPath '/' char(gt(i)) '/' source '_' char(split(1:end-1)) '.png'];
                imwrite(grapheme,filename);
                count = count+1;
            else
                filename = [errorPath '/' char(gt(i)) '_' source '_' char(split(1:end-1)) '.png'];
                imwrite(grapheme,filename);
            end
        end
        logObj.logFilePrint(logtxtFile,false,'extractedGrapheme=',false)
        logObj.logFilePrint(logtxtFile,false,string(count),true)
        logObj.logFilePrint(logtxtFile,false,'completed',false)
    end
end
fclose(fid);
%% Save metaData
writetable(metaTable,metadataFile);
