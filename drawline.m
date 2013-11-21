function [ im_with_line ] = drawline(im, A)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% Source: http://stackoverflow.com/questions/3533843/how-to-draw-a-line-on-an-image-in-matlab
% figure,imshow(im);


%# make sure the image doesn't disappear if we plot something else
% hold on

J = im;

for  ball_nr = 1 : size( A , 3)
    
  % TODO: get correct ball color
  ball_color = [1,0,0];

  pos_frame_from = uint32(A(:, :, ball_nr, 1));
  
  for  frame_nr = 1 : size( A, 4 )

     pos_frame_to = uint32(A(:, :, ball_nr, frame_nr));
     
     x1 = pos_frame_from(1);
     y1 = pos_frame_from(2);
     x2 = pos_frame_to(1);
     y2 = pos_frame_to(2);
     
     %disp(['Frame ',int2str(frame_nr),' Ball ',int2str(ball_nr),' Line from [ ', int2str(x1),', ', int2str(y1),' ] to [', int2str(x2),', ', int2str(y2),' ]']);
     
     % TODO: change to vision plot method
     shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom','CustomBorderColor',ball_color);
     J = step(shapeInserter, J, [x1 y1 x2 y2]);
     
     %plot([pos_frame_from(2),pos_frame_to(2)],[pos_frame_from(1),pos_frame_to(1)],'Color',ball_color,'LineWidth',2);
     
     pos_frame_from = pos_frame_to;

  end
  
end

subplot(1,1,1);
imshow(J);

im_with_line = J;

% saveas(im_with_line, 'plottet.jpg','jpg');

% hold off

end

