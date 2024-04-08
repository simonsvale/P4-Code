function GSCNSweep (rx, GSCNInfoFile)  
    disp("Performing GSCN sweep!");

    % Supress warning about table.
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    % Read GSCCN info table.
    GSCNInfo = readtable(GSCNInfoFile,TextType='String');
    
    % Create a new table, containing GSCN start values 
    % and their subcarrier spacing.
    GSCNStartRange = GSCNInfo.GSCN_B;
    GSCNScs = GSCNInfo.CASE;

    % Create a table for displaying all GCSN frequencies in the sweep.
    FR1Wave = single(2);

    GSCNLength = height(GSCNStartRange);
    
    % Set the amount of frames to capture.
    framesPerCapture = 2;
    captureDuration = seconds((framesPerCapture+1)*10e-3);

    nrbSSB = 20; % Number of resource blocks in an SSB 
    
    % Loop through all GSCN values, start index is 1 in matlab.
    for index = 1:GSCNLength  
        % Set new center frequency based on the GSCN index.
        rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency( GSCNStartRange(index) );
       
        % Set subcarrier spacing case.
        scsSSB = hSSBurstSubcarrierSpacing( 'CASE '+GSCNScs(index) );

        % OFDM demodulation information
        ofdmInfo = nrOFDMInfo(nrbSSB,scsSSB,'SampleRate',rx.SampleRate);

        % Capture waveform
        waveform = variableSampleCapture(rx, captureDuration);

        % Concatenate
        FR1Wave = cat(1, FR1Wave, waveform(:,1));
    end


    % Display figure
    figure;
    nfft = ofdmInfo.Nfft * GSCNLength/4;

    spectrogram(FR1Wave,ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
    title('FR1 GSCN Spectrogram');
    
    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

end