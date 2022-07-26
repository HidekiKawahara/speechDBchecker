function output = directoryLevelDistribution(axHandle, directoryName,segLInMs, maxN)
% output = directoryLevelDistribution(axHandle, directoryName,segLInMs, maxN)
% This function shows level ditribution
% Arguments
%   axHandle       : handle to axis of a figure
%   directoryName  : stging of directory name or a structure with field
%     name         : filename string
%   segLInMs       : level check segment length in ms
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
hold(axHandle, 'off');
nFiles = min(nFilesTrue, maxN);
alphaV = min(1, 20/nFiles);
wf = weightingFilter('A-weighting',fs);
tt = (1:fs)'/fs;
xsin = sin(2*pi*1000*tt);
rms1kMax = std(xsin);
for ii = 1:nFiles
    fullPath = JSUTcorpus + string(fileList(ii).name);
    [x2, ~] = audioread(fullPath);
    x = x2(:,1);
    nSegment = floor(length(x)/nSegLength);
    levels = zeros(nSegment,1);
    properOnes = 0;
    y = wf(x);
    for jj = 1:nSegment
        tmpLvl = 20*log10(std(x((jj-1)*nSegLength + (1:nSegLength))));
        if ~isnan(tmpLvl) && ~isinf(tmpLvl)
            properOnes = properOnes + 1;
            tmpLvl = 20*log10(std(y((jj-1)*nSegLength + (1:nSegLength)))/rms1kMax);
            levels(properOnes,:) = tmpLvl;
        end
    end
    levels = levels(1:properOnes);
    nSegment = properOnes;
    plot(axHandle, sort(levels),(1:nSegment)/nSegment,'Color',[0 0 0 alphaV]);
    grid(axHandle, 'on');
    axis(axHandle, [-100 0 0 1]);
    hold(axHandle, 'all');
    title(axHandle, directoryName + " checked: " + num2str(ii) + " in " + num2str(nFilesTrue),"Interpreter","none");
    drawnow;
end
%
set(axHandle, "LineWidth",2, "FontSize", 14)
xlabel(axHandle, "level (A-weight dB rel. max 1kHz sig)");
ylabel(axHandle, "cumulative probability")
if nFilesTrue == 1
    text(axHandle, -98, 0.9, fileList(1).name,"Interpreter","none","FontSize",15);
end
%title(axHandle, directoryName + " files: " + num2str(nFilesTrue),"Interpreter","none")
output.elapsedTime = toc(startTic);
end