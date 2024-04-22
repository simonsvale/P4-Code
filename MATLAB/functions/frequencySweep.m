function [SSBFrequencies, firstSSBTimestamps] = frequencySweep(rx, centerFrequencies, captureDuration)
    
    % Convert capture duration to milliseconds.
    captureDuration = milliseconds(captureDuration);
    
    % Get amount of center frequencies.
    centerFrequenciesAmount = length(centerFrequencies);
    
    % Capture a small amount to configure the SDR.
    capture(rx, captureDuration);
    
    % Create empty arrays for storing confirmed SSB frequencies and timestamps.
    SSBFrequencies = [];
    firstSSBTimestamps = [];

    % Loop through all given frequencies.
    for i = 1:centerFrequenciesAmount
        
        % Set center frequency of the receiver.
        rx.CenterFrequency = centerFrequencies(i);

        % Set subcarrier spacing case from given center frequency.
        scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
        scs =  scsOptions(1);

        % Capture waveform
        [waveform, timestamp] = capture(rx, captureDuration);

        try
            % Attempt to detect the SSBs on the frequencies.
            [SSB, offset] = approximateSSBPeriodicity(waveform, rx.CenterFrequency, scs, rx.SampleRate, false);
            if SSB
                % If an SSB is found add its frequency to the return array.
                SSBFrequencies(end+1) = rx.CenterFrequency;

                % Add the offset to the timestamp.
                timestamp = datetime(timestamp, 'InputFormat', 'YYYY/mm/dd HH:MM:SS:FFF') + milliseconds(offset);
               
                % Add the correctly offset timestamp to the return array.
                firstSSBTimestamps(end+1) = datenum(timestamp);
                
                %{
                % Fig
                nrbSSB = 10; % Number of resource blocks in an SSB
                scsNumeric = double(extract(scs,digitsPattern));
                ofdmInfo = nrOFDMInfo(nrbSSB,scsNumeric);
                
                % Display spectrogram of received waveform  
                figure;
                nfft = ofdmInfo.Nfft * 32;
                spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
                
                plotVar = [];

                for n = 1:milliseconds(captureDuration)/20
                    plotVar(end+1) = offset+20.0*n;
                    plotVar(end+1) = offset-20.0*n;
                end

                hold on;
                plot(plotVar, 0, 'r.', 'MarkerSize', 10);

                plot(offset, 0, 'b.', 'MarkerSize', 10);

                title('Spectrogram of the Received Waveform');
                %}
            end
        catch err
            disp("ERROR: " + err.identifier);
            continue
        end
    end
    
    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

end