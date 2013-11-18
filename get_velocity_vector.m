function [ velocityVector ] = get_velocity_vector( ball, frame, vectorMatrix )
%get_velocity_vector returns the velocity vector for the given ball and the given frame
%   @author Florian Krall

velocityVector = [0 0];	% default value for velocity
s = size(vectorMatrix);

if (ball <= s(5) && frame <= s(6) )
	vec = vectorMatrix(:,:,:,:,ball,frame);
	velocityVector = [vec(3) vec(4)];
end

end