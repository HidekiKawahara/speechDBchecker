%% sample script to calibrate spectral display

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

% calibration constant = 77+33 = 110 dB

fig2C = openfig("vSlspctrm20220727T230041.fig");
print(fig2C,"-dpng","-r200","rawOpenedFig.png")
%%
gObject = fig2C.Children.Children;
nItem = length(gObject);
for ii = 1:nItem
    switch gObject(ii).Type
        case 'line'
            cvec = gObject(ii).Color;
            gObject(ii).Color = [cvec 1/20];
            ydataa = gObject(ii).YData;
            gObject(ii).YData = ydataa + 110;
    end
end
ylimit = fig2C.Children.YLim;
fig2C.Children.YLim = ylimit + 110;
drawnow
%%
ylabel(fig2C.Children ,'level (SPL dB for 1/3 ocatve width, rel. 20 micro Pa)')
positionP = gObject(1).Position;
positionP(2) = positionP(2) + 110;
gObject(1).Position = positionP;
%%
print(fig2C,"-dpng","-r200","calibratedFig.png")
