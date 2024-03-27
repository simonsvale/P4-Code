
function o_capture_wave(rx, waveform, scs)

% Set parameters
SampleRate = rx.SampleRate;
CenterFrequency = rx.CenterFrequency;
MinChannel = hSynchronizationRasterInfo.getMinimumBandwidth(scs,rx.CenterFrequency);

% Save waveform
save("capture.mat","waveform","SampleRate", "CenterFrequency", "MinChannel");

end