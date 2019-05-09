function [ meta ] = metadataExtract( refPath, img, ratio )

if nargin<3
    ratio = 0.3;  % check this ratio with tic omr
end

roi=[0 0 size(img,2) 540];
img=imcrop(img,roi);
metadata_ref = imbinarize(rgb2gray(imread([refPath '/metadataRef.png'])));
metadata_ref=imcrop(metadata_ref,roi);
metadata_ref = imerode(metadata_ref,strel('disk',2));
img = ~imbinarize(rgb2gray(img));
img(~metadata_ref) = 0;
imshowpair(metadata_ref,img)
S = regionprops(metadata_ref,'BoundingBox');
S = cat(1,S.BoundingBox);
%% justify BoundingBox arrangement according to OMR
quantIdx = discretize(S(:,2),4,'IncludedEdge','left'); %% find quantization Idx
for i=1:4
    S(quantIdx==i,2) = mean(S(quantIdx==i,2)); %% quantize the height to mean of bins
end
S = sortrows(S,2);
%% find omr fillups
% % imshow(img)
% % hold on
meta=[];
for i = 1:size(S,1)
    BB = S(i,:);
    %     rectangle('Position',BB,'EdgeColor','r','LineWidth',2)
    %     annotation('textbox',[BB(1)/size(img,2) BB(2)/size(img,1) BB(3)/size(img,2) BB(4)/size(img,1)],'String',num2str(i));
    fillup = sum(sum(imcrop(img,BB)))/(30*30);
    if fillup >ratio
        meta = [meta;i];
    end
    % hold off
end
end