function [components_img, labelCount] = ccl_labeling( bw_img )

    runlengthTable = ccl_runLengthLabeling( bw_img );
    runlengthTable = ccl_bottomUpLabeling( runlengthTable );
    [components_img, labelCount] = ccl_labelNormalisation(runlengthTable, bw_img);

end