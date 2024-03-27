% Setup the SDR
radioOptions = hSDRBase.getDeviceNameOptions;
rx = hSDRReceiver(radioOptions(10)); % B210
antennaOptions = getAntennaOptions(rx);
rx.ChannelMapping = antennaOptions(1);
rx.Gain = 8;


fr1BandInfo = hSynchronizationRasterInfo.FR1DLOperatingBand;
syncRasterInfo = hSynchronizationRasterInfo.SynchronizationRasterFR1;
band = "n77";
bandRasterInfo = syncRasterInfo.(band);

useCustomCenterFrequency = false;
GSCN = 7791;
if useCustomCenterFrequency
    rx.CenterFrequency =  3520e6; %#ok<*UNRCH>
else
    rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency(GSCN);
end

scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
scs =  scsOptions(1);


nrbSSB = 20; % Number of resource blocks in an SSB
scsNumeric = double(extract(scs,digitsPattern));
ofdmInfo = nrOFDMInfo(nrbSSB,scsNumeric);
rx.SampleRate = ofdmInfo.SampleRate;

framesPerCapture = 1;
captureDuration = seconds((framesPerCapture+1)*10e-3);

fprintf("Capturing wave" + newline);
waveform = capture(rx,captureDuration);
%detectedSSB = findSSB(waveform,rx.CenterFrequency,scs,rx.SampleRate);

fprintf("Plotting wave" + newline);
plot = spectrumAnalyzer;
plot.Title = "Received signal";
plot(waveform);

% Free memory?
release(rx);





