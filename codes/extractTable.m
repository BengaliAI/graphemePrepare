function [tableImg,roi] = extractTable(img,disp)
if nargin<2
    disp=false;
end
centroids = markerCentroids(img);
deg = [];
for i=1:size(centroids,1)/2
    diff = centroids(i+11,:)-centroids(i,:);
    deg = [deg,rad2deg(atan((-diff(2)/diff(1))))];
end
tableImg = imrotate(img,-deg(2),'bilinear','loose');
centroids = markerCentroids(tableImg);
centroids = sort(centroids);
roi = [0,centroids(3,2)-50,size(tableImg,2),size(tableImg,1)-centroids(3,2)+50];
tableImg = imcrop(tableImg,roi);
if disp
    imshow(tableImg)
end
end