% Script file: loadAlldata.m
%
% Purpose:
%   Perform a pipeline of a study on mental workload analysis, including.
%       _ Data editing
%       _ Filtering
%       _ PCA extraction
%   The data used in this file was collected in Ms.Thao's experiment
%

close all; clear all; clc;
study = 'Thao_rubic';   % Select which study is being analyzed here

%% ========================== PREPARING ================================
% Prompting to user
sub = input('sub = ');  % Let user choose subject

%% Load color data;
fprintf('\n\n$$$Load color data$$$\n\n');  
link=strcat('.\data\', study, '\Subject',num2str(sub));
myFolder=strcat(link,'\','color');

if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end

filePattern = fullfile(myFolder, '*.mat');
Files = dir(filePattern);
level=[];
for k = 1:length(Files)
  baseFileName = Files(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);    
end

%% Load data
fprintf('\n\n$$$load data$$$\n\n');
link=strcat('.\data\', study, '\Subject',num2str(sub));
myFolder=strcat(link,'\','data');
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
filePattern = fullfile(myFolder, '*.mat');
Files = dir(filePattern);

%%  Initializing data from frontal cortex, ...
Alldata_seg.frontal.raw.hbo = []; 
Alldata_seg.frontal.raw.hb = [];
Alldata_seg.frontal.raw.hbt = [];

Alldata_seg.frontal.fil.hbo = [];
Alldata_seg.frontal.fil.hb = [];
Alldata_seg.frontal.fil.hbt = [];

Alldata_seg.frontal.CBSI.hbo = [];
Alldata_seg.frontal.CBSI.hb = [];
Alldata_seg.frontal.CBSI.hbt = [];

Alldata_seg.frontal.const_xcui.hbo = [];
Alldata_seg.frontal.const_xcui.hb = [];
Alldata_seg.frontal.const_xcui.hbt = [];

Alldata_seg.frontal.const_nm.hbo = [];
Alldata_seg.frontal.const_nm.hb = [];
Alldata_seg.frontal.const_nm.hbt = [];

%% visual cortex, ...
Alldata_seg.visual.raw.hbo = [];
Alldata_seg.visual.raw.hb = [];
Alldata_seg.visual.raw.hbt = [];

Alldata_seg.visual.fil.hbo = [];
Alldata_seg.visual.fil.hb = [];
Alldata_seg.visual.fil.hbt = [];

Alldata_seg.visual.CBSI.hbo = [];
Alldata_seg.visual.CBSI.hb = [];
Alldata_seg.visual.CBSI.hbt = [];

Alldata_seg.visual.const_xcui.hbo = [];
Alldata_seg.visual.const_xcui.hb = [];
Alldata_seg.visual.const_xcui.hbt = [];

Alldata_seg.visual.const_nm.hbo = [];
Alldata_seg.visual.const_nm.hb = [];
Alldata_seg.visual.const_nm.hbt = [];

%% and all.
Alldata_seg.all.raw.hbo = [];
Alldata_seg.all.raw.hb = [];
Alldata_seg.all.raw.hbt = [];

Alldata_seg.all.fil.hbo = [];
Alldata_seg.all.fil.hb = [];
Alldata_seg.all.fil.hbt = [];

Alldata_seg.all.CBSI.hbo = [];
Alldata_seg.all.CBSI.hb = [];
Alldata_seg.all.CBSI.hbt = [];

Alldata_seg.all.const_xcui.hbo = [];
Alldata_seg.all.const_xcui.hb = [];
Alldata_seg.all.const_xcui.hbt = [];

Alldata_seg.all.const_nm.hbo = [];
Alldata_seg.all.const_nm.hb = [];
Alldata_seg.all.const_nm.hbt = [];

%%
diffData_seg = []; 
%diffData_seg.frontal.hb = [];diffData_seg.visual.hbo = []; diffData_seg.visual.hb = [];

%% ======================== PROCESSING DATA =============================
for k = 1:length(Files)
    clear hb_data;
    clear info;
    baseFileName = Files(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    [info, ad_data]=load_ad(fullFileName);
    i=0;
    for ii=1:4:info.ad_ch_max/2*4-1
        i=i+1;
            mesData = ad_data.raw(:,ii:ii+3);
            [hbo, hb, hbt] = conv(mesData);
            hb_data.frontal.raw(1,:,i)=hbo(info.base_st:info.base_ed);
            hb_data.frontal.raw(2,:,i)=hb(info.base_st:info.base_ed);
            hb_data.frontal.raw(3,:,i)=hbt(info.base_st:info.base_ed);            
    end
    i=0;
    for ii=info.ad_ch_max/2*4+1:4:info.ad_ch_max*4-1
        i=i+1;
            mesData = ad_data.raw(:,ii:ii+3);
            [hbo, hb, hbt] = conv(mesData);
            hb_data.visual.raw(1,:,i)=hbo(info.base_st:info.base_ed);
            hb_data.visual.raw(2,:,i)=hb(info.base_st:info.base_ed);
            hb_data.visual.raw(3,:,i)=hbt(info.base_st:info.base_ed);            
    end
    
    hb_data.all.raw = cat(3,hb_data.frontal.raw, hb_data.visual.raw);
    info.size = size(hb_data.frontal.raw);   
    
    % Load para
    disp('Start loading parameters...');
    Input_para;
    disp('Done');
    
    % Create time series
    time = 0:info.ts:round(size(hb_data.frontal.raw,2)*info.ts)+info.ts;
    
    %% Process continuous data
    [ hb_data ] = calc_cont( info, hb_data, para );
    [ hb_data ] = smoothCBSI( hb_data, para, info );

    %% Diff
    clear diff_data; %?
    for i=1:7        
            diff_data.frontal(1,:,i)=SGfilter(hb_data.frontal.fil(1,:,i),round(para.M/info.ts)*2+1,para.K) - SGfilter(hb_data.frontal.fil(2,:,i),round(para.M/info.ts)*2+1,para.K);
            %diff_data.visual(1,:,i)=SGfilter(hb_data.visual.fil(1,:,i),round(para.M/info.ts)*2+1,para.K) - SGfilter(hb_data.visual.fil(2,:,i),round(para.M/info.ts)*2+1,para.K);
            %diff_data.visual(:,i)=SGfilter(hb_data.visual.fil(1,:,i),round(para.M/info.ts)*2+1,para.K);
            %diff_data.visual(2,:,i)=SGfilter(hb_data.visual.fil(2,:,i),round(para.M/info.ts)*2+1,para.K);   
    end        
    %% Segmentation
     segmentation;
     
%     %Frontal
%     Alldata_seg.frontal.raw.hbo = [Alldata_seg.frontal.raw.hbo;hbdata_seg.frontal.raw.hbo];
%     Alldata_seg.frontal.raw.hb = [Alldata_seg.frontal.raw.hb;hbdata_seg.frontal.raw.hb];
%     % 
     Alldata_seg.frontal.fil.hbo = [Alldata_seg.frontal.fil.hbo;hbdata_seg.frontal.fil.hbo];
     Alldata_seg.frontal.fil.hb = [Alldata_seg.frontal.fil.hb;hbdata_seg.frontal.fil.hb];
%     % 
%     Alldata_seg.frontal.CBSI.hbo = [Alldata_seg.frontal.CBSI.hbo;hbdata_seg.frontal.CBSI.hbo];
%     Alldata_seg.frontal.CBSI.hb = [Alldata_seg.frontal.CBSI.hb;hbdata_seg.frontal.CBSI.hb];
%     % 
     diffData_seg = [diffData_seg;diffdata_seg.frontal];
%     %diffData_seg.frontal.hb = [diffData_seg.frontal.hb;diffdata_seg.frontal.hb];
%     
%     %Visual
%     Alldata_seg.visual.raw.hbo = [Alldata_seg.visual.raw.hbo;hbdata_seg.visual.raw.hbo];
%     Alldata_seg.visual.raw.hb = [Alldata_seg.visual.raw.hb;hbdata_seg.visual.raw.hb];
%     % 
%     Alldata_seg.visual.fil.hbo = [Alldata_seg.visual.fil.hbo;hbdata_seg.visual.fil.hbo];
%     Alldata_seg.visual.fil.hb = [Alldata_seg.visual.fil.hb;hbdata_seg.visual.fil.hb];
%     % 
%     Alldata_seg.visual.CBSI.hbo = [Alldata_seg.visual.CBSI.hbo;hbdata_seg.visual.CBSI.hbo];
%     Alldata_seg.visual.CBSI.hb = [Alldata_seg.visual.CBSI.hb;hbdata_seg.visual.CBSI.hb];
%     % 
     %diffData_seg.frontal.hbo = [diffData_seg.frontal.hbo;diffdata_seg.frontal.hbo];
     %diffData_seg.frontal.hb = [diffData_seg.frontal.hb;diffdata_seg.frontal.hb];
end

%% ======================== PCA Extraction ================================
%PCAextraction;
variance = 99;
%diff = diffData_seg.frontal.hbo-diffData_seg.frontal.hb;
[PCAdata.Chbo.frontal] = PCAextraction(Alldata_seg.frontal.fil.hbo,variance);
[PCAdata.Chb.frontal] = PCAextraction(Alldata_seg.frontal.fil.hb,variance);
%[PCAdata.Chbo.visual] = PCAextraction(Alldata_seg.visual.fil.hbo,variance);
%[PCAdata.Chb.visual] = PCAextraction(Alldata_seg.visual.fil.hb,variance);
%[PCAdata.Chbo.all] = PCAextraction(cat(3,Alldata_seg.frontal.fil.hbo,Alldata_seg.visual.fil.hbo),variance);
%[PCAdata.Chb.all] = PCAextraction(cat(3,Alldata_seg.frontal.fil.hb,Alldata_seg.visual.fil.hb),variance);
[PCAdata.diff] = PCAextraction(diffData_seg,variance);
