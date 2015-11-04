function distance = toDistance(voltage)
    lambda = 3e8 / 2.4e9;
    db_voltage = (voltage / 0.0177) - 89;
    distance = lambda / (4 * pi * 10^((db_voltage - 31.82858)/20));
end