function fileList = audiofileSelector(inputFileList)
% fileList = audiofileSelector(inputFileList)
% This function selects files which have audio signal
% Arguments
%   inputFileList  : structure with the following field
%        name      : filename string
% Output
%   fileList       : structure with the following field
%        name      : filename string
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

nFiles = length(inputFileList);
audioIndicator = zeros(nFiles, 1);
audioExtensions = ".aifc,.aiff,.aif,.au,.flac,.ogg,.opus,.wav,.WAV,.mp3,.m4a,.mp4";
for ii = 1:nFiles
    if length(inputFileList(ii).name) > 3
        [~, ~, fext] = fileparts(inputFileList(ii).name);
        if contains(audioExtensions,fext)
            audioIndicator(ii) = 1;
        end
    else
        audioIndicator(ii) = 0;
    end
end
fileList = inputFileList(audioIndicator == 1);
end