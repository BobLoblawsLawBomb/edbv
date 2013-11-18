function [ im_with_line ] = drawline(im, A)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% Source: http://stackoverflow.com/questions/3533843/how-to-draw-a-line-on-an-image-in-matlab
% figure,imshow(im);


%# make sure the image doesn't disappear if we plot something else
% hold on

J = im;

for  ball_nr = 1:size( A , 3)
    
  % TODO: get correct ball color
  ball_color=[1,0,0];

  pos_frame_from = A(:, :, ball_nr, 1)
  
  for  frame_nr = 2:size( A, 4 )

     pos_frame_to = A(:, :, ball_nr, frame_nr);
    
     % TODO: change to vision plot method
     shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom','CustomBorderColor',ball_color);
     J = step(shapeInserter, im,
     
     %plot([pos_frame_from(2),pos_frame_to(2)],[pos_frame_from(1),pos_frame_to(1)],'Color',ball_color,'LineWidth',2);
     
     pos_frame_from = pos_frame_to;

  end
  
end

imshow(J)
% saveas(im_with_line, 'plottet.jpg','jpg');

% hold off

end

