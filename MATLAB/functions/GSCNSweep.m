function GSCNSweep (rx, GSCNInfoFile)  
    disp("Performing GSCN sweep!");

    % Supress warning about table.
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    % Read GSCCN info table.
    GSCNInfo = readtable(GSCNInfoFile,TextType='String');
    
    % Create a new table, containing GSCN start values,
    % GSCN end values and subcarrier spacing cases.
    GSCNStartRange = GSCNInfo.GSCN_B;
    GSCNEndRange = GSCNInfo.GSCN_E;
    GSCNScs = GSCNInfo.CASE;

    % Create a table for displaying all GCSN frequencies in the sweep.
    % FR1Wave = single(2);

    GSCNLength = height(GSCNStartRange);
    
    % Set the amount of frames to capture.
    framesPerCapture = 2;
    captureDuration = seconds((framesPerCapture+1)*10e-3);

    nrbSSB = 20; % Number of resource blocks in an SSB 
    
    % Set default subcarrier spacing.
    scs = "15 kHz";
    
    % Loop through all GSCN values, start index is 1 in matlab.
    for i = 1:GSCNLength  
        % Set subcarrier spacing case.

        % Get GSCN subcarrier spacing, if not case A.
        switch GSCNScs(i)
           case 'B'
                scs = "30 kHz";

           case 'C'
                scs = "30 kHz";
        end

        for n = GSCNStartRange(i):GSCNEndRange(i)
            % Set detection options
            rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency( n );

            % Capture waveformll
            waveform = variableSampleCapture(rx, captureDuration);

            
            % Detect SSBs
            try
                detectedSSB = findSSB(waveform,rx.CenterFrequency,scs,rx.SampleRate);
            catch err
                disp("ERROR: " + err.identifier);
                continue
            end
        end

        % Concatenate (Legacy)
        % FR1Wave = cat(1, FR1Wave, waveform(:,1));
    end

    %{
    % Display figure
    figure;
    nfft = ofdmInfo.Nfft * GSCNLength/4;
    
    spectrogram(FR1Wave,ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
    title('FR1 GSCN Spectrogram');
    %}

    % Free memory, but better than release()
    delete(rx);
    
    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

end