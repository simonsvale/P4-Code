function GSCNSweep (rx, captureDuration, ofdmInfo, GSCNInfoFile)  
    fprintf("Performing GSCN sweep!");

    % Supress warning about table.
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    % Read GSCCN info table.
    GSCNInfo = readtable(GSCNInfoFile,TextType='String');
    
    % Create a new table
    GSCNStartRange = GSCNInfo.GSCN_B;

    % Create a table for displaying all GCSN frequencies in the sweep.
    FR1Wave = single(2);
    
    % Loop through all GSCN values, start index is 1 in matlab.
    for index = 1:height(GSCNStartRange)  
        % Set new center frequency based on the GSCN index.
        rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency(GSCNStartRange(index));
        
        % Capture waveform
        waveform = variableSampleCapture(rx, captureDuration);

        % Concatenate
        FR1Wave = cat(1, FR1Wave, waveform(:,1));
    end

    % Display figure
    figure;
    nfft = ofdmInfo.Nfft;
    spectrogram(FR1Wave,ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
    title('FR1 GSCN Spectrogram');
    
    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

end