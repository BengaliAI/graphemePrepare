% img = scanned/ref image for determining centroid
% S1 = struct of centroid position

function S1 = markerCentroids2( img, Centroid_Threshold, FilledImage_Threshold, ratio )
    if nargin<2
      Centroid_Threshold = 4500;
      FilledImage_Threshold = 4500;
      ratio = 0.8;
    end
    img = rgb2gray(img);
    img = medfilt2(img,[5,5]);
    bwc = imbinarize(img);
    BW1 = bwareaopen(~bwc, Centroid_Threshold);
    CC = bwconncomp(BW1);
    S1 = regionprops(CC,'Centroid');
    BW2 = bwareaopen(~bwc, FilledImage_Threshold);
    CC = bwconncomp(BW2);
    SFI = regionprops(CC,'FilledImage');
    Noise_row = [];
    for x = 1: numel(SFI)
        [uv,~,idx] = unique(SFI(x).FilledImage);
        n = accumarray(idx(:),1);
        black_ratio(x) = n(2)/(n(1)+n(2))
        if black_ratio(x)< ratio
           Noise_row = [Noise_row x]; 
        end
    end
    S1(Noise_row) = [];
    
%if you want to see centroid position uncomment this section
%    figure
%    imshow(bwc); 
%    hold on;
%    for x = 1: numel(S1)
%        plot(S1(x).Centroid(1),S1(x).Centroid(2),'go');
%    end
end

