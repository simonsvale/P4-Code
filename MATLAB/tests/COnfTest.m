
[rx, tx] = configureSDR('B210','');

% Jam duration in milliseconds.
smartSSBJam(rx, tx, 2.11585e9, 30);

delete(rx);
delete(tx);


return 
