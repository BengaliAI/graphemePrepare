% in main 
% label = []
% label_cell = num2cell(label)
% label=metadataExtract(refPath,aligned_img,ratio) #aligned_img=rec of surf
% label_cell{end+1} = label


function [ label ] = metadataExtract( refPath, aligned_img, ratio )
    
    if nargin<3
      ratio = 0.3;  % check this ratio with tic omr
    end
    
    img=imcrop(aligned_img,[115 185 1900-115 540-185]);
%     figure
%     imshow(img)
    metadata_ref = imread([refPath '/metadataRef.png']);
    metadata_ref=imcrop(metadata_ref,[115 185 1900-115 540-185]);
%     figure
%     imshow(metadata_ref)
    omr = ~imbinarize(rgb2gray(img));
    omr = bwareaopen(omr,800);
    CC = bwconncomp(omr);
    L = labelmatrix(CC);
    s_omr = regionprops(CC,'Extent');
    omr = ismember(L, find([s_omr.Extent] >= .7));
    s_omr = regionprops(omr,'Centroid','BoundingBox');
    metadata_omr = imbinarize(rgb2gray(metadata_ref));
    CC = bwconncomp(metadata_omr);
    L = labelmatrix(CC);
    s_metadata_omr = regionprops(CC,'Extent');
    metadata_omr = ismember(L, find([s_metadata_omr.Extent] >= .7));
    s_metadata_omr = regionprops(metadata_omr,'Centroid','BoundingBox');
    label = [];
    for i = 1:numel(s_metadata_omr)
        omr_circles = imcrop(img, s_metadata_omr(i).BoundingBox);
        omr_circles = imbinarize(rgb2gray(omr_circles));
        [uv,~,idx] = unique(omr_circles);
        n = accumarray(idx(:),1);
        black_ratio(i) = n(1)/(n(1)+n(2));
        if black_ratio(i)> ratio
            label = [label i];
        end
%         figure
%         imshow(omr_circles)
%         axis on
    end
end

