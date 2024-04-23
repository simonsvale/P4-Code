function [rx, tx] = configureSDR(platform, serialNumber)
    % Setup the the receiving and transmitting objects.
    rx = hSDRReceiver(platform); % Super class of comm.SDRuReceiver().
    tx = comm.SDRuTransmitter(Platform=platform);

    % Check if a serial number is provided.
    switch serialNumber
        case ''
            % Find radio.
            SDR = findsdru();

            % Set the serial numbers of the rx and tx objects.
            rx.SDRObj.SerialNum = SDR(1).SerialNum;
            tx.SerialNum = SDR(1).SerialNum;

            % Reset SDR variable.
            clear SDR;
        otherwise
            % Set the serial number to the given string.
            rx.SDRObj.SerialNum = serialNumber;
            tx.SerialNum = serialNumber;
    end

    % Set the default Ssample rate and gain.
    rx.SampleRate = 31e6;
    rx.Gain = 76;
    tx.Gain = 76;

    rx.SDRObj.MasterClockRate = 31e6;
    tx.MasterClockRate = 31e6;

end



