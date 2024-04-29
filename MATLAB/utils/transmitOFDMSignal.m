function transmitOFDMSignal(tx, waveform)

    t = 0; % sec
    while t<stopTime
        tx(waveform);
        t = t + length(waveform)/Fs;
    end

end