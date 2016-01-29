% summarize_future_projections.m
%
% This script summarizes the projections of future fire probability made by
% the R script: project_21stCentury_fire.R. Specifically, this script 
% calculates the (1) median predicted probability of fire occurrence for  
% three different time periods in the 21st century and for three GCMS and 
% (2) the ratio between predicted historical and predicted future fire 
% rotation periods per pixel.
% 
% FILE REQUIREMENTS:
%    (1) Historical predicted probability of fire maps for Alaska
%    (1950-2009) from the AK model. These files are located in the
%    folder: 'Young_et_al_2016_Ecography\Output\1_FINAL_AK_RESULTS'
%        
%    (2) Future projected probabilities of fire occurrence for each GCM,
%    time period, and BRT model, located in:
%    
%    - 'Young_et_al_2016_Ecography\Output\4_FutureProjections\[GCM NAME]'
%
% DEPENDENCIES:
%     (1) Function from Matlab mapping toolbox:
%         geotiffread.m 
%
% CITATION, FILES, AND SELF-AUTHORED FUNCTIONS AVAILABLE FROM ...
%
% Created by: Adam Young
% Created on: January 2015
% Edited for publication: January 2016
%
% Contact info: Philip E. Higuera, PhD, philip.higuera[at]umontana.edu
%%
% Initialize workspace
clear all; % clear workspace
close all; % close current figures
clc; % clear command prompt
% Initialize directory names
wdir = 'G:\test'; % Parent directory where 'Young_et_al_2016_Ecography' is located
data_dir = '\Young_et_al_2016_Ecography\Data\'; % Data directory
output_dir = '\Young_et_al_2016_Ecography\Output\'; % Output directory

% LOAD AK MASK MAP TO GET DIMENSIONS OF 2-KM RASTER OF ALASKA
tifInfo = geotiffinfo([wdir,data_dir,'VegLandscapeData\AK_VEG.tif']);

% SET MAIN DIRECTORIES FOR COLLECTING DATA
main_hist_dir = [wdir,output_dir,'1_AK_FINAL_RESULTS\']; % HISTORICAL
main_fut_dir  = [wdir,output_dir,'4_FUTURE_PROJECTIONS\']; % FUTURE

% CELL ARRAYS TO ITERATIVELY CHANGE DIRECTORY AND RETRIEVE NEEDED RASTER
% MAPS OF ALASKA.
yrs  = {'2010_2039','2040_2069','2070_2099'};
gcms = {'CCSM4','GFDL-CM3','GISS-E2-R','IPSL-CM5A-LR','MRI-CGCM3'};

% FUTURE PREDICTED: THIS IS A 725 x 687 x 5 x 3 ARRAY. THE FIRST
% DIMENSION AND SECOND DIMENSION ARE FOR THE ROWS AND COLUMNS OF THE RASTER
% OF ALASKA, RESPECTIVELY. THE THIRD DIMENSION REPRESENTS A GIVEN GCM, THE
% FOURTH DIMENSION IS REPRESENTATIVE OF THE FUTURE TIME PERIOD
med_fut_pred = NaN(tifInfo.Height,tifInfo.Width, ... 
                   length(gcms), ...
                   length(yrs));

% RATIOS COMPARING PREDICTED FUTURE AND HISTORIC PROBABILITIES: THIS 
% IS THE RATIO OF FRP_FUTURE/FRP_HISTORIC. SINCE THE FRP
% IS CALCULATED BY TAKING THE INVERSE OF THE ANNUAL PREDICTED PROBABILITY OF
% FIRE OCCURRENCE (I.E. 30/PROB), WE SIMPLY CALCULATE:
%
%                           HISTORIC_PROB/FUTURE_PROB
% 
% AS THIS IS EQUAL TO:
%
%                          (30/FUTURE_PROB)/(30/HISTORIC_PROB)
%                        = (30/FUTURE_PROB)*(HISTORIC_PROB/30)
%                        =  HISTORIC_PROB/FUTURE_PROB

% EMPTY ARRAY TO STORE RATIO RESULTS
ratio = NaN(tifInfo.Height,tifInfo.Width, ...
            length(gcms), ...
            length(yrs));

% ARRAY TO STORE HISTORICAL PREDICTIONS OF THE PROBABILITY OF FIRE
% OCCURRENCE FOR ALL ONE-HUNDRED BRTS
hist_pred  = NaN(tifInfo.Height,tifInfo.Width,100);

% ARRAY TO STORE FUTURE PREDICTIONS OF THE PROBABILITY OF FIRE
% OCCURRENCE FOR ALL ONE-HUNDRED BRTS, FIVE GCMS, AND THREE TIME PERIODS
fut_pred = NaN(tifInfo.Height,tifInfo.Width, ...
    100, ...
    length(gcms), ...
    length(yrs));

% ARRAY TO STORE FUTURE RATIOS OF THE RELATIVE CHANGE IN THE FIRE ROTATION 
% PERIOD FOR ALL ONE-HUNDRED BRTS, FIVE GCMS, AND THREE TIME PERIODS
ratio_i  = NaN(tifInfo.Height,tifInfo.Width, ...
    100, ...
    length(gcms), ...
    length(yrs));

for i = 1:100 % FOR EACH BRT
    cd(main_hist_dir); % CHANGE DIRECTORY 
    hist_files = dir('*tif');
    % LOAD HISTORICAL PROBABILITY MAP
    hist_pred(:,:,i)  = geotiffread(['pred_map_',num2str(i),'.tif']);
    
    for g = 1:length(gcms) % FOR EACH GCM
        
        cd([main_fut_dir,char(gcms(g))]); % CHANGE TO THE DIRECTORY WHERE
                                          % FUTURE PROJECTIONS ARE LOCATED

        for y = 1:length(yrs) % FOR EACH TIME PERIOD
            
            % SET NAME OF CURRENT FILE AND AND LOAD PROJECTED PROBABILTIY 
            %  MAP
            filename = sprintf('%s_pred_map_%s_%d.tif', ...
                               char(gcms(g)),char(yrs(y)),i);
            fut_pred(:,:,i,g,y) = geotiffread(filename); % STORE PROJECTED
                                                         % PROBABILITY MAP
            % CALCULATE AND STORE RATIO
            ratio_i(:,:,i,g,y) =   hist_pred(:,:,i) ./ fut_pred(:,:,i,g,y);
        end
        
        
    end
end

% SUMMARIZE PROJECTIONS AND RATIO VALUES USING THE MEDIAN PER PIXEL
for g = 1:length(gcms) % FOR EACH GCM
    for y = 1:length(yrs) % FOR EACH TIME PERIOD     
        med_fut_pred(:,:,g,y) = squeeze(median(fut_pred(:,:,:,g,y),3));
        ratio(:,:,g,y) = squeeze(median(ratio_i(:,:,:,g,y),3));
    end
end
% SAVE OUTPUT AS .mat FILES
cd(main_fut_dir);
save('med_fut_pred.mat','med_fut_pred');
save('ratio.mat','ratio');