function [recovered,qual] = surfAlign(ref,moving,disp)
if nargin<3
    disp = false;
end
ref = rgb2gray(ref);
%     ref = imbinarize(ref);
BW = rgb2gray(moving);
%     BW = imbinarize(BW);
%     imshow(BW)

ptsOriginal  = detectSURFFeatures(ref);
ptsDistorted = detectSURFFeatures(BW);
[featuresOriginal,  validPtsOriginal]  = extractFeatures(ref,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(BW, ptsDistorted);
[indexPairs,qual] = matchFeatures(featuresOriginal, featuresDistorted,...
    'MatchThreshold',13.541667,'Unique',true);
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));
tform = estimateGeometricTransform(...
    matchedDistorted, matchedOriginal, 'affine');

outputView = imref2d(size(ref));
recovered  = imwarp(moving,tform,'OutputView',outputView);
qual = mean(1-qual./4);

if disp
    imshowpair(recovered,ref)
end
end