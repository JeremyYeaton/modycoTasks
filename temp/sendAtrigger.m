ioObj = io64;
status = io64(ioObj)
address = hex2dec('4FD8'); 
data_out=255;
io64(ioObj,address,data_out); % send a signal
%%
data_out=0;
io64(ioObj,address,data_out); % stop sending a signal
clear io64;