function [recovered,qual] = surfAlignGPU(ref,moving,nonrigid,disp)

if nargin<3
    disp = false;
end
ref = rgb2gray(ref);
BW = rgb2gray(moving);

ptsOriginal  = detectSURFFeatures(ref);
ptsDistorted = detectSURFFeatures(BW);
[featuresOriginal,  validPtsOriginal]  = extractFeatures(ref,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(BW, ptsDistorted);
[indexPairs,qual] = matchFeatures(featuresOriginal, featuresDistorted,...
    'MatchThreshold',70);
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));
tform = estimateGeometricTransform(...
    matchedDistorted, matchedOriginal, 'affine');

outputView = imref2d(size(ref));
recovered  = imwarp(moving,tform,'OutputView',outputView);

fixedGPU  = gpuArray(ref);
movingGPU = gpuArray(recovered);

% fixedGPU  = rgb2gray(fixedGPU);
movingGPU = rgb2gray(movingGPU);

% fixedHist = imhist(fixedGPU);
% movingGPU = histeq(movingGPU,fixedHist);

[D,~] = imregdemons(movingGPU,fixedGPU,100,'AccumulatedFieldSmoothing',3.0,'PyramidLevels',7);

recovered = gather(recovered);
D = gather(D);
recovered = imwarp(recovered,D);

if disp
    imshowpair(recovered,ref)
end
end