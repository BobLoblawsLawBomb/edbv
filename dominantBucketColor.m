function [ dominantColor ] = dominantBucketColor( img, bucketCount, offset )
%UNTITLED Sortiert jedes faerbige Pixel (schwarze = ausmaskierte Pixel
%werden ignoriert) in einen von bucketCount Buckets ein. Jedes Pixel in
%einem Bucket wir dort als ein Pixel der gleichen Farbe angesehen. Wir
%reduzieren also die Breite des Farbraums auf bucketCount Moeglichkeiten.
%Zurueckgegeben wird das groesste Bucket
%   @author Maximilian Irro

    buckets = zeros(bucketCount);
    
    tableMask = im2bw(img,0.000001);

    hsv = rgb2hsv(img);
    hue = hsv(:,:,1);
    
    % TODO: Wie ist denn die hue der schwarzen ausmaskierten Pixel? Dazu
    % muesse man sich eigentloch das value anschauen um die herauszufiltern
    
    
    % wir bauen uns ein Fenster, mit dem wir die Farben diskriminieren. Die
    % Hue wir zwar meistens zwischen 0-360 Grad angegeben, der Wert liegt
    % aber zwischen [0,1]. Wir muessen also umrechnen. 
    
    windowSize = 1 / bucketCount;
    windowStart = 1-windowSize/2; % Rot ist von ~330-30 Grad
    windowEnd = windowSize/2;
    for b = 1 : bucketCount
       
       if b == 1 % Uebergang zwischen 0/1 muss anders behandelt werden
           colorMask = hue>windowStart | hue<windowEnd; 
       else
           colorMask = hue>windowStart & hue<windowEnd; 
       end
       
       % wir maskieren den Tisch aus (ausmaskierte Pixel = 0 wuerden als Rot
       % klassifiziert werden) und schneiden schliesslich noch alles auf
       % dem Tisch weg was nicht in die Farbklasse passt. Alles was dann
       % ungleich 0 ist ist ein Pixel in unserer Farbklasse
       buckets(b) = nnz( colorMask .* tableMask); 
       
       % jetzt versetzen wir noch das Window auf die naechste Farbklasse
       windowStart = windowStart + windowSize;
       if windowStart > 1
           windowStart = windowStart-1;
       end
       
       windowEnd = windowEnd + windowSize;
       if windowEnd > 1
           windowEnd = windowEnd-1;
       end
    
    end
    
    [colorElementCount, bucketIndex] = max(buckets(:));

    dominantColor = 1/bucketCount * bucketIndex - 1/bucketCount + 0.001;
end

