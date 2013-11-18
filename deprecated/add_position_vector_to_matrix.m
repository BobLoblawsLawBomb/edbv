function [vectorMatrix] = add_position_vector_to_matrix( ball, frame, positionVector, vectorMatrix)
%add_position_vector_to_matrix Adds the position vector to the matrix
%   @author Florian Krall

velocityVector = get_velocity_vector(ball, frame, vectorMatrix);
vectorMatrix(:,:,ball,frame) = [positionVector(1) positionVector(2) velocityVector(1) velocityVector(2)]; % Position

end