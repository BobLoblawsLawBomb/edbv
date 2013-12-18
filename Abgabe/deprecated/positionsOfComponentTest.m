function[] = positionsOfComponentTest(path)

    im=imread(path);
    mask=table_mask(im);
    imgMasked=im .* mask;
    [resultBW,resultColor]=connectedComponent(imgMasked);

    J=im;

    for i=1:size(resultBW(:))

       p=getPositionOfComponent(cell2mat(resultBW(:,i)));
       markerInserter = vision.MarkerInserter('Shape','X-Mark','Size',5);
       J=step(markerInserter,J,p);
    end

    imshow(J .* mask)
end
