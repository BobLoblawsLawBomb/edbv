hVideoSrc = vision.VideoFileReader('res\test.mp4', ...
    'ImageColorSpace', 'Intensity');

hEdge = vision.EdgeDetector( ...
    'Method', 'Roberts', ...
    'ThresholdSource', 'Property', ...
    'Threshold', 15/256, ...
    'EdgeThinning', true);

hAB = vision.AlphaBlender('Operation', 'Highlight selected pixels');

WindowSize = [190 150];
hVideoOrig = vision.VideoPlayer('Name', 'Original');
hVideoOrig.Position = [10 hVideoOrig.Position(2) WindowSize];

hVideoEdges = vision.VideoPlayer('Name', 'Edges');
hVideoEdges.Position = [210 hVideoOrig.Position(2) WindowSize];

hVideoOverlay = vision.VideoPlayer('Name', 'Overlay');
hVideoOverlay.Position = [410 hVideoOrig.Position(2) WindowSize];

while ~isDone(hVideoSrc)
    frame     = step(hVideoSrc);                % Read input video
    edges     = step(hEdge, frame);             % Edge detection
    composite = step(hAB, frame, edges);        % AlphaBlender
    
    step(hVideoOrig, frame);                    % Display original
    step(hVideoEdges, edges);                   % Display edges
    step(hVideoOverlay, composite);             % Display edges overlayed
end

release(hVideoSrc);