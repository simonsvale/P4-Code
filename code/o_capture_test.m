% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000758';
rx.ChannelMapping = 1; % The antenna number.

%rx.CenterFrequency =  2.11585e9; %3.71e9 %2.11585e9
rx.Gain = 76; % Max 76 dBm
rx.SampleRate = 31e6; % max ~41 MHz, theoretically 61.44 MHz.

GSCN = 6432; % 5290 ~ 2.11585e9 GHz.
rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency(GSCN);

scsOptions = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
scs =  scsOptions(1);


nrbSSB = 20; % Number of resource blocks in an SSB
scsNumeric = double(extract(scs,digitsPattern));
%ofdmInfo = nrOFDMInfo(nrbSSB,scsNumeric);

scsSSB = hSSBurstSubcarrierSpacing('CASE B');
ofdmInfo = nrOFDMInfo(nrbSSB,scsSSB,'SampleRate',rx.SampleRate);

framesPerCapture = 2;
captureDuration = seconds((framesPerCapture+1)*10e-3);

GSCNSweep(rx, captureDuration, 'GSCNData.xlsx');

return % Test

% Capture waveform
waveform = variableSampleCapture(rx, captureDuration);


% Detect SSBs
fprintf("Detecting SSBs" + newline);
try
    detectedSSB = findSSB(waveform,rx.CenterFrequency,scs,rx.SampleRate);
catch err
    fprintf("ERROR: " + err.identifier);
    delete(rx);
    return
end

% Display spectrogram of received waveform
figure;
nfft = ofdmInfo.Nfft;
spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
title('Spectrogram of the Received Waveform');

% Free memory, but better than release()
delete(rx);


