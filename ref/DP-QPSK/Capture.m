flag=1;DPOSymbolRate=12.5e9;

for iLoop=1:200
    [streamX,streamY]=waveform(flag,DPOSymbolRate);%–≈∫≈ªÒ»°
    streamX=streamY;
    ROP='_40';
    filename1=['dataRx\ROP',ROP,'dBm_',num2str(iLoop),'X.mat'];
    save(filename1,'streamX');
    iLoop
end
