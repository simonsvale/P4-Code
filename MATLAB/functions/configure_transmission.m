function tx_updated = configure_transmission(tx_object, center_frequency, gain)
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

    % This is needed, to configure the radio.
    pause(5);
    disp("Configuring radio!")
    tx(waveform);

    tx_updated = tx
end