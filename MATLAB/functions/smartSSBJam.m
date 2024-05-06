function smartSSBJam(rx, tx, centerFrequency, duration, OFDM)
    
    subcarriers = 240;
    OFDMSymbols = 16;
    
    if OFDM
        ofdmMod = comm.OFDMModulator('FFTLength', subcarriers, ...
        'NumGuardBandCarriers', [0;0], ...
        'InsertDCNull', false, ...
        'CyclicPrefixLength', 8, ...
        'Windowing', false, ...
        'OversamplingFactor', 1, ...
        'NumSymbols', OFDMSymbols, ...
        'NumTransmitAntennas', 1, ...
        'PilotInputPort', false);
        
        % Modulation order
        M = 4;
    
        % input bit source:
        in = randi([0 1], (2 * subcarriers * OFDMSymbols), 1);
        
        dataInput = qammod(in, M, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
        ofdmInfo = info(ofdmMod);
        ofdmSize = ofdmInfo.DataInputSize;
        dataInput = reshape(dataInput, ofdmSize);
        
        % Get subcarrier spacing
        scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
        scs =  double(extract(scsOptions(1),digitsPattern)) * 1e3;

        % Generation
        waveform = ofdmMod(dataInput);

        Fs = ofdmMod.FFTLength * scs * ofdmMod.OversamplingFactor;

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
    tx.InterpolationFactor = 2;
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
    constantIncrease = 25;
    

    % Get the SSB time duration.
    SSBDuration = constantIncrease*getSSBDuration(centerFrequency);
    
    if OFDM
        transmissionTimer.TimerFcn = @(~,~) transmitOFDMSignal(tx, waveform, SSBDuration, Fs);
        transmissionTimer.TasksToExecute = 10000*floor(duration);
    else
        transmissionTimer.TimerFcn = @(~,~) transmitJamSignal(tx, waveform, SSBDuration);
        transmissionTimer.TasksToExecute = 10000*floor(duration);
    end

    % Get approx time since this function was called.
    configureTime = 5;

    sweepDuration = 30;
    
    % Check if any SSBs exists on the given center frequency.
    [frequency, timestamp, realCaptureTime] = frequencySweep(rx, centerFrequency, sweepDuration);

    % Check if no SSBs were found.
    if (isempty(frequency))
        disp("No SSBs found on the given frequency.");
        return
    end

    % Adjust transmission timing to timestamp.
    transmissionPoint = datenum(datetime(timestamp, 'ConvertFrom', 'datenum') + milliseconds((sweepDuration - realCaptureTime)*(3/2)) + seconds(configureTime));

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














