
% Error_decision = blob_error( scanned_blob )
function [ Error_decision ] = BWblobThrash( scanned_blob )
    Error_decision = false;
    bwc = imbinarize(rgb2gray(scanned_blob));
    vertical_bwc_sum = sum(sum((bwc),1)); 
%     horizontal_bwc_sum = sum(sum((bwc),2));
    vertical_inv_bwc_sum = sum(sum((~bwc),1)); 
%     horizontal_inv_bwc_sum = sum(sum((~bwc),2));
    if vertical_bwc_sum == 0 | vertical_inv_bwc_sum == 0
        Error_decision = true; %true for error
    end
end

