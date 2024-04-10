% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000758';
rx.ChannelMapping = 1; % The antenna number?

rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.

% Perform GSCN sweep and detect SSB
[SSB, offset] = ARFCNSweep(rx, 'ARFCNDanmark.xlsx');

% DEBUG
disp("Center frequency [GHz]: ");
for i = 1:length(SSB)

    disp(SSB(i));

end

disp("Height. "+height(SSB));

disp("Timing offset [ms]: ");
for i = 1:length(SSB)
    
    disp(offset(i));

end
