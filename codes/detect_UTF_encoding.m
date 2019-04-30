  function [encoding, bytes_per_char, BOM_size, byte2char] = detect_UTF_encoding(FILENAME)
    %detect_UTF_encoding determines which UTF encoding has been used for a
    %file, and returns an encoding name, number of bytes per character,
    %size of the Byte Order Mark used in the file, and a handle to a
    %routine that converts byte vectors to characters taking into account
    %byte swapping
    
    %Written 20160215 by Walter Roberson
    
    %in the below, swapbtyes is used not to "fix" incoming byte orders to the
    %One True Byte Order (namely Big Endian): instead swapbytes is needed to mangle
    %Big Endian to Little Endian because that is what putz Intel architectures use, and
    %all current MATLAB are only supported on Intel architectures
  
    [fid, message] = fopen(FILENAME, 'r');
    if fid < 0
      fprintf(2, 'Failed to open file "%s" because: "%s"\n', FILENAME, message);
      encoding = ''; bytes_per_char = 0; BOM_size = 0; byte2char = @(B) '';
      return
    end

    firstbytes = fread(fid, [1,4], '*uint8');
    fclose(fid);
  
    %we might have requested 4 bytes but that doesn't mean we got all 4
    if length(firstbytes) >= 2 && all(firstbytes(1:2) == [254, 255])   %UTF16BE
      encoding = 'UTF16BE';
      bytes_per_char = 2;
      BOM_size = 2;
      byte2char = @(B) char(swapbytes(typecast(uint8(B), 'uint16')));
    elseif length(firstbytes) >= 4 && all(firstbytes(1:4) == [255, 254, 0, 0])    %UTF32LE
      encoding = 'UTF32LE';
      bytes_per_char = 4;
      BOM_size = 4;
      byte2char = @(B) char(typecast(uint8(B),'uint32'));
      warning('32 bit Unicode detected (UTF32LE); MATLAB only stores 16 bits per character.');
    elseif length(firstbytes) >= 2 && all(firstbytes(1:2) == [255, 254])   %UTF16LE
      encoding = 'UTF16LE';
      bytes_per_char = 2;
      BOM_size = 2;
      byte2char = @(B) char(typecast(uint8(B),'uint16'));
    elseif length(firstbytes) >= 4 && all(firstbytes(1:4) == [0, 0, 254, 255])   %UTF32BE
      encoding = 'UTF32BE';
      bytes_per_char = 4;
      BOM_size = 4;
      byte2char = @(B) char(swapbytes(typecast(uint8(B), 'uint32')));
      warning('32 bit Unicode detected (UTF32BE); MATLAB only stores 16 bits per character');
    elseif length(firstbytes) >= 3 && all(firstbytes(1:3) == [239, 187, 191])    %UTF8
       encoding = 'UTF8';
       bytes_per_char = 1;
       BOM_size = 3;
       byte2char = @(B) char(uint8(B));
    else
       encoding = 'Default';
       bytes_per_char = 1;
       BOM_size = 0;
       byte2char = @(B) char(uint8(B));
    end
  end