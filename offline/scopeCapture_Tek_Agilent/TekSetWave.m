function TekSetWave(instr, data, destName)
    
    %fprintf(instr,[':head 0;:dele:wave ' destName ';:data:dest ' destName ';:data:start 1']);
    fprintf(instr,[':head 0;:data:dest ' destName ';:data:start 1']);
    
    dataSize = length(data);
    dataSizeStr = num2str(dataSize);
    ymin = min(data);
    ymax = max(data);
    yScaleF = (ymax - ymin ) / 250.0;
    if yScaleF == 0.0
        if ymax == 0.0
            yScaleF = 1;
        else
            yScaleF = ymax / 250.0;
        end;
    end;
    
    %xZ = str2num(query(instr,'WFMOUTPRE:XZERO?')); 
    %sI = str2num(query(instr,'WFMOUTPRE:XINCR?'));
    %iT = str2num(query(instr,'WFMOUTPRE:PT_OFF?'));
    %ymult = str2num(query(instr,'WFMOUTPRE:YMULT?'));
    %yoff = str2num(query(instr,'WFMOUTPRE:YOFF?'))
    %yzero = str2num(query(instr,'WFMOUTPRE:YZERO?'));
    %flushinput(instr);
    
    fprintf(instr,':WFMINPRE:BYT_NR 1;BIT_NR 8;ENCDG BIN;BN_FMT RP;BYT_OR MSB');
    %fprintf(instr,[':WFMINPRE:NR_PT ' dataSizeStr ';XINCR ' num2str(sI) ';XZERO ' num2str(xZ) ';PT_OFF ' num2str(iT) ';YMULT ' num2str(yScaleF) ';YZERO ' num2str(yzero) ';NR_FR 1']);
    fprintf(instr,['CURVE #' num2str(length(dataSizeStr)) dataSizeStr]);
    dataByte = uint8((data - ymin) / yScaleF);
    fwrite(instr,dataByte,'uint8');
    fwrite(instr,char(10),'char');
    flushoutput(instr);
    
    fprintf(instr,[':select:' destName ' 1']);
return;