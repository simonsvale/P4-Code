% start
ofdmMod = comm.OFDMModulator('FFTLength', 16, ...
    'NumGuardBandCarriers', [6;5], ...
    'InsertDCNull', false, ...
    'CyclicPrefixLength', 16, ...
    'Windowing', false, ...
    'OversamplingFactor', 1, ...
    'NumSymbols', 100, ...
    'NumTransmitAntennas', 1, ...
    'PilotInputPort', false);

scs = 30e6;
M = 4; 	 % Modulation order
% input bit source:
in = randi([0 1], 1000, 1);

dataInput = qammod(in, M, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
ofdmInfo = info(ofdmMod);
ofdmSize = ofdmInfo.DataInputSize;
dataInput = reshape(dataInput, ofdmSize);

% Generation
waveform = ofdmMod(dataInput);

Fs = ofdmMod.FFTLength * scs * ofdmMod.OversamplingFactor; 		

masterClockRate = 16000000;
interpolationFactor = 1;
tx = comm.SDRuTransmitter(Platform='B210');
tx.SerialNum = findsdru().SerialNum;
tx.CenterFrequency = 1.230e9;
tx.Gain = 50;
tx.ChannelMapping = 1;
tx.LocalOscillatorOffset = 1;
tx.PPSSource = 'Internal';
tx.ClockSource = 'Internal';
tx.MasterClockRate = masterClockRate;
tx.InterpolationFactor = interpolationFactor;
tx.TransportDataType = 'int16';
tx.EnableBurstMode = false;

waveform = repmat(waveform, 1, 1);

% This is needed, to configure the radio.
pause(5);
disp("Configuring radio!")
tx(waveform);


duration = 10;
disp("transmission started!");

for i = 1:10
    tic;
    while toc < 0.06
    tx(waveform);
    end

    tic;
    while toc < 0.1
    end
end

disp("Transmission stopped!");
release(tx);





