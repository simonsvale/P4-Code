% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000758';
rx.ChannelMapping = 1; % The antenna number.
% antennaOptions = getAntennaOptions(rx);

rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 39e6; % max ~39MHz
rx.CenterFrequency =  2.11585e9; %3.71e9 %2.11585e9


fr1BandInfo = hSynchronizationRasterInfo.FR1DLOperatingBand;
syncRasterInfo = hSynchronizationRasterInfo.SynchronizationRasterFR1;
band = "n78";
bandRasterInfo = syncRasterInfo.(band);


scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
scs =  scsOptions(1);


nrbSSB = 20; % Number of resource blocks in an SSB
scsNumeric = double(extract(scs,digitsPattern));
%ofdmInfo = nrOFDMInfo(nrbSSB,scsNumeric);

scsSSB = hSSBurstSubcarrierSpacing('CASE B');
ofdmInfo = nrOFDMInfo(nrbSSB,scsSSB,'SampleRate',rx.SampleRate);

framesPerCapture = 2;
captureDuration = seconds((framesPerCapture+1)*10e-3);

% Capture wave
fprintf("Capturing wave" + newline);
waveform = capture(rx,captureDuration);

% Detect SSBs
fprintf("Detecting SSBs" + newline);
detectedSSB = findSSB(waveform,rx.CenterFrequency,scs,rx.SampleRate);

% Plot wave
fprintf("Plotting wave" + newline);
plot = spectrumAnalyzer;
plot.Title = "Received signal";
plot(waveform);

% Free memory?
release(rx);

% Display spectrogram of received waveform
figure;
nfft = ofdmInfo.Nfft;
spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
title('Spectrogram of the Received Waveform')

