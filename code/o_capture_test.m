% Setup the SDR
rx = hSDRReceiver('B210'); % Set radio type.
rx.SDRObj.SerialNum = '8000748';
rx.ChannelMapping = 1; % The antenna number.

rx.CenterFrequency =  2.11585e9; %3.71e9 %2.11585e9
rx.Gain = 76; % Max 76 dBm

rx.SampleRate = 61.4e6; % max ~39MHz
% Morten: max sample rate på radio AAU126327 er 32kHz
% --> Hvis ErrOverflowInBurstMode Overflow occured in middle of a contiguous
% burst., sæt SampleRate ned

%GSCN = 7791;
%rx.CenterFrequency = hSynchronizationRasterInfo.gscn2frequency(GSCN);


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
try
    waveform = capture(rx,captureDuration);
    [warning_message, warning_id] = lastwarn;

    switch warning_id
        case 'sdru:SDRuReceiver:ReceiveUnsuccessful'
            fprintf("[ERROR] Receive unsuccessful, terminating!" + newline);
            delete(rx);
            return
    end
catch err
        fprintf("ERROR: "+err.identifier);
        delete(rx);
        return
end


% Detect SSBs
fprintf("Detecting SSBs" + newline);
try
    detectedSSB = findSSB(waveform,rx.CenterFrequency,scs,rx.SampleRate);
catch E2
    fprintf("ERROR: " + E2.identifier);
    delete(rx);
end

% Plot wave
fprintf("Plotting wave" + newline);
plot = spectrumAnalyzer;
plot.Title = "Received signal";
plot(waveform);

% Display spectrogram of received waveform
figure;
nfft = ofdmInfo.Nfft;
spectrogram(waveform(:,1),ones(nfft,1),0,nfft,'centered',rx.SampleRate,'yaxis','MinThreshold',-130);
title('Spectrogram of the Received Waveform');

% Free memory, but better than release()
delete(rx);

