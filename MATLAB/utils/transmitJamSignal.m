function transmitJamSignal(tx, waveform, durationSeconds)
    % Transmit for the duration of the SSB.
    tic;
    while toc < durationSeconds
        tx(waveform);
    end

end