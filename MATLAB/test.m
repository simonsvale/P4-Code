%% Generating OFDM waveform
% OFDM configuration
ofdmMod = comm.OFDMModulator('FFTLength', 240, ...
    'NumGuardBandCarriers', [0;0], ...
    'InsertDCNull', false, ...
    'CyclicPrefixLength', 4, ...
    'Windowing', false, ...
    'OversamplingFactor', 1, ...
    'NumSymbols', 4, ...
    'NumTransmitAntennas', 1, ...
    'PilotInputPort', false);

simons = ofdmMod.FFTLength * 2 * ofdmMod.NumSymbols;
disp("RandInput Simons formula:" + simons);
scs = 15000;
M = 4; 	 % Modulation order
% input bit source:
in = randi([0 1], simons, 1);

dataInput = qammod(in, M, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
ofdmInfo = info(ofdmMod);
ofdmSize = ofdmInfo.DataInputSize;
dataInput = reshape(dataInput, ofdmSize);

% Generation
waveform = ofdmMod(dataInput);

Fs = ofdmMod.FFTLength * scs * ofdmMod.OversamplingFactor; 								 % Specify the sample rate of the waveform in Hz


%% Transmit waveform over the air
masterClockRate = 7200000;
interpolationFactor = 2;
usrpTx = comm.SDRuTransmitter(Platform='B210');
usrpTx.SerialNum ='8000748';
usrpTx.CenterFrequency = 2115850000;
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

disp("Starting");

% Transmit waveform (for 10 sec):
stopTime = 0.1; % sec

usrpTx(waveform);
pause(3);
disp("Jamming");

tic;
while toc < 20
    t = 0; % sec
    while t<stopTime
        usrpTx(waveform);
        t = t + length(waveform)/Fs;
    end
    pause(0.1);
end

fprintf('Transmission stopped.\n')
release(usrpTx);
