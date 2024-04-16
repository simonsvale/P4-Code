function rx = find_radio(serialNumber, gain)
    % Setup the SDR
    rx = hSDRReceiver('B210'); % Set radio type.
    
    % If a serial number is entered or it is empty.
    switch serialNumber
        case ''
            % Find radio
            radio = findsdru();
            rx.SDRObj.SerialNum = radio(1).SerialNum;
            clear radio;
        otherwise
            rx.SDRObj.SerialNum = serialNumber;
    end

    % Set the rest of the variables.
    rx.ChannelMapping = 1; % The antenna number?

    rx.Gain = gain; % Max 76 dBm
    rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.
end