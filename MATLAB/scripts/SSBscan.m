% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000758';
rx.ChannelMapping = 1; % The antenna number.
rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 41e6; % max ~41 MHz, theoretically 61.44 MHz.

% Define frequency range to scan in MHz
frequency_start = 450; % MHz (Start of FR1 bands)
frequency_end = 6000; % MHz (End of FR1 bands)
frequency_spacing = 56; % MHz
frequencies = frequency_start:frequency_spacing:frequency_end; % Create an array of frequencies

% Loop over the frequencies
for frequency_MHz = frequencies
    fprintf("Scanning frequency: %d MHz\n", frequency_MHz);
    rx.CenterFrequency = frequency_MHz * 1e6; % Convert MHz to Hz

    scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
    scs = scsOptions(1);

    nrbSSB = 20; % Number of resource blocks in an SSB

    scsSSB = hSSBurstSubcarrierSpacing('CASE B');
    ofdmInfo = nrOFDMInfo(nrbSSB,scsSSB,'SampleRate',rx.SampleRate);

    framesPerCapture = 2;
    captureDuration = seconds((framesPerCapture+1)*10e-3);

    % Capture waveform
    waveform = variableSampleCapture(rx, captureDuration);

    % Detect SSBs
    fprintf("Detecting SSBs\n");
    try
        detectedSSB = findSSB(waveform,rx.CenterFrequency,scs,rx.SampleRate);
        
        % Check if any SSBs are detected
        if ~isempty(detectedSSB)
            % Display spectrogram of received waveform only if SSBs are
            % detected (not working)
            figure;
            nfft = ofdmInfo.Nfft;
            spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
            title(sprintf('Spectrogram of the Received Waveform - Frequency: %d MHz', frequency_MHz));
        else
            fprintf("No SSBs detected for frequency: %d MHz\n", frequency_MHz);
        end
    catch err
        fprintf("ERROR: " + err.identifier + "\n");
    end
end

% Free memory, better than release()
delete(rx);
