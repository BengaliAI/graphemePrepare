function [meta] = metadataExtract(refPath,img,disp)
if nargin<3
    disp=false;
end
roi=[0 0 size(img,2) 540];
img=imcrop(img,roi);
metadata_ref = imbinarize(rgb2gray(imread([refPath '/metadataRef.png'])));
metadata_ref=imcrop(metadata_ref,roi);
metadata_ref = imerode(metadata_ref,strel('disk',2));
img = ~imbinarize(rgb2gray(img));
img(~metadata_ref) = 0;
S = regionprops(metadata_ref,'BoundingBox');
S = cat(1,S.BoundingBox);
%% justify BoundingBox arrangement according to OMR
bins = discretize(S(:,2),4,'IncludedEdge','left'); %% quantization bins
for i=1:4
    S(bins==i,2) = mean(S(bins==i,2)); %% quantize to mean
end
S = sortrows(S,2);
%% find omr fillups
fillup=[];
for i = 1:size(S,1)
    %     rectangle('Position',BB,'EdgeColor','r','LineWidth',2)
    %     annotation('textbox',[BB(1)/size(img,2) BB(2)/size(img,1) BB(3)/size(img,2) BB(4)/size(img,1)],'String',num2str(i));
    fillup = [fillup;sum(sum(imcrop(img,S(i,:))))/(30*30)];
end
if disp
    figure;
    imshowpair(metadata_ref,img)
    hold on
end
meta = [];
for i = 1:size(S,1)
    if fillup(i) > mean(fillup)
        meta = [meta;i];
        if disp
            rectangle('Position',S(i,:),'EdgeColor','r','LineWidth',2)
        end
    end
end
hold off
end