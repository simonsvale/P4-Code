
% Both return values are arrays with same size.
function [LocatedSSBFrequencies, periodicity] = ARFCNSweep(rx, ARFCNFile)
    disp("Performing ARFCN sweep!");

    % Supress warning about table.
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    % Read ARFCN values from table.
    ARFCNInfo = readtable(ARFCNFile,TextType='String');
    ARFCN = ARFCNInfo.ARFCN;
    ARFCNLength = height(ARFCN);

    % Set the amount of frames to capture.
    framesPerCapture = 2;
    captureDuration = seconds((framesPerCapture+1)*10e-3);

    nrbSSB = 20; % Number of resource blocks in an SSB 
    
    % Loop through all ARFCN values, start index is 1 in matlab.
    for i = 1:ARFCNLength
        % Convert ARFCN to center frequency.
        rx.CenterFrequency = ARFCN2Frequency( ARFCN(i) );

        % Set subcarrier spacing case from center frequency.
        scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
        scs =  scsOptions(1);

        % Capture waveform
        waveform = variableSampleCapture(rx, captureDuration);
        
        % Detect SSBs
        try
            SSB = findSSB(waveform,rx.CenterFrequency,scs,rx.SampleRate);
            
            if SSB 
                disp("SSB");
            else
                disp("No SSB")
            end

        catch err
            disp("ERROR: " + err.identifier);
            continue
        end
    end

    % Free memory, but better than release()
    delete(rx);
    
    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

end