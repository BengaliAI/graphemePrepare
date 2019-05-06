function centroids = markerCentroids(img,disp)
if nargin<2
    disp = false;
end
img = ~imbinarize(rgb2gray(img));
img = bwareaopen(img,2500);
CC = bwconncomp(img);
L = labelmatrix(CC);
s = regionprops(CC,'Extent');
img = ismember(L, find([s.Extent] >= .7));
s = regionprops(img,'Centroid');
centroids = cat(1, s.Centroid);
if disp
    imshow(img)
    hold(imgca,'on')
    plot(imgca,centroids(:,1), centroids(:,2), 'r*')
    hold(imgca,'off')
end
end