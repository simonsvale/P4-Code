function [SSBFrequencies, firstSSBTimestamps, realCaptureTime] = frequencySweep(rx, centerFrequencies, captureDuration)
    
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
        [waveform, timestamp, realCaptureTime] = capture(rx, captureDuration);

        try
            % Attempt to detect the SSBs on the frequencies.
            [SSB, offset] = approximateSSBPeriodicity(waveform, rx.CenterFrequency, scs, rx.SampleRate);
            if SSB
                % If an SSB is found add its frequency to the return array.
                SSBFrequencies(end+1) = rx.CenterFrequency;

                % Add the offset to the timestamp.
                timestamp = datetime(timestamp, 'InputFormat', 'YYYY/mm/dd HH:MM:SS:FFF') + milliseconds(offset);
               
                % Add the correctly offset timestamp to the return array.
                firstSSBTimestamps(end+1) = datenum(timestamp);

            end
        catch err
            disp("ERROR: " + err.identifier);
            continue
        end
    end
    
    % Enable warning again.
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

end