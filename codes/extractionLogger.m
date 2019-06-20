classdef extractionLogger
    
    properties
        source
        logPath
        logtxtFile
    end
    
    methods
        function obj = extractionLogger(source,logPath)   
            obj.source = source;
            obj.logPath = logPath;
            obj.logtxtFile = [obj.logPath '/' obj.source '.log'];
        end
        function pilotIdx = pilotIdxFinder(obj)
            logfiles = dir(obj.logPath);
            logicLevel = [];
            for idx =1 : length(logfiles)
                split = (strsplit(logfiles(idx).name,'.'));
                logicLevel = [logicLevel (strcmp(char(split(end)),'log'))];
            end
            if sum(logicLevel)
                fid = fopen(obj.logtxtFile, 'rt');
                if fid == -1
                    error('Cannot open file: %s', obj.logtxtFile);
                    return
                end
                scannedText = textscan(fid,'%s','Delimiter','#');
                completeFile = strfind((scannedText{1,1})','completed');
                pilotIdx = sum(~(cellfun('isempty',completeFile)))+3;
            else
                fid = fopen(obj.logtxtFile, 'w');
                pilotIdx = 3;
            end
            fclose(fid);
        end
        function logFilePrint(obj,newLine,stringPrint,tabGap)
            fid = fopen(obj.logtxtFile, 'at+');   %open close in extract.m
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
