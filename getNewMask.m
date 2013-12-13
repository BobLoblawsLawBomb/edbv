function [ newMask, resultRaw, searchMask ] = getNewMask( oldPosition, vector, instabilityFactor, im, threshold)
%GETNEWMASK Summary of this function goes here
%   Detailed explanation goes here

    %oldMask3=repmat(uint8(oldMask),[1 1 3]);

    %subplot(1,2,1),subimage(oldMask3 .* im);

    %boundaryPositions=getBoundaryPositionsOfComponent(oldMask);
    
    
    %movedBoundaryPositions=zeros(size(boundaryPositions));

    %J=im;
    
    %oldPosition=getPositionOfComponent(oldMask);
    
    %imageSize=size(im);

%     for i=1:size(boundaryPositions)
% %        disp(boundaryPositions(i,:));
%        movedBoundaryPositions(i,1)=int32(boundaryPositions(i,1)+vector(2));
%        movedBoundaryPositions(i,2)=int32(boundaryPositions(i,2)+vector(1));
% %        J=step(markerInserter,J,int32(boundaryPositions(i,:)));
%     end

    
    newMask = false(size(im));
    
%     for k = 1:length(movedBoundaryPositions)
% %        markerInserter = vision.MarkerInserter('Shape','Circle','Size',1);
% %        J=step(markerInserter,J,int32(movedBoundaryPositions(k,:)));
% %        disp(movedBoundaryPositions(k,:));
%         
%         x=int32(movedBoundaryPositions(k,2));
%         y=int32(movedBoundaryPositions(k,1));
%         
%         if x>0 && x<=imageSize(1) && y>0 && y<=imageSize(2)
%             newMask(x,y)=1;
% 
%         end
%         
%         newMask=bwmorph(newMask,'bridge');
%         newMask=imfill(newMask,4,'holes');
% 
% 
%     end
    
%     newPosition=getPositionOfComponent(newMask);

    newPosition = [oldPosition(1) + vector(1), oldPosition(2) + vector(2)];
    newPositionWithFactor = newPosition;
    newPositionWithFactor(3) = instabilityFactor;
    uint8NewMask = insertShape(uint8(newMask), 'FilledCircle', newPositionWithFactor);
    
    %disp(['oldPos: ',num2str(oldPosition), ' | newPos: ', num2str(newPosition), ' | velocity: ', num2str(vector)]);
    
    newMask = im2bw(uint8NewMask,0.5);
    
    searchMask = newMask;

    newMask3 = repmat(uint8(newMask),[1 1 3]);
    
    J = newMask3 .* im;
   
    [resultBW, resultColor, resultRaw] = connectedComponent(J, threshold);
    
%         
%     disp(size(resultBW));
%     disp(length(resultBW(:)));

    index = length(resultBW(:));    
    d = inf;
    
    if(index > 1)
        for i=1:length(resultBW(:))
            
            pos = getPositionOfComponent(cell2mat(resultBW(i)));
            
            %        disp('iteration: ');
            %        disp(i);
            %
            %        disp(pos);
            %        disp(newPosition);
            %        disp(oldPosition);
            
            newD = sqrt(double((pos(1)-newPosition(1))^2 + (pos(2)-newPosition(2))^2));
            %
            %        disp('new distance');
            %        disp(newD);
            
            if newD < d
                d = newD;
                index = i;
            end
            
        end
    end
    
%     disp('choose index:');
    
%     disp(index);
    %if ~isEmpty(resultBW(:))
    if(index ~= 0)
        newMask = cell2mat(resultBW(index));
    end
    %end

    
    %newMask3=repmat(uint8(newMask),[1 1 3]);
    
    %J=newMask3 .* im;
   
    
%     imshow(J);
     %subplot(1,2,2),subimage(J)
end

