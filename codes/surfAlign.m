function [recovered,qual] = surfAlign(ref,moving)

    ref = imbinarize(rgb2gray(ref));
%     ref = medfilt2(ref,[5,5]);
    BW = imbinarize(rgb2gray(moving));
%     BW = medfilt2(BW,[5,5]);
    
    ptsOriginal  = detectSURFFeatures(ref);
    ptsDistorted = detectSURFFeatures(BW);
    [featuresOriginal,  validPtsOriginal]  = extractFeatures(ref,  ptsOriginal);
    [featuresDistorted, validPtsDistorted] = extractFeatures(BW, ptsDistorted);
    [indexPairs,qual] = matchFeatures(featuresOriginal, featuresDistorted);
    matchedOriginal  = validPtsOriginal(indexPairs(:,1));
    matchedDistorted = validPtsDistorted(indexPairs(:,2));
    tform = estimateGeometricTransform(...
        matchedDistorted, matchedOriginal, 'affine');

    outputView = imref2d(size(ref));
    recovered  = imwarp(moving,tform,'OutputView',outputView);
    qual = mean(1-qual./4);

end