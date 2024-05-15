% FMCW configuration
fmcwWaveform = phased.FMCWWaveform('SampleRate', 10000, ...
    'SweepTime', 0.01, ...
    'SweepBandwidth', 100000, ...
    'SweepDirection', 'Triangle', ...
    'SweepInterval', 'Positive', ...
    'NumSweeps', 1);

% Generation
waveform = fmcwWaveform();

Fs = 10000; 		

masterClockRate = 5000000;
interpolationFactor = 500;
usrpTx = comm.SDRuTransmitter(Platform='B210');
usrpTx.SerialNum ='8000758';
usrpTx.CenterFrequency = 2.11585e9;
usrpTx.Gain = 76;
usrpTx.ChannelMapping = 1;
usrpTx.LocalOscillatorOffset = 1;
usrpTx.PPSSource = 'Internal';
usrpTx.ClockSource = 'Internal';
usrpTx.MasterClockRate = masterClockRate;
usrpTx.InterpolationFactor = interpolationFactor;
usrpTx.TransportDataType = 'int16';
usrpTx.EnableBurstMode = false;

waveform = repmat(waveform, 1, 1);

% This is needed, to configure the radio.
pause(5);
disp("Configuring radio!")
usrpTx(waveform);
    

periodicity = 0.02;
times = 5000;

disp("transmission started!");

for i = 1:times
    tic;
    while toc < 0.01
    usrpTx(waveform);
    end

    tic;
    while toc < periodicity
    end
end

fprintf('Transmission stopped.\n')
release(usrpTx);