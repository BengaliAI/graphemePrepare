classdef Logs
    
    properties
        logfiles
        files
    end
    
    methods
        function validiFileIdx = txtCheck(obj)
            logicLevel = [];
            for idx =1 : length(obj.logfiles)
                split = (strsplit(obj.logfiles(idx).name,'.'));
                logicLevel = [logicLevel (strcmp(char(split(end)),'txt'))];
                validiFileIdx = find(logicLevel,1);
            end   
        end
        function obj = Logs(logfiles,files)   
            obj.logfiles = logfiles;
            obj.files = files;
        end
        function pilotIdx = pilotIdxFinder(obj,logtxtFile)
            fid = fopen(logtxtFile, 'rt');
            if fid == -1
                error('Cannot open file: %s', obj.files);
                return
            end
            scannedText = textscan(fid,'%s','Delimiter','#');
            completeFile = strfind((scannedText{1,1})','completed');
            pilotIdx = sum(~(cellfun('isempty',completeFile)))+1;
            fclose(fid);
        end
        function logFilePrint(obj,logtxtFile,newLine,stringPrint,tabGap)
            fid = fopen(logtxtFile, 'at+');   %open close in extract.m
            if newLine
                fprintf(fid, '\n');
            end
            fprintf(fid, '%s',stringPrint);
            if tabGap
                fprintf(fid, '    #');
            end
            fclose(fid);
        end
    end
    
end
