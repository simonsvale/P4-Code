
[rx, tx] = configureSDR('B210','');

% Jam duration in milliseconds.
smartSSBJam(rx, tx, 2.11585e9, 150);

release(tx);
release(rx);


return 
