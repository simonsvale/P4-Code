function transmitOFDMSignal(tx, waveform, duration, Fs)

    t = 0; % sec
    while t<duration
        tx(waveform);
        t = t + length(waveform)/Fs;
    end

end