% run all offline data
% NOTE comment var "oflFileIdx" in loadOfflineData.m and
% Receiver_SSB_test04.m first

% clc;
clear;
close all;

load rootPath.mat;
% dataDir                = fullfile(rootPath,'.\offlineData\20181018\16qam');
dataDir                = fullfile('C:\Users\hongb\Dropbox\2018_10_25\20181108');

[fileList,fileListNum] = getFileList(dataDir,'.mat');
berArr                 = zeros(fileListNum,1);
QdBArr                 = zeros(fileListNum,1);
EVMArr                 = zeros(fileListNum,1);

for oflFileIdx = 1:fileListNum
    fprintf('%s%d%s%d%s\n','- processing data ',oflFileIdx, ' in ',fileListNum, ' files.');
    runMainOfflineSSB;
%     Receiver_SSB_test04;
    berArr(oflFileIdx) = ber;
    QdBArr(oflFileIdx) = QdB;
    EVMArr(oflFileIdx) = evm;
end