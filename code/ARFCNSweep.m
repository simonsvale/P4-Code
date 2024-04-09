
% Both return values are arrays with same size.
function [SSBFrequencies, msOffset] = ARFCNSweep(rx, ARFCNFile)
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

    % Create empty arrays for storing confirmed SSB frequencies and their periodicity.
    SSBFrequencies = [];
    msOffset = [];

    % Loop through all ARFCN values, start index is 1 in matlab.
    for i = 1:ARFCNLength
        % Convert ARFCN to center frequency.
        rx.CenterFrequency = ARFCN2Frequency( ARFCN(i) );

        % Set subcarrier spacing case from center frequency.
        scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
        scs =  scsOptions(1);

        % Capture waveform
        waveform = variableSampleCapture(rx, captureDuration);
        
        try
            % Attempt to detect the SSBs on the given ARFCN frequencies.
            [SSB, offset] = findSSB(waveform, rx.CenterFrequency, scs, rx.SampleRate, false);
            
            if SSB
                % If an SSB is found add it to the return array.
                SSBFrequencies(end+1) = rx.CenterFrequency;
                msOffset(end+1) = offset;
                
                % Display fig
                scsSSB = hSSBurstSubcarrierSpacing('CASE C');
                ofdmInfo = nrOFDMInfo(20,scsSSB,'SampleRate',rx.SampleRate);
            
                figure;
                nfft = ofdmInfo.Nfft;
                spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
                title('Spectrogram of the Received Waveform');

            else
                disp("No SSB found at "+rx.CenterFrequency);
            end

        catch err
            disp("ERROR: " + err.identifier);
            continue
        end
    end

    % Free memory, does the same as release(), but better.
    delete(rx);
    
    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

end