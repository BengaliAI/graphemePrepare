clear all
close all
clc

source = 'RIFLESSCH5';
pack = ['../data/packed' '/' source];
pack = 'M:\GraphemeDataset\submission2\IUB2\IUB2';
fileList = dir(pack);
fileList = struct2cell(fileList);
intAvg = [];
for i=3:length(fileList) % skip the first two ['.','..']
    target = [pack '/' fileList{1,i}];
    im = im2double(rgb2gray(imread(target)));
    intAvg = [intAvg;sum(sum(im))/(size(im,1)*size(im,2))]; % Avg Intensity
end
histogram(intAvg)
%% Higher Tail
close all
thresh = .98;
idx = find(intAvg>thresh)+2; % idx
for i=1:length(idx)
    figure();
    target = [pack '/' fileList{1,idx(i)}];
    targetImg = imread(target);
    imshow(targetImg)
    if isOutlierGrapheme(targetImg)
        disp(fileList{1,idx(i)})
%         delete(target)
    end
    title(fileList{1,idx(i)})
end
%% Lower Tail
close all
thresh = .89;
idx = find(intAvg<thresh)+2; % idx
for i=1:length(idx)
    figure();
    target = [pack '\' fileList{1,idx(i)}];
    targetImg = imread(target);
    imshow(targetImg)
    disp(fileList{1,idx(i)})
%     delete(target)
    title(fileList{1,idx(i)})
end

%% Black Thresh
close all
idx = find(isoutlier(intAvg,'gesd'))+2;
for i=1:length(idx)
    figure();
    target = [pack '/' fileList{1,idx(i)}];
    imshow(rgb2gray(imread(target)))
    %         delete(target)
    title(fileList{1,idx(i)})
end