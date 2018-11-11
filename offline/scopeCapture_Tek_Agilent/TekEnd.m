% End TekVISA for TDS5000/6000/7000/8000 ...
function TekEnd(instr)
fclose(instr);
delete(instr);
return;