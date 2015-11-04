clear;close all;clc;

voltages = 1 : .001 : 5;
lambda = 3e8 / 2.4e9;
db_voltages = (voltages ./ 0.0177) - 89;
distances = lambda ./ (4 * pi * 10.^((db_voltages - 31.82858)./20));

plot(voltages, distances)
grid on
xlabel('Voltage [V]')
ylabel('Distance [?]')
title('Distance vs Pin Voltage')
