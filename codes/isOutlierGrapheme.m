function Error_decision = isOutlierGrapheme(scanned_blob)
    Error_decision = false;
    bwc = im2bw(rgb2gray(scanned_blob));
    vertical_bwc_sum = sum(sum((bwc),1));
%     horizontal_bwc_sum = sum(sum((bwc),2));
    vertical_inv_bwc_sum = sum(sum((~bwc),1));
%     horizontal_inv_bwc_sum = sum(sum((~bwc),2));
    if vertical_bwc_sum < 10 || vertical_inv_bwc_sum < 10
        Error_decision = true;
    end
end
