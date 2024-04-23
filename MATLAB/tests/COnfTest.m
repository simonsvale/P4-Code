
[rx, tx] = configureSDR('B210','');

% Jam duration in milliseconds.
dumbSSBJam(rx, tx, 2.11585e9, 30);

delete(rx);
delete(tx);


return 
