clear all
close all

source = 'RIFLESCLG2';
pack = ['../data/packed' '/' source];
fileList = dir(pack);
fileList = struct2cell(fileList);
intAvg = [];
for i=3:length(fileList) % skip the first two ['.','..']
    target = [pack '/' fileList{1,i}];
    im = im2double(rgb2gray(imread(target)));
    intAvg = [intAvg;sum(sum(im))/(size(im,1)*size(im,2))]; % Avg Intensity
end
%histogram(intAvg)
%% White Thresh
close all
thresh = .99;
idx = find(intAvg>thresh)+2; % idx 
for i=1:length(idx)
    figure();
    target = [pack '/' fileList{1,idx(i)}];
    imshow(rgb2gray(imread(target)))
    title(fileList{1,idx(i)})
end
%% Black Thresh
close all
idx = find(isoutlier(intAvg,'gesd'))+2;
for i=1:length(idx)
    figure();
    target = [pack '/' fileList{1,idx(i)}];
    imshow(rgb2gray(imread(target)))
    title(fileList{1,idx(i)})
end