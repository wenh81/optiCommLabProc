% Test how to divide the phase-folded LMS data
close all;

% phase compensation using ML algorithm
pnCompMLParmsQP.bypass     = 0;
aux                    = modem.qammod( 4 );
modFormatStrTmp        = strsplit(aux.Type);
modFormat              = strcat(num2str(aux.M),'-',modFormatStrTmp{1});
pnCompMLParmsQP.modFormat  = modFormat;
pnCompMLParmsQP.constScale = rms(aux.Constellation);
pnCompMLParmsQP.blkLen     = 6;

% input signal normalized
postEqSigOut  = lmsDdEqualizer(crSigOut,postLmsParms);
pfSigIn = postEqSigOut(:);
pfSigIn = pfSigIn/rms(pfSigIn)*dsp.constScale;
dataLen = length(pfSigIn);

% rotation stardard constellaton
NangleTmp = 64;
hNangle   = floor(NangleTmp/2);
% rotPhiArr = [-hNangle:1:hNangle]/2/hNangle * pi/2;
rotPhiArr = [0:NangleTmp]/NangleTmp/2 * pi/2;
Nangle    = length(rotPhiArr);

% init 16-QAM index for stardard constellation of dsp.const
constIndex = zeros(length(dsp.const),1);

rotRefConstStatics    = dsp.const/rms(dsp.const)*dsp.constScale;
[~,outerRefConstIdx]   = find(abs(rotRefConstStatics).^2 == abs(3+1i*3)^2);
weightOuterDist        = 1.0;
weightDmin             = ones(dataLen,1);


dMinArr   = zeros(2*hNangle+1,1);
rotCenterIdxArr        = zeros(dataLen,Nangle);
rotCenterTmpArr        = zeros(dataLen,Nangle);
rotSigTmpArr           = zeros(dataLen,Nangle);
rotSigRmsArr           = zeros(Nangle,1);
for angleIdx = 1:Nangle
    rotPhi    = rotPhiArr(angleIdx);
    rotRefConst  = rotRefConstStatics;
    
    %% re-calc index
    % calc angles and hard decision
    rxAngle                = angle(rotRefConst);
    rxAngleQ1Idx           = find(rxAngle<=pi/2 & rxAngle>0);
    rxAngleQ2Idx           = find(rxAngle<=pi & rxAngle>pi/2);
    rxAngleQ3Idx           = find(rxAngle<=-pi/2 & rxAngle>-pi);
    rxAngleQ4Idx           = find(rxAngle<=0 & rxAngle>-pi/2);
    % gen const index
    constIndex(rxAngleQ1Idx) = 1;
    constIndex(rxAngleQ2Idx) = 2;
    constIndex(rxAngleQ3Idx) = 3;
    constIndex(rxAngleQ4Idx) = 4;
    % constellation in each Qua
    cnstQ1                 = rotRefConst(rxAngleQ1Idx);
    cnstQ2                 = rotRefConst(rxAngleQ2Idx);
    cnstQ3                 = rotRefConst(rxAngleQ3Idx);
    cnstQ4                 = rotRefConst(rxAngleQ4Idx);
    % rotation center
    rotCenterQ1            = mean(cnstQ1);
    rotCenterQ2            = mean(cnstQ2);
    rotCenterQ3            = mean(cnstQ3);
    rotCenterQ4            = mean(cnstQ4);
    rotCenterArr           = [rotCenterQ1;rotCenterQ2;rotCenterQ3;rotCenterQ4];
    %%
    
    % rotation
    rotRefConst(rxAngleQ1Idx) = (rotRefConst(rxAngleQ1Idx) - rotCenterQ1) ...
        * exp(1i * rotPhi) + rotCenterQ1;
    rotRefConst(rxAngleQ2Idx) = (rotRefConst(rxAngleQ2Idx) - rotCenterQ2) ...
        * exp(1i * rotPhi) + rotCenterQ2;
    rotRefConst(rxAngleQ3Idx) = (rotRefConst(rxAngleQ3Idx) - rotCenterQ3) ...
        * exp(1i * rotPhi) + rotCenterQ3;
    rotRefConst(rxAngleQ4Idx) = (rotRefConst(rxAngleQ4Idx) - rotCenterQ4) ...
        * exp(1i * rotPhi) + rotCenterQ4;

    % expand rotRefConst
    rotRefConstArr         = repmat(rotRefConst, dataLen, 1);
    % calc distance
    pfSigInTmp             = repmat(pfSigIn, 1, length(rotRefConst));
    d                      = pfSigInTmp - rotRefConstArr;
    dAbs                   = abs(d);
    [dmin, didx]           = min(dAbs,[],2);
    %     ofst                   = abs(d)./abs(rotRefConstArr);
    %     [dmin, didx]           = min(ofst,[],2);
    weightIdx              = [];
    for idx = 1:length(outerRefConstIdx)
        weightIdx          = [ weightIdx; find(didx == outerRefConstIdx(idx))];
    end
    weightIdx              = sort(weightIdx);
    weightDmin(weightIdx)  = weightOuterDist;
    dMinArr(angleIdx)      = mean(dmin .* weightDmin);
    rotCenterIdx           = constIndex(didx);
    rotCenterIdxArr(:,angleIdx) = rotCenterIdx;
    rotCenterTmp           = rotCenterArr(rotCenterIdx);
    rotCenterTmpArr(:,angleIdx) = rotCenterTmp;
    
    % save rotated signal
    pfSigScale             = pfSigIn - rotCenterTmp;
    rotSigTmpArr(:,angleIdx) = pfSigScale * exp(-1i*rotPhi) + rotCenterTmp;
    rotSigTmpRep       = repmat(rotSigTmpArr(:,angleIdx),1,length(rotRefConst));
    refSigTmp          = repmat(rotRefConstStatics,dataLen,1);
    deltaTmp           = abs(rotSigTmpRep - refSigTmp);
    [delta,idx]        = min(deltaTmp,[],2);
    rotSigRmsArr(angleIdx) = rms(delta) ./ rms(rotRefConstStatics(idx));
    
    %%
    % signal divide
    slcQ1                  = pfSigIn(rotCenterIdxArr(:,angleIdx)==1);
    slcQ2                  = pfSigIn(rotCenterIdxArr(:,angleIdx)==2);
    slcQ3                  = pfSigIn(rotCenterIdxArr(:,angleIdx)==3);
    slcQ4                  = pfSigIn(rotCenterIdxArr(:,angleIdx)==4);
    %     figName = 'Constellation slicer';
    %     close(findobj('Name',figName));
    %     figure('Name',figName,'Position',[scrsz(3)*3/4 scrsz(4)*5/9 scrsz(3)/4 scrsz(4)/3]);
    figure(3001)
    clf;
    plot(pfSigIn,'.')
    hold on;
    plot(slcQ1,'.r');
    plot(slcQ2,'.k');
    plot(slcQ3,'.m');
    plot(slcQ4,'.g');
    hold on;
    %rotPhi                 = estiPhi;%rotPhiArr(2);
    cnstQ1 = (rotRefConst(rxAngleQ1Idx) - rotCenterQ1) * exp(1i * rotPhi) + rotCenterQ1;
    cnstQ2 = (rotRefConst(rxAngleQ2Idx) - rotCenterQ2) * exp(1i * rotPhi) + rotCenterQ2;
    cnstQ3 = (rotRefConst(rxAngleQ3Idx) - rotCenterQ3) * exp(1i * rotPhi) + rotCenterQ3;
    cnstQ4 = (rotRefConst(rxAngleQ4Idx) - rotCenterQ4) * exp(1i * rotPhi) + rotCenterQ4;
    plot([cnstQ1(:);cnstQ2(:);cnstQ3(:);cnstQ4(:)],'+b','LineWidth',10);
    grid on;
    hold off;
end

%
[dMinSum, idxRotCenter] = min(dMinArr);
rotCenter               = rotCenterTmpArr(:,idxRotCenter);

% assuming estiphi
estiPhi                = rotPhiArr(idxRotCenter);
pfSigScale             = pfSigIn - rotCenter;
method                 = 1;
switch method
    case 1
        % method 1
        pfSigOutTmp   = pfSigScale .* exp(-1i*estiPhi);
        pfSigOut      = pfSigOutTmp + rotCenter;
        % method 2
    case 2
        pfSigOutTmp    = phaseNoiseCompML(pfSigScale,pnCompMLParmsQP);
        pfSigOut       = pfSigOutTmp + rotCenter;
    case 3
        phi            = pi/4;
        pfSigOutTmp    = phaseNoiseComp(pfSigScale*exp(1i*phi)) * exp(-1i*phi);
        pfSigOut       = pfSigOutTmp + rotCenter;
    otherwise
        error('un-supported method');
end

% PN and LMS
% pfSigOutTmp2           = lmsDdEqualizer(pfSigOut,postLmsParms);
pfSigOutLastTmp        = phaseNoiseCompML(pfSigOut,dsp.pnCompMLParms);
pfSigOutLast        = pfLmsEqualizer16QAM(pfSigOutLastTmp, dsp);


%% plot figures
scrsz = get(0,'ScreenSize');
% original
figName = 'Constellation before PF';
close(findobj('Name',figName));
figure('Name',figName,'Position',[1 scrsz(4)*5/9 scrsz(3)/4 scrsz(4)/3]);
plot(pfSigIn,'.')
hold on;
plot(dsp.const*dsp.constScale,'+r','LineWidth',10);
grid on;

% rotation
figName = 'Constellation wi rotation';
rotPhi                 = estiPhi;
cnstQ1 = (rotRefConst(rxAngleQ1Idx) - rotCenterQ1) * exp(1i * rotPhi) + rotCenterQ1;
cnstQ2 = (rotRefConst(rxAngleQ2Idx) - rotCenterQ2) * exp(1i * rotPhi) + rotCenterQ2;
cnstQ3 = (rotRefConst(rxAngleQ3Idx) - rotCenterQ3) * exp(1i * rotPhi) + rotCenterQ3;
cnstQ4 = (rotRefConst(rxAngleQ4Idx) - rotCenterQ4) * exp(1i * rotPhi) + rotCenterQ4;

close(findobj('Name',figName));
figure('Name',figName,'Position',[1 scrsz(4)*1/7 scrsz(3)/4 scrsz(4)/3]);
plot(pfSigIn,'.')
hold on;
plot(cnstQ1,'+r','LineWidth',10);
plot(cnstQ2,'ko','LineWidth',10);
plot(cnstQ3,'ms','LineWidth',10);
plot(cnstQ4,'g^','LineWidth',10);
grid on;

% signal divide
slcQ1                  = pfSigIn(rotCenterIdxArr(:,idxRotCenter)==1);
slcQ2                  = pfSigIn(rotCenterIdxArr(:,idxRotCenter)==2);
slcQ3                  = pfSigIn(rotCenterIdxArr(:,idxRotCenter)==3);
slcQ4                  = pfSigIn(rotCenterIdxArr(:,idxRotCenter)==4);
figName = 'Constellation slicer';
close(findobj('Name',figName));
figure('Name',figName,'Position',[scrsz(3)*3/4 scrsz(4)*5/9 scrsz(3)/4 scrsz(4)/3]);
clf;
plot(pfSigIn,'.')
hold on;
plot(slcQ1,'.r');
plot(slcQ2,'.k');
plot(slcQ3,'.m');
plot(slcQ4,'.g');
hold on;
rotPhi                 = estiPhi;%rotPhiArr(2);
cnstQ1 = (rotRefConst(rxAngleQ1Idx) - rotCenterQ1) * exp(1i * rotPhi) + rotCenterQ1;
cnstQ2 = (rotRefConst(rxAngleQ2Idx) - rotCenterQ2) * exp(1i * rotPhi) + rotCenterQ2;
cnstQ3 = (rotRefConst(rxAngleQ3Idx) - rotCenterQ3) * exp(1i * rotPhi) + rotCenterQ3;
cnstQ4 = (rotRefConst(rxAngleQ4Idx) - rotCenterQ4) * exp(1i * rotPhi) + rotCenterQ4;
plot([cnstQ1(:);cnstQ2(:);cnstQ3(:);cnstQ4(:)],'+b','LineWidth',10);
grid on;
hold off;

% BPS output
figure(4);
clf;
plot(pfSigOut,'.')
hold on;
plot(dsp.const*dsp.constScale,'+r','LineWidth',10);
grid on;

% BPS wi Eq output
figure(5);
clf;
plot(pfSigOutLastTmp,'.')
hold on;
plot(dsp.const*dsp.constScale,'+r','LineWidth',10);
grid on;

figure(6);
clf;
plot(pfSigOutLast,'.')
hold on;
plot(dsp.const*dsp.constScale,'+r','LineWidth',10);
grid on;