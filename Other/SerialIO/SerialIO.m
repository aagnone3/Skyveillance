s = serial('COM6');
set(s,'BaudRate',9600);
fopen(s);
while 1==1
    out = fscanf(s);
    if ~isempty(strfind(out, ','))
        out
    end
end
fclose(s)
delete(s)
clear s