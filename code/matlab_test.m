function print_parameter()
    rx = hSDRReceiver('B210'); % Set radio type.
    rx.SDRObj.SerialNum = '8000748';
    rx.ChannelMapping = 1; % The antenna number?
end