function transmitJamSignal(tx, waveform, durationSeconds)
    % Transmit for the duration of the SSB in seconds.
    tic;
    while toc < durationSeconds
        tx(waveform);
    end

end