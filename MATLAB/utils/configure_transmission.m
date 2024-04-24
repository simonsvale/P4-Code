function tx = configure_transmission(tx, center_frequency, gain)
    tx.CenterFrequency = 1.230e9;
    tx.Gain = gain;
    tx.ChannelMapping = 1;
    tx.LocalOscillatorOffset = 1;
    tx.PPSSource = 'Internal';
    tx.ClockSource = 'Internal';
    tx.MasterClockRate = masterClockRate;
    tx.InterpolationFactor = interpolationFactor;
    tx.TransportDataType = 'int16';
    tx.EnableBurstMode = false;

    waveform = repmat(waveform, 1, 1);

    pause(5);
    disp("Configuring radio!")
    tx(waveform) % This is needed, to avoid the 7 second delay before sending.
end