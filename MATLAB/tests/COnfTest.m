
[rx, tx] = configureSDR('B210','');
rx.SampleRate = 31e6;
rx.CenterFrequency = 2.11585e9;

% Jam duration in milliseconds.
smartSSBJam(rx, tx, 2.11585e9, 30, true);

%waveform = capture(rx, milliseconds(40));

%options = hSynchronizationRasterInfo.getSCSOptions(rx.CenterFrequency);
%scs = options(1);

%extractPRACH(waveform, rx.CenterFrequency, scs, rx.SampleRate);

delete(rx);
delete(tx);


return 
