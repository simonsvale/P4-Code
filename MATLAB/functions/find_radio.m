function [rx, tx] = find_radio(serialNumber)
    % Setup the SDR-objects
    rx = hSDRReceiver('B210'); % Set radio type.
    tx = comm.SDRuTransmitter(Platform='B210');

    % If a serial number is entered or it is empty.
    switch serialNumber
        case ''
            % Find radio
            radio = findsdru();
            rx.SDRObj.SerialNum = radio(1).SerialNum;
            tx.SerialNum = radio(1).SerialNum;
            clear radio;
        otherwise
            rx.SDRObj.SerialNum = serialNumber;
            tx.SerialNum = serialNumber;
    end
    rx.SampleRate = 31e6;
    rx.Gain = 76;
    tx.Gain = 76;
end