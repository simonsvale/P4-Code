function transmitOFDMSignal(tx, waveform, duration, Fs)
    
    % Transmit for the length of the OFDM waveform and the duration.
    t = 0;
    while t<duration
        tx(waveform);
        t = t + length(waveform)/Fs;
    end

end