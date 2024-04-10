% Generated by MATLAB(R) 23.2 (R2023b) and Communications Toolbox 23.2 (R2023b).
% Generated on: 10-Apr-2024 09:16:11

%% Generating Sine Wave waveform
Fs = 1000; 								 % Specify the sample rate of the waveform in Hz

% Sine Wave configuration
% waveform configuration:
sineWaves = dsp.SineWave('Frequency', 2000000000, ...
    'Amplitude', 1, ...
    'PhaseOffset', 0, ...
    'SampleRate', Fs , ...
    'ComplexOutput', 0, ...
    'SamplesPerFrame', 100 *Fs);

% Generation
waveform = sineWaves();

%% Visualize
% Time Scope
timeScope = timescope('SampleRate', Fs, ...
    'TimeSpanOverrunAction', 'scroll', ...
    'TimeSpanSource', 'property', ...
    'TimeSpan', 0.03);
timeScope(waveform);
release(timeScope);

% Spectrum Analyzer
spectrum = spectrumAnalyzer('SampleRate', Fs);
spectrum(waveform);
release(spectrum);


%% Transmit waveform over the air
masterClockRate = 5000000;
interpolationFactor = 512;
% resample waveform to the radio's sample rate
waveform = resample(waveform, Fs, masterClockRate/interpolationFactor);

usrpTx = comm.SDRuTransmitter(Platform='B210');
usrpTx.SerialNum ='8000748';
usrpTx.CenterFrequency = 2450000000;
usrpTx.Gain = 8;
usrpTx.ChannelMapping = 1;
usrpTx.LocalOscillatorOffset = 1;
usrpTx.PPSSource = 'Internal';
usrpTx.ClockSource = 'Internal';
usrpTx.MasterClockRate = masterClockRate;
usrpTx.InterpolationFactor = interpolationFactor;
usrpTx.TransportDataType = 'int16';
usrpTx.EnableBurstMode = false;

waveform = repmat(waveform, 1, 1);

% Transmit waveform (for 10 sec):
stopTime = 10; % sec
t = 0; % sec
while t<stopTime
    usrpTx(waveform);
    t = t + length(waveform)/Fs;
end

fprintf('Transmission stopped.\n')
release(usrpTx);
