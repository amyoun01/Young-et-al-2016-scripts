% create_hist_ak_climatologies.m
%
% Calculate 30-yr climate normals per 2-km pixel in Alaska based on a
% randomly selected 30 years from 1950-2009. Must run this code prior to
% running the BRT analysis in R.
% 
% FILE REQUIREMENTS:
%    (1) Monthly gridded climate or fire data for time period of interest. 
%        These data are available in the folders under the 
%        'Young_et_al_2016_Ecography' parent directory:
%
%        Fire - \Data\FireData
%        Climate - \Data\ClimateData\Historical
%        
%    (2) Vectors of 30 years of training and testing data randomly sampled 
%        without replacement from 1950-2009. The testing set of years is
%        complementary to the training set. The data used in this
%        analysis are located in the following directory under
%        'Young_et_al_2016_Ecography': \Data\AncillaryData. 
%        
% DEPENDENCIES:
%     (1) createClimatologies.m - function used to summarize multi-year
%         climate and create a climatology of a gridded dataset. Details 
%         regarding this function are described in comments of the 
%         createClimatologies.m script, located in:
%         'Young_et_al_2016_Ecography\Scripts\Functions'
%
%     (2) Function(s) from Matlab mapping toolboxes:
%         geotiffwrite.m
%         geotiffread.m (used only in createClimatologies.m)
%         geotiffinfo.m (used also in createClimatologies.m)
%
% CITATION, FILES, AND SELF-AUTHORED FUNCTIONS AVAILABLE FROM ...
%
% Created by: Adam Young
% Created on: June 2013
% Edited for publication: January 2016
%
% Contact info: Philip E. Higuera, PhD, philip.higuera[at]umontana.edu
%%
% INITIALIZE WORKSPACE
clear all; % clear workspace of variables
clc; % clear command prompt
close all; % close all current figure windows
% WORKING DIRECTORY - LOCATION OF THE 'Young_et_al_2016_Ecography'
wdir = 'G:\test';
% ADD PATH FOR FOLDER THAT CONTAINS createClimatologies.m FUNCTION
addpath([wdir,'\Young_et_al_2016_Ecography\Scripts\Functions']);
% Initialize Variables AND FUNCTIONS
% Geographic information for exporting GeoTiff files
tifInfo = ...
    geotiffinfo(...
    [wdir, ...
    '\Young_et_al_2016_Ecography\Data\VegLandscapeData\AK_VEG.tif']);
R = tifInfo.RefMatrix; % Referencing matrix
varname = @(x) inputname(1); % Short function to convert variable name to 
                             % a character string, useful for naming
                             % GeoTiff files to export.
% Establish output directories to save GeoTiff files to. 
save_dir = [wdir,'\Young_et_al_2016_Ecography\Data\train_test_data'];
% If the current directory does not exist, create it.
direxist = exist(save_dir,'dir');
if direxist == 0
    mkdir(save_dir);
end
% LOAD ALREADY RANDOM SAMPLED 30-YR CLIMATOLOGIES FROM 1950-2009
cd([wdir,'\Young_et_al_2016_Ecography\Data\AncillaryData']);
load('train_years.mat'); % Also available as a .csv file
load('test_years.mat'); % Also available as a .csv file
% Create array to store training and testing climatologies
years_mtx = cat(3,train_climatologies,test_climatologies);
fnames = {'train','test'}; % Character strings for naming exported GeoTiff 
                           % files. 
% Create climatologies and fire frequency data for training and testing 
% datasets.
for m = 1:size(years_mtx,3)
    climatologies = years_mtx(:,:,m); % Matrix of randomly sampled thirty
                                      % periods. There are 100 rows and
                                      % 30 columns. The
                                      % createClimatologies.m function will
                                      % use the 30 years in each row to 
                                      % create a climatology.
                                      
    % Mean Temperature of the Warmest Month -------------------------------
    directory = [wdir, ...
        '\Young_et_al_2016_Ecography\Data\ClimateData\Historical\TEMP'];
    % The following (strN, months, and func_hand) are all parameters used
    % to run the createClimatologies.m function. Please see the 
    % createClimatologies.m script for details.
    strN = '01_1950'; 
    months = 1:12; 
    func_hand = @(x) max(x,[],3);
    % Run createClimatologies.m
    TempWarm = createClimatologies(directory,...
                                   strN, ...
                                   climatologies, ...
                                   months, ...
                                   func_hand, ...
                                   true, ...
                                   -9999);
    % For each climatology created (here 100), export the climatological
    % map as a GeoTiff.
    for i = 1:size(climatologies,1)
        filename = ...
            sprintf(...
            '%s\\%s_%s_%d.tif',...
            save_dir,char(fnames(m)),varname(TempWarm), i);
        geotiffwrite(filename, ...
            TempWarm(:,:,i), ...
            R, ...
            'GeoKeyDirectoryTag',tifInfo.GeoTIFFTags.GeoKeyDirectoryTag)
    end
    clear TempWarm;
    
    % Mean Total Annual Moisture Availability -----------------------------
    directory = [wdir, ...
        '\Young_et_al_2016_Ecography\Data\ClimateData\Historical\DEF\'];
    % The following (strN, months, and func_hand) are all parameters used
    % to run the createClimatologies.m function. Please see the 
    % createClimatologies.m script for details.
    strN = '01_1950';
    months = 1:12;
    func_hand = @(x) sum(x,3);
    % Run createClimatologies.m
    AnnDEF = createClimatologies(directory,...
                                 strN, ...
                                 climatologies, ...
                                 months, ...
                                 func_hand, ...
                                 true, ...
                                 -9999);
    for i = 1:size(climatologies,1)
        filename = ...
            sprintf(...
            '%s\\%s_%s_%d.tif',...
            save_dir,char(fnames(m)),varname(AnnDEF), i);
        geotiffwrite(filename, ...
            AnnDEF(:,:,i), ...
            R, ...
            'GeoKeyDirectoryTag',tifInfo.GeoTIFFTags.GeoKeyDirectoryTag)
    end
    clear AnnDEF;
    
    % Fire  frequency -----------------------------------------------------
    directory = [wdir, ... 
        '\Young_et_al_2016_Ecography\Data_Results\1_FireData\'];
    strN = '1950';   
    months = 1; 
    func_hand = @(x) nansum(x,3);
    firefreq = createClimatologies(directory,...
                                   strN, ...
                                   climatologies, ...
                                   months, ...
                                   func_hand, ...
                                   true, ...
                                   -9999);
    firefreq = firefreq.*30;
    for i = 1:size(climatologies,1)
        filename = ...
            sprintf(...
            '%s\\%s_%s_%d.tif',...
            save_dir,char(fnames(m)),varname(firefreq), i);
        geotiffwrite(filename, ...
            firefreq(:,:,i), ...
            R, ...
            'GeoKeyDirectoryTag',tifInfo.GeoTIFFTags.GeoKeyDirectoryTag)
    end
    clear firefreq;
end