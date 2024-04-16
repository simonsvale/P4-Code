
% Both return values are arrays with same size.
function [SSBFrequencies, msOffset] = ARFCNSweep(rx, ARFCNFile, captureDurationMiliseconds)
    disp("Performing ARFCN sweep!");

    captureDurationMiliseconds = milliseconds(captureDurationMiliseconds);

    % Supress warning about table.
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    % Read ARFCN values from table.
    ARFCNInfo = readtable(ARFCNFile,TextType='String');
    ARFCN = ARFCNInfo.ARFCN;
    ARFCNLength = height(ARFCN);

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
        waveform = variableSampleCapture(rx, captureDurationMiliseconds);
        
        disp("check 2");
        disp(waveform);
        disp(rx.CenterFrequency);
        disp(class(rx.CenterFrequency));
        disp(scs);
        disp(class(scs));
        disp(rx.SampleRate);
        disp(class(rx.SampleRate));

        try
            % Attempt to detect the SSBs on the given ARFCN frequencies.
            [SSB, offset] = approximateSSBPeriodicity(waveform, rx.CenterFrequency, scs, rx.SampleRate, false);
            
            if SSB
                % If an SSB is found add it to the return array.
                SSBFrequencies(end+1) = rx.CenterFrequency;
                msOffset(end+1) = offset;
                
                
                % Display fig
                ofdmInfo = nrOFDMInfo(20,15,'SampleRate',rx.SampleRate);
                
                figure;
                nfft = ofdmInfo.Nfft;

                spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
                
                plotVar = [];

                for n = 1:milliseconds(captureDurationMiliseconds)/20
                    plotVar(end+1) = offset+20.0*n;
                    plotVar(end+1) = offset-20.0*n;
                end

                hold on;
                plot(plotVar, 0, 'r.', 'MarkerSize', 10);

                plot(offset, 0, 'b.', 'MarkerSize', 10);

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