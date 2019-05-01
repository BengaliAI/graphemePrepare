function results = ocrForm(img,roi,erode,imdisp)
img = imcrop(img,roi);
% Make the image a bit bigger to help OCR
img = imresize(img, 5);
% binarize image
lvl = graythresh(img);
BWOrig = im2bw(img, lvl);
% BWOrig = imbinarize(img);
% First remove unwanted clutter
BWComplement = ~BWOrig;

CC = bwconncomp(BWComplement);
numPixels = cellfun(@numel, CC.PixelIdxList);
[~,idx] = max(numPixels);
BWComplement(CC.PixelIdxList{idx}) = 0;

% Next, because the text does not have a layout typical to a document, you
% need to provide ROIs around the text for OCR. Use regionprops for this.
BW = imdilate(BWComplement, strel('disk',3)); % grow the text a bit to get a bigger ROI around them.
% CC = bwconncomp(BW);
% Use regionprops to get the bounding boxes around the text
% s = regionprops(CC,'BoundingBox');
% roi = vertcat(s(:).BoundingBox);
% Apply OCR
% Thin the letters a bit, to help OCR deal with the blocky letters
BW1 = imerode(BWComplement, strel('square',erode));
BW1 = bwareaopen(BW1,20000);
if imdisp
    imshow(BW1)
end
% Set text layout to 'Word' because the layout is nothing like a document.
% Set character set to be A to Z, to limit mistakes.
results = ocr(BW1, 'TextLayout', 'Word','CharacterSet','0123456789');
end
