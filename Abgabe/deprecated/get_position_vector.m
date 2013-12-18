function [ positionVector ] = get_position_vector( ball, frame, vectorMatrix )
%get_position_vector returns the position vector for the given ball and the given frame
%   @author Florian Krall

positionVector = [0 0];	% default value for position
s = size(vectorMatrix);

if (ball <= s(5) && frame <= s(6) )
	vec = vectorMatrix(:,:,ball,frame);
	positionVector = [vec(1) vec(2)];
end

end