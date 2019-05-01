function [results,S] = ocrForm(img,roi,erode,imdisp)
img = imcrop(img,roi);
% Make the image a bit bigger to help OCR
img = imresize(img, 5);
% binarize image
lvl = graythresh(img);
BWOrig = im2bw(img, lvl);
% First remove unwanted clutter
BWComplement = ~BWOrig;

CC = bwconncomp(BWComplement);
numPixels = cellfun(@numel, CC.PixelIdxList);
[~,idx] = max(numPixels);
BWComplement(CC.PixelIdxList{idx}) = 0;

% Next, because the text does not have a layout typical to a document, you
% need to provide ROIs around the text for OCR. Use regionprops for this.
% BW = imdilate(BWComplement, strel('disk',3)); % grow the text a bit to get a bigger ROI around them.

% CC = bwconncomp(BW);
% Use regionprops to get the bounding boxes around the text
% s = regionprops(CC,'BoundingBox');
% roi = vertcat(s(:).BoundingBox);
% Apply OCR
% Thin the letters a bit, to help OCR deal with the blocky letters
CC = bwconncomp(BWComplement);
S = regionprops(CC,'Extent');
L = labelmatrix(CC);
BWComplement = ismember(L, find([S.Extent] >= .1));
% BWComplement = bwareaopen(BWComplement,20000);
% BWComplement = imerode(BWComplement, strel('square',erode));
BWComplement = imresize(BWComplement,.15);
if imdisp
    imshow(BWComplement)
end

% Set text layout to 'Word' because the layout is nothing like a document.
% Set character set to be A to Z, to limit mistakes.
results = ocr(BWComplement, 'TextLayout', 'Word','CharacterSet','0123456789');
end
