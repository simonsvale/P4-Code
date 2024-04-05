function GSCNSweep (rx, captureDuration, GSCNInfoFile)  
    % Read GSCCN info table.
    GSCNInfo = readtable(GSCNInfoFile,TextType='String');
    
    % Create a new table
    GSCNStartRange = GSCNInfo.GSCN_B;
    
    % Loop through all GSCN values, start index is 1 in matlab.
    for index = 1:height(GSCNStartRange)  
        % Set new center frequency based on the GSCN index.
        rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency(GSCNStartRange(index));
        
        % Capture waveform
        waveform = variableSampleCapture(rx, captureDuration);

    end
    
    disp("Done!");

end