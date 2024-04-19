% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.

% Get serial number
%radio = findsdru();
%rx.SDRObj.SerialNum = radio(1).SerialNum;

% Reset variable to avoid problems
clear radio;

rx.ChannelMapping = 1; % The antenna number?

rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.

% Convert ARFCN to center frequency.
rx.CenterFrequency = 3.70992e9;

% Set subcarrier spacing case from center frequency.
scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
scs =  scsOptions(1);

% Capture waveform
waveform = variableSampleCapture(rx, milliseconds(60));

nrbSSB = 10; % Number of resource blocks in an SSB
scsNumeric = double(extract(scs,digitsPattern));
ofdmInfo = nrOFDMInfo(nrbSSB,scsNumeric);

% Display spectrogram of received waveform  
figure;
nfft = ofdmInfo.Nfft * 32;
spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
title('Spectrogram of the Received Waveform')




