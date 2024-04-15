% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000748';
rx.ChannelMapping = 1; % The antenna number?

rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.

% Setup the SDR also for tx
% tx = comm.SDRuTransmitter(Platform='B210');
% tx.SerialNum ='8000748';
% tx.CenterFrequency = 2450000000;
% tx.Gain = 8;
% tx.ChannelMapping = 1;
% tx.TransportDataType = 'int16';
% tx.EnableBurstMode = false;



% Perform GSCN sweep and detect SSB
[SSB, offset] = ARFCNSweep(rx, 'ARFCNDanmark.xlsx', milliseconds(40));

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



delete(rx);