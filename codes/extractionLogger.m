classdef extractionLogger
    
    properties
        source
        logPath
        logtxtFile
    end
    
    methods
        function self = extractionLogger(source,logPath)   
            self.source = source;
            self.logPath = logPath;
            self.logtxtFile = [self.logPath '/' self.source '.log'];
        end
        function pilotIdx = pilotIdxFinder(self)
            logfiles = dir(self.logPath);
            logicLevel = [];
            for idx =1 : length(logfiles)
                split = (strsplit(logfiles(idx).name,'.'));
                logicLevel = [logicLevel (strcmp(char(split(end)),'log'))];
            end
            if sum(logicLevel)
                fid = fopen(self.logtxtFile, 'rt');
                if fid == -1
                    error('Cannot open file: %s', self.logtxtFile);
                    return
                end
                scannedText = textscan(fid,'%s','Delimiter','#');
                completeFile = strfind((scannedText{1,1})','completed');
                pilotIdx = sum(~(cellfun('isempty',completeFile)))+3;
            else
                fid = fopen(self.logtxtFile, 'w');
                pilotIdx = 3;
            end
            fclose(fid);
        end
        function logFilePrint(self,newLine,stringPrint,tabGap)
            fid = fopen(self.logtxtFile, 'at+');   %open close in extract.m
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
