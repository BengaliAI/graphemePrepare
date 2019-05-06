function [bw,img] = markerExtract(img,dilate)
if nargin<2
  dilate = 0;
end
bw = ~imbinarize(rgb2gray(img));
bw = bwareaopen(bw,2500);
CC = bwconncomp(bw);
L = labelmatrix(CC);
s = regionprops(CC,'Extent');
bw = ismember(L, find([s.Extent] >= .7));
bw = imdilate(bw, strel('disk',dilate));
bw = cat(3,bw,bw,bw);
img(~bw) = 0;
bw = bw(:,:,1);
end