function status = scheduledTransmission(centerFrequency, waveSampleRate, duration)
    
    % 2.11585e9, 40000, 0.01

    % Generation
    if (waveSampleRate < 9800)
        status = 1;
        return
    end
    

    % Generate sine wave for transmission.
    disp("Generating sine wave!");

    sineWave = dsp.SineWave('Frequency', centerFrequency, ...
        'Amplitude', 1, ...
        'PhaseOffset', 1, ...
        'SampleRate', waveSampleRate , ...
        'ComplexOutput', 0, ...
        'SamplesPerFrame', duration * waveSampleRate);
    
    waveform = sineWave();

    tx = comm.SDRuTransmitter(Platform='B210');
    tx.SerialNum = findsdru().SerialNum;
    tx.CenterFrequency = 2.11585e9;
    tx.Gain = 76;
    tx.ChannelMapping = 1;
    tx.LocalOscillatorOffset = 1;
    tx.PPSSource = 'Internal';
    tx.ClockSource = 'Internal';
    %tx.MasterClockRate = masterClockRate;
    tx.InterpolationFactor = 1;
    tx.TransportDataType = 'int16';
    tx.EnableBurstMode = false;
    
    % This is needed, to configure the radio.
    pause(5);
    disp("Configuring transmission!")
    tx(waveform);
    
    
    periodicity = 0.02;
    times = 100;
    
    disp("transmission started!");
    
    for i = 1:times
        tic;
        while toc < 0.01
        tx(waveform);
        end
    
        tic;
        while toc < periodicity
        end
    end
    
    disp("Transmission stopped!");
    release(tx);


end


