function [ newMask ] = getNewMask( oldMask, vector, instabilityFactor, im)
%GETNEWMASK Summary of this function goes here
%   Detailed explanation goes here

    subplot(1,2,1),subimage(oldMask)

    boundaryPositions=getBoundaryPositionsOfComponent(oldMask);
    
    
    movedBoundaryPositions=zeros(size(boundaryPositions));

    J=im;
    
    imageSize=size(im);

    for i=1:size(boundaryPositions)
%        disp(boundaryPositions(i,:));
       movedBoundaryPositions(i,1)=int32(boundaryPositions(i,1)+vector(1));
       movedBoundaryPositions(i,2)=int32(boundaryPositions(i,2)+vector(2));
%        J=step(markerInserter,J,int32(boundaryPositions(i,:)));
    end

    
    newMask=false(size(oldMask));
    
    for k = 1:length(movedBoundaryPositions)
%        markerInserter = vision.MarkerInserter('Shape','Circle','Size',1);
%        J=step(markerInserter,J,int32(movedBoundaryPositions(k,:)));
%        disp(movedBoundaryPositions(k,:));
        
        x=movedBoundaryPositions(k,2);
        y=movedBoundaryPositions(k,1);
        
        if x>0 && x<=imageSize(1) && y>0 && y<=imageSize(2)
            newMask(x,y)=1;

        end
        
        newMask=bwmorph(newMask,'bridge');
        newMask=imfill(newMask,4,'holes');
        
      

        grow(x+1,y,0);
        grow(x,y+1,0);
        grow(x-1,y,0);
        grow(x,y-1,0);

    end
    
    
    function [ ] = grow(x,y,counter)
       if counter < instabilityFactor && x>0 && x<=imageSize(1) && y>0 && y<=imageSize(2)
          
          newMask(x,y)=1;
          
          grow(x+1,y, counter+1);
          grow(x,y+1, counter+1);
          grow(x-1,y, counter+1);
          grow(x,y-1, counter+1);
         
       end
    end

    
    newMask3=repmat(uint8(newMask),[1 1 3]);
    
    disp(size(newMask3));
    disp(size(im));
    
    J=newMask3 .* im;
    
    [resultBW, resultColor]=connectedComponent(J);
    
    newMask=cell2mat(resultBW(1));
    
    subplot(1,2,2),subimage(newMask)
end

