% Generated by MATLAB(R) 23.2 (R2023b) and Communications Toolbox 23.2 (R2023b).
% Generated on: 10-Apr-2024 09:16:11

Fs = 1000; 								 % Specify the sample rate of the waveform in Hz

% Sine Wave configuration
% waveform configuration:
sineWaves = dsp.SineWave('Frequency', 2115850000, ...
    'Amplitude', 1, ...
    'PhaseOffset', 0, ...
    'SampleRate', 50e3 , ...
    'ComplexOutput', 0, ...
    'SamplesPerFrame', 200e3);

% Generation
waveform = sineWaves();

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


masterClockRate = 31e6;
interpolationFactor = 512;
% resample waveform to the radio's sample rate
waveform = resample(waveform, Fs, masterClockRate/500);

usrpTx = comm.SDRuTransmitter(Platform='B210');
usrpTx.SerialNum ='8000758';
usrpTx.CenterFrequency = 2.11585e9;
usrpTx.Gain = 76;
usrpTx.ChannelMapping = 1;
usrpTx.LocalOscillatorOffset = 1;
usrpTx.PPSSource = 'Internal';
usrpTx.ClockSource = 'Internal';
usrpTx.MasterClockRate = masterClockRate;
usrpTx.InterpolationFactor = 1;
usrpTx.TransportDataType = 'int16';
usrpTx.EnableBurstMode = false;

waveform = repmat(waveform, 1, 1);

% Transmit waveform (for 10 sec):
for i = 1:5000
        tic;
        while toc < 0.003
        usrpTx(waveform);
        end
    
        tic;
        while toc < 0.02
        end
    end

fprintf('Transmission stopped.\n')
release(usrpTx);
