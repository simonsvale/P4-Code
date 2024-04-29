function smartSSBJam(rx, tx, centerFrequency, duration, OFDM)
    
    tic;
    % Check if any SSBs exists on the given center frequency.
    [frequency, timestamp] = frequencySweep(rx, centerFrequency, 30);

    % Check if no SSBs were found.
    if (isempty(frequency))
        disp("No SSBs found on the given frequency.");
        return
    end
    
    if OFDM
        ofdmMod = comm.OFDMModulator('FFTLength', 240, ...
        'NumGuardBandCarriers', [6;5], ...
        'InsertDCNull', false, ...
        'CyclicPrefixLength', 16, ...
        'Windowing', false, ...
        'OversamplingFactor', 1, ...
        'NumSymbols', 50, ...
        'NumTransmitAntennas', 1, ...
        'PilotInputPort', false);
        
        % Modulation order
        M = 4;
    
        % input bit source:
        in = randi([0 1], 22900, 1);
        
        dataInput = qammod(in, M, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
        ofdmInfo = info(ofdmMod);
        ofdmSize = ofdmInfo.DataInputSize;
        dataInput = reshape(dataInput, ofdmSize);
        
        % Generation
        waveform = ofdmMod(dataInput);

    else
        % Setup jamming signal.
        sineWave = dsp.SineWave('Frequency', centerFrequency, ...
        'Amplitude', 1, ...
        'PhaseOffset', 0, ...
        'SampleRate', 10e3 , ...
        'ComplexOutput', 0, ...
        'SamplesPerFrame', 200e3);
    
        % Generation of signal.
        waveform = sineWave();
        waveform = resample(waveform, 1000, tx.MasterClockRate/500);
    end

    waveform = repmat(waveform, 1, 1);

    % Set rest of transmission settings.
    tx.ChannelMapping = 1;
    tx.LocalOscillatorOffset = 1;
    tx.PPSSource = 'Internal';
    tx.ClockSource = 'Internal';
    tx.InterpolationFactor = 1;
    tx.TransportDataType = 'int16';
    tx.EnableBurstMode = false;
    
    % Configure transmission, is needed due to the FPGA.
    disp("Configuring transmission!")
    tx.CenterFrequency = centerFrequency;
    
    % Initial pause is needed for the SDR to configure correctly. 
    pause(5);
    tx(waveform);
    pause(5);
    
    % Setup tranmission scheduler.
    transmissionTimer = timer;
    transmissionTimer.ExecutionMode = 'fixedRate';
    transmissionTimer.Period = 0.02;
    
    % Needed as the USRP B210, cannot transmit with the desired periodicity.
    constantIncrease = 15;

    % Get the SSB time duration.
    SSBDuration = constantIncrease*getSSBDuration(centerFrequency);

    transmissionTimer.TimerFcn = @(~,~) transmitJamSignal(tx, waveform, SSBDuration);
    transmissionTimer.TasksToExecute = 10000*floor(duration);
    
    % Get approx time since this function was called.
    configureTime = floor(toc);

    % Adjust transmission timing to timestamp.
    transmissionPoint = datenum(datetime(timestamp, 'ConvertFrom', 'datenum') + seconds(configureTime));

    % Wait for the new transmission point.
    while(datenum(clock)<=transmissionPoint)
    end

    % transmit jamming signal.
    start(transmissionTimer);

    disp("Starting transmission!");
    
    % Wait for the jamming to stop.
    pause(duration);

    disp("Done Transmitting!");
    stop(transmissionTimer)

end














