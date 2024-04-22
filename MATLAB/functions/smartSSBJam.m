function smartSSBJam(rx, tx, centerFrequency, duration)
    
    tic;
    % Check if any SSBs exists on the given center frequency.
    [frequency, timestamp] = frequencySweep(rx, centerFrequency, 60);
    
    % Check if no SSBs were found.
    if (isempty(frequency))
        disp("No SSBs found on the given frequency.");
        return
    end

    % Setup jamming signal.
    waveSampleRate = 10000;

    fmcwWaveform = phased.FMCWWaveform('SampleRate', 10000, ...
    'SweepTime', 0.005, ...
    'SweepBandwidth', 100000, ...
    'SweepDirection', 'Triangle', ...
    'SweepInterval', 'Positive', ...
    'NumSweeps', 1);

    % Generation
    waveform = fmcwWaveform();
    
    % Configure transmission, is needed due to the FPGA.
    disp("Configuring transmission!")
    tx.CenterFrequency = centerFrequency;

    pause(5);
    tx(waveform);
    pause(5);
    
    % Get approx time since function run.
    configureTime = floor(toc);

    % Adjust transmission timing to timestamp.
    transmissionPoint = datetime(timestamp, 'ConvertFrom', 'datenum') + seconds(configureTime+5);

    % Wait for the new transmission point.
    while(datetime(clock,'Format','uuuu-MM-dd HH:mm:ss.SSS')<=transmissionPoint)
    end
    
    %DEBUG
    %disp("Timestamp: "+datestr(timestamp,'YYYY/mm/dd HH:MM:SS:FFF'));
    %disp("SendTime: "+datestr(clock,'YYYY/mm/dd HH:MM:SS:FFF'));

    for i = 1:duration
        tic;
        while toc < 0.01
        tx(waveform);
        end
    
        tic;
        while toc < 0.02
        end
    end

    disp("Done Transmitting!");

end














