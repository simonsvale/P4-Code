rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000758';
rx.ChannelMapping = 1; % The antenna number?