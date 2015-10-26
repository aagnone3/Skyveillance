clear;close all;clc;

s = serial('COM5');
fprintf('Serial object created\n');
set(s,'BaudRate',9600);
fprintf('Baud rate set\n');
fopen(s);
fprintf('Serial port open\n');
DESIRED_NUM_DATA_POINTS = 20;
cur_num_data_points = 0;
while cur_num_data_points < DESIRED_NUM_DATA_POINTS
    out = fscanf(s);
    if ~isempty(strfind(out, ','))
        cur_num_data_points = cur_num_data_points + 1;
        out
    end
end
fclose(s);
delete(s);
clear s;