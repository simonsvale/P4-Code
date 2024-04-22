function transmitJamSignal(tx, waveform)
    % Transmit for the duration of the SSB.
    tic;
    while toc < 0.005
        tx(waveform);
    end

end