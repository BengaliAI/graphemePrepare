function [formID,results] = ocrForm(img,roi,erode,imdisp)
if nargin<4
    imdisp = false;
end
img = imcrop(img,roi);
% Make the image a bit bigger to help OCR
img = imresize(img, 5);
% binarize image
lvl = graythresh(img);
BWOrig = im2bw(img, lvl);
BWComplement = ~BWOrig;

% CC = bwconncomp(BWComplement);
% numPixels = cellfun(@numel, CC.PixelIdxList);
% [~,idx] = max(numPixels);
% BWComplement(CC.PixelIdxList{idx}) = 0;

%% Remove outline
CC = bwconncomp(BWComplement);
S = regionprops(CC,'Extent');
L = labelmatrix(CC);
BWComplement = ismember(L, find([S.Extent] >= .1));

%% Remove page marker
CC = bwconncomp(BWComplement);
S = regionprops(CC,'Extent');
L = labelmatrix(CC);
BWComplement = ismember(L, find([S.Extent] <= .7));

BWComplement = bwareaopen(BWComplement,20000);
% BWComplement = imerode(BWComplement, strel('square',erode));
BWComplement = imdilate(BWComplement, strel('disk',erode));
BWComplement = imresize(BWComplement,.15);

% Set text layout to 'Word' because the layout is nothing like a document.
% Set character set to be A to Z, to limit mistakes.
results = ocr(BWComplement, 'TextLayout', 'Word','CharacterSet','0123456789');
formID = results.Words{1};
formID = strip(formID);

%% Handle error with '8' detection
if isnan(str2double(results.Words{1}))
    formID = '8';
end

if imdisp
    img = imresize(img,.15);
    Iocr = insertObjectAnnotation(img, 'rectangle', ...
        results.WordBoundingBoxes, ...
        formID);
    imshow(Iocr);
end
end
