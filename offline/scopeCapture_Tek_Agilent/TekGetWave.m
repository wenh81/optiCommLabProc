function [data, sI, xZ, iT] = TekGetWave(instr, srcName)
    clear fastA;
    clear data;
    
    fastA = query(instr, ':head 0;:fasta?');
    if fastA(1) == '1'
        fprintf(instr,':fasta:state 0');
        %pause 0.05
    end;
    
    horizLen = str2num(query(instr,':HOR:RECORD?'));
    fprintf(instr,':data:width 1;encod rib');
    fprintf(instr,[':DATA:SOU ' srcName ';START ' num2str(1) ';STOP ' num2str(horizLen)]);
    fprintf(instr,':CURVE?');
    
    header = fscanf(instr,'%s',2);
    header1 = fscanf(instr,'%s',str2num(header(2)));

    [data,count] = fread(instr,horizLen,'int8');
    Curveterminator = fread(instr,1,'char');

    % get x zero
    xZ = str2num(query(instr,'WFMOUTPRE:XZERO?'));
    % get the sampling interval 
    sI = str2num(query(instr,'WFMOUTPRE:XINCR?'));
    % get the trigger point within the record
    iT = str2num(query(instr,'WFMOUTPRE:PT_OFF?'));
    ymult = str2num(query(instr,'WFMOUTPRE:YMULT?'));
    yoff = str2num(query(instr,'WFMOUTPRE:YOFF?'));
    yzero = str2num(query(instr,'WFMOUTPRE:YZERO?'));

    % scale the data to the correct values
    data = ymult*(data - yoff) - yzero;

flushinput(instr);
flushoutput(instr);
return;