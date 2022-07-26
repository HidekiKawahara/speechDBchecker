%% script for checking speech database

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

% Please execute this using cell mode
fig1H = figure;
plot(rand(200,2));grid on;
axH1 = gca;
fig2H = figure;
plot(rand(200,2));grid on;
axH2 = gca;
%% select directory consisting of files consisting audio or a file
checkType = {'directory','file'};
idType = 1; % Please edit this to select a directory or a file
switch checkType{idType}
    case 'directory'
        selPath = uigetdir;
        testPath = [selPath '/'];
        % select one file consisting audio
    case 'file'
        testPath = struct;
        [filen, pathn] = uigetfile('*.*');
        testPath.pathName = pathn;
        testPath.fileName = filen;
end
%% level distribution
maxN = 1000; % maximum number of files checked
segmentLinMS = 50; % 50ms for level check 
output1 = directoryLevelDistribution(axH1, testPath,segmentLinMS, maxN);
%% spectral display of silent and voiced samples
% Please adjus following thresholds by inspecting level distribution
silentProb = 0.00; % reference level (probability) of silent segment
voiceProb = 0.9; % reference level (probability) of voiced segment
output2 = spectrumDistributionTest(axH2, testPath, segmentLinMS, silentProb, voiceProb, maxN);
%%
print(fig1H,'-dpng','-r200', "dstrbtn" + datestr(now,30) + ".png");
print(fig2H,'-dpng','-r200', "vSlspctrm" + datestr(now,30) + ".png");
