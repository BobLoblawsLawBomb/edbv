video_path = ['..',filesep,'res',filesep,'test.mp4'];
videoReader = vision.VideoFileReader(video_path,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
converter = vision.ImageDataTypeConverter; 
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form';
opticalFlow.ReferenceFrameSource = 'Input port';
shapeInserterLine = vision.ShapeInserter('Shape','Lines','BorderColor','Custom', 'CustomBorderColor', 255);
videoPlayer = vision.VideoPlayer('Name','Motion Vector');

frame = step(videoReader);
lastim = step(converter, frame);

while ~isDone(videoReader)
    frame = step(videoReader);
    im = step(converter, frame);
    of = step(opticalFlow, im, lastim);
    lines = videooptflowlines(of, 30);
    %xv = real(of);
    %yv = imag(of);
    vof = abs(of);
    vimg = mat2gray(vof);
    imshow(vimg);
    if ~isempty(lines)
      out =  step(shapeInserterLine, im, lines); 
      step(videoPlayer, out);
    end
    lastim = im;
end

release(videoPlayer);
release(videoReader);