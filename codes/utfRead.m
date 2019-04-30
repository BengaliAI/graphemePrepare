function data_cell = utfRead(input_file)
% input_file = 'shuffled.txt';
[file_encoding, bytes_per_char, BOM_size, bytes2char] = detect_UTF_encoding(input_file);
if isempty(file_encoding)
   error('No usable input file');
end
fid = fopen(input_file,'rt');
fread(fid, [1, BOM_size], '*uint8');   %skip the Byte Order Mark
thisbuffer = fgets(fid);
extra = mod(length(thisbuffer), bytes_per_char);
if extra ~= 0
  %in little-endian modes, newline would be found in first byte and the 0's after need to be read
  thisbuffer = [thisbuffer, fread(fid, [1, bytes_per_char - extra], '*uint8')];
end
thisline = bytes2char(thisbuffer);
data_cell = textscan(thisline, '%s', 'delimiter', '\t');   %will ignore the end of lines
header_fields = reshape(data_cell{1}, 1, []);
num_field = length(header_fields);
thisbuffer = fread(fid, [1 inf], '*uint8');
extra = mod(length(thisbuffer), bytes_per_char);
if extra ~= 0
  thisbuffer = [thisbuffer, zeros(1, bytes_per_char - extra, 'uint8')];
end
thisline = bytes2char(thisbuffer);
fmt = repmat('%s', 1, num_field);
data_cell = textscan(thisline, fmt, 'delimiter', '\t');
fclose(fid);
end