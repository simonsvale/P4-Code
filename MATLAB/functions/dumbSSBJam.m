function dumbSSBJam(rx, tx, centerFrequency, duration)
    
    % Check if any SSBs exists on the given center frequency.
    [frequency, ~] = frequencySweep(rx, centerFrequency, 30);
    
    % Check if no SSBs were found.
    if (isempty(frequency))
        disp("No SSBs found on the given frequency.");
        return
    end
    
    % Setup jamming signal.
    sineWaves = dsp.SineWave('Frequency', centerFrequency, ...
    'Amplitude', 1, ...
    'PhaseOffset', 0, ...
    'SampleRate', 10e3 , ...
    'ComplexOutput', 0, ...
    'SamplesPerFrame', 200e3);
    
    % Generation
    waveform = sineWaves();
    waveform = resample(waveform, 1000, tx.MasterClockRate/500);
    
    tx.ChannelMapping = 1;
    tx.LocalOscillatorOffset = 1;
    tx.PPSSource = 'Internal';
    tx.ClockSource = 'Internal';
    tx.InterpolationFactor = 1;
    tx.TransportDataType = 'int16';
    tx.EnableBurstMode = false;
    
    waveform = repmat(waveform, 1, 1);
    
    % Configure transmission, is needed due to the FPGA.
    disp("Configuring transmission!")
    tx.CenterFrequency = centerFrequency;
    
    % Initial pause is needed for the SDR to configure correctly. 
    pause(5);
    tx(waveform);
    pause(5);
    
    disp("Starting transmission!");
    
    % Transmit for the duration in seconds.
    tic;
    while toc < duration
        tx(waveform);
    end
    
    disp("Done Transmitting!");
end


