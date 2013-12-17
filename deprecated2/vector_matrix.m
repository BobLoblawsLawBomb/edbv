function [ vectorMatrix ] = create_matrix( )
%create_matrix creates the matrix that stores the vectors for position and velocity
%   @author Florian Krall

%create the vector matrix
vectorMatrix = [0 0 0 0]; % Position and Velocity of Ball 1 in Frame 1

end

function add_velocity_vector_to_matrix( ball, frame, velocityVector)
%add_velocity_vector_to_matrix Adds the velocity vector to the matrix
%   @author Florian Krall

positionVector = get_position_vector(ball, frame)
vectorMatrix(:,:,:,:,ball,frame) = [positionVector(1) positionVector(2) velocityVector(1) velocityVector(2)]; % Velocity

end

function add_position_vector_to_matrix( ball, frame, positionVector)
%add_position_vector_to_matrix Adds the position vector to the matrix
%   @author Florian Krall

velocityVector = get_velocity_vector(ball, frame)
vectorMatrix(:,:,:,:,ball,frame) = [positionVector(1) positionVector(2) velocityVector(1) velocityVector(2)]; % Position

end

function [ positionVector ] = get_position_vector( ball, frame )
%get_position_vector returns the position vector for the given ball and the given frame
%   @author Florian Krall

positionVector = [0 0];	% default value for position
size = size(vectorMatrix);

if (ball <= size(5) && frame <= size(6) )
	vec = vectorMatrix(:,:,:,:,ball,frame)
	positionVector = [vec(1) vec(2)]
end

end

function [ velocityVector ] = get_velocity_vector( ball, frame )
%get_velocity_vector returns the velocity vector for the given ball and the given frame
%   @author Florian Krall

velocityVector = [0 0];	% default value for velocity
size = size(vectorMatrix);

if (ball <= size(5) && frame <= size(6) )
	vec = vectorMatrix(:,:,:,:,ball,frame)
	positionVector = [vec(3) vec(4)]
end

end