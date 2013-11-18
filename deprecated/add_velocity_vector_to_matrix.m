function [vectorMatrix] = add_velocity_vector_to_matrix( ball, frame, velocityVector, vectorMatrix)
%add_velocity_vector_to_matrix Adds the velocity vector to the matrix
%   @author Florian Krall

positionVector = get_position_vector(ball, frame, vectorMatrix);
vectorMatrix(:,:,ball,frame) = [positionVector(1) positionVector(2) velocityVector(1) velocityVector(2)]; % Velocity

end