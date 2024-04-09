% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000748';
rx.ChannelMapping = 1; % The antenna number.

rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.

% Perform GSCN sweep and detect SSB
[SSB, ~] = ARFCNSweep(rx, 'ARFCNDanmark.xlsx');

disp(SSB);
