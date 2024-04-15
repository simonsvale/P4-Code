function output = find_radio(serial_number, gain)
    % Setup the SDR
    rx = hSDRReceiver('B210'); % Set radio type.
    rx.SDRObj.SerialNum = serial_number;
    rx.ChannelMapping = 1; % The antenna number?

    rx.Gain = gain; % Max 76 dBm
    rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.

    output = rx
end