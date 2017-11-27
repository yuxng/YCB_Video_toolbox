function [seq_ids, frame_ids] = load_dataset_indexes(filename)

fid = fopen(filename, 'r');
C = textscan(fid, '%s');
indexes = C{1};
fclose(fid);

num = numel(indexes);
seq_ids = zeros(num, 1);
frame_ids = zeros(num, 1);

for i = 1:num
    str = indexes{i};
    pos = strfind(str, '/');
    seq_ids(i) = str2double(str(1:pos-1));
    frame_ids(i) = str2double(str(pos+1:end));
end

