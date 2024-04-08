% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000758';
rx.ChannelMapping = 1; % The antenna number.

%rx.CenterFrequency =  2.11585e9; %3.71e9 %2.11585e9
rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.

GSCNSweep(rx, 'GSCNDataAltered.xlsx');
