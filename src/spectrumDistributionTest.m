function output = spectrumDistributionTest(axHandle, directoryName,segLInMs, thL, thH, maxN)
% output = spectrumDistributionTest(axHandle, directoryName,segLInMs, thL, thH, maxN)
% This function shows spectral level distribution in 1/3 octave width
% Arguments
%   axHandle       : handle to axis of a figure
%   directoryName  : stging of directory name or a structure with field
%     name         : filename string
%   segLInMs       : level check segment length in ms
%   thL            : theleshold probability for silent segment definition
%   thH            : theleshold probability for voiced segment definition
%   maxN           : maximum number of lines to plot
% Output
%   output         : structure with the following field
%     elapsedTime  : total time elapsed in this function (s)
%
% Licence
% Copyright 2022 Hideki Kawahara
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

startTic = tic;
if isstruct(directoryName)
    JSUTcorpus = directoryName.pathName;
    fileList.name = directoryName.fileName;
    directoryName = JSUTcorpus;
else
    JSUTcorpus = directoryName;
    tmpfileList = dir(JSUTcorpus + "*.*");
    fileList = audiofileSelector(tmpfileList);
end
if isempty(fileList)
    disp('no wav file found.')
    output = [];
    return;
end
nFilesTrue = length(fileList);
ii = 1;
fullPath = JSUTcorpus + string(fileList(ii).name);
[~, fs] = audioread(fullPath);
nSegLength = round(fs*segLInMs/1000);
w = nuttallwin(nSegLength);
w = w/sqrt(sum(w.^2));
%fx = (0:nSegLength-1)'/nSegLength*fs;
%figure;
%set(gcf, 'Position', [1046         497         774         393])
fxOct = 20*2 .^(0:1/48:log2(fs/2/20))';
fxOctL = fxOct*2^(-1/6);
fxOctH = fxOct*2^(1/6);
fftl = 2^(ceil(log2(nSegLength))+4);
fxw = (0:fftl-1)'/fftl*fs;
nFiles = min(nFilesTrue, maxN);
hold(axHandle, 'off');
alphaV = min(1, 20/nFiles);
randomIndex = 1:nFilesTrue;
[~, idxSrt] = sort(rand(nFilesTrue,1));
randomIndex = randomIndex(idxSrt);
wf = weightingFilter('A-weighting',fs);
tt = (1:nSegLength)'/fs;
xsin = sin(2*pi*1000*tt);
for ii = 1:nFiles
    idx = randomIndex(ii);
    fullPath = JSUTcorpus + string(fileList(idx).name);
    [x2, fs] = audioread(fullPath);
    x = x2(:,1);
    nSegment = floor(length(x)/nSegLength);
    levels = zeros(nSegment,2);
    properOnes = 0;
    y = wf(x);
    for jj = 1:nSegment
        tmpLvl = 20*log10(std(x((jj-1)*nSegLength + (1:nSegLength))));
        if ~isnan(tmpLvl) && ~isinf(tmpLvl)
            properOnes = properOnes + 1;
            tmpLvl = 20*log10(std(y((jj-1)*nSegLength + (1:nSegLength))));
            levels(properOnes, :) = [tmpLvl jj];
        end
    end
    levels = levels(1:properOnes, :);
    nSegment = properOnes;
    [~, sortedIdx] = sort(levels(:,1));
    pw1kMax = abs(fft(xsin .* w,fftl)) .^2;
    sum1kMax = sum(pw1kMax)/2;
    if nFiles > 1
        idVoice = levels(sortedIdx(min(nSegment, round(thH*nSegment))),2);
        voiceSeg = x((idVoice-1)*nSegLength + (1:nSegLength));
        idSilent = levels(sortedIdx(max(1, round(thL*nSegment))),2);
        silentSeg = x((idSilent-1)*nSegLength + (1:nSegLength));
        pw = abs(fft(voiceSeg .* w,fftl)) .^2 / sum1kMax;
        pwS = abs(fft(silentSeg .* w,fftl)).^2 / sum1kMax;
        cpw = cumsum(pw);
        cpwS = cumsum(pwS);
        vLevel = interp1(fxw, cpw, fxOctH,"linear","extrap") - interp1(fxw, cpw, fxOctL,"linear","extrap");
        sLevel = interp1(fxw, cpwS, fxOctH,"linear","extrap") - interp1(fxw, cpwS, fxOctL,"linear","extrap");
        semilogx(axHandle, fxOct, 10*log10(vLevel),"Color",[0 0 0 alphaV])
        hold(axHandle, 'on');
        semilogx(axHandle, fxOct, 10*log10(sLevel),"Color",[1 0 0 alphaV])
        axis(axHandle, [20 fs/2 -140 0])
        grid(axHandle, 'on');
        title(axHandle, directoryName + " checked: " + num2str(ii) + " in " + num2str(nFilesTrue),"Interpreter","none");
        if ii == 1
        text(axHandle, 22, -135, "thL:" + num2str(thL) + " thH:" + num2str(thH),  ...
            "FontSize", 15);
        end
        drawnow
    else
        nTestSeg = min(round(0.1*nSegment),maxN);
        idSilent = max(1, round(thL*nSegment));
        idVoice = min(nSegment, round(thH*nSegment));
        alphaV = min(1, 20/nTestSeg);
        for jj = 1:nTestSeg
            idv = levels(sortedIdx(idVoice),2);
            ids = levels(sortedIdx(idSilent),2);
            voiceSeg = x((idv-1)*nSegLength + (1:nSegLength));
            silentSeg = x((ids-1)*nSegLength + (1:nSegLength));
            pw = abs(fft(voiceSeg .* w,fftl)) .^2 / sum1kMax;
            pwS = abs(fft(silentSeg .* w,fftl)).^2 / sum1kMax;
            cpw = cumsum(pw);
            cpwS = cumsum(pwS);
            vLevel = interp1(fxw, cpw, fxOctH,"linear","extrap") - interp1(fxw, cpw, fxOctL,"linear","extrap");
            sLevel = interp1(fxw, cpwS, fxOctH,"linear","extrap") - interp1(fxw, cpwS, fxOctL,"linear","extrap");
            semilogx(axHandle, fxOct, 10*log10(vLevel),"Color",[0 0 0 alphaV])
            hold(axHandle, 'on');
            semilogx(axHandle, fxOct, 10*log10(sLevel),"Color",[1 0 0 alphaV])
            axis(axHandle, [20 fs/2 -140 0])
            grid(axHandle, 'on');
            title(axHandle, directoryName + " checked: " + num2str(jj) + " in " + num2str(nSegment),"Interpreter","none");
            drawnow
            idSilent = idSilent + 1;
            idVoice = idVoice - 1;
        end
        deltaw = nTestSeg/nSegment;
        text(axHandle, 22, -135, "thL: [" + num2str(thL+[0 deltaw],'%7.3f')  ...
            + "],   thH: [" + num2str(thH+[-deltaw 0],'%7.3f') + "],    file:" + fileList(1).name, ...
            "FontSize", 15, "Interpreter","none");
    end
end

set(axHandle, "LineWidth",2, "FontSize", 14)
xlabel(axHandle, "frequency (Hz)");
ylabel(axHandle, "level (dB) rel. max 1kHz")
%title(axHandle, directoryName + " files: " + num2str(nFiles),"Interpreter","none")
output.elapsedTime = toc(startTic);
end