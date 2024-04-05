function GSCNSweep (rx, captureDuration, ofdmInfo, GSCNInfoFile)  
    % Supress warning about table.
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    % Read GSCCN info table.
    GSCNInfo = readtable(GSCNInfoFile,TextType='String');
    
    % Create a new table
    GSCNStartRange = GSCNInfo.GSCN_B;

    % Create a table for displaying all frequencies in FR1.
    FR1Wave = single(2);
    
    % Loop through all GSCN values, start index is 1 in matlab.
    for index = 1:height(GSCNStartRange)  
        % Set new center frequency based on the GSCN index.
        rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency(GSCNStartRange(index));
        
        % Capture waveform
        waveform = variableSampleCapture(rx, captureDuration);
        
        % Capture wave
        AuxWave = waveform(:,1);

        % Concatenate
        FR1Wave = cat(1, FR1Wave, AuxWave);
    end

    % Display figure
    figure;
    nfft = ofdmInfo.Nfft;
    spectrogram(FR1Wave,ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
    title('FR1 GSCN Spectrogram');
    

    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
    
    disp("Done!");

end