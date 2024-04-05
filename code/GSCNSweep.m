function GSCNSweep (rx, captureDuration, ofdmInfo, GSCNInfoFile)  
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

        figure;
        nfft = ofdmInfo.Nfft;
        spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
        title('Spectrogram of the Received Waveform');

    end
    
    disp("Done!");

end