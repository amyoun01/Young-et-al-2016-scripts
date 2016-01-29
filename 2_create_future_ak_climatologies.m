% create_future_ak_climatologies.m
%
% Calculate 30-yr climate normals per 2-km pixel in Alaska using downscaled 
% GCM projected climate data for the following periods:
%     * 2010 - 2039
%     * 2040 - 2069
%     * 2070 - 2099
% 
% FILE REQUIREMENTS:
%    (1) Monthly gridded climate data for time periods of interest. 
%        These data are available in the folders under the 
%        'Young_et_al_2016_Ecography' parent directory:
%
%        Climate - \Data\ClimateData\FutureProjected
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
% Contact info: Philip E. Higuera, PhD, philip.higuera[at]umontana.edu%% INITIALIZE WORKSPACE
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
    '\Young_et_al_2016_Ecography\Data_Results\VegLandscapeData\AK_VEG.tif']);
R = tifInfo.RefMatrix; % Referencing matrix
varname = @(x) inputname(1); % Short function to convert variable name to 
                             % a character string, useful for naming
                             % GeoTiff files to export.
% Time periods of 30-yr climatologies to create
climatologies = [2010:2039;
                 2040:2069;
                 2070:2099];
% 5 GCMs used to create future projections of temperature and
% precipitation. All projections are under the AR5 RCP 6.0 scenario.
gcms = {'CCSM4','GFDL-CM3','GISS-E2-R','IPSL-CM5A-LR','MRI-CGCM3'};
% Create climatologies for each of the three time periods and for each GCM
for g = 1:length(gcms)
    % For each GCM, if a directory does not yet exist to store the
    % GeoTiffs, create one using the mkdir.m function.
    save_dir = [wdir,'\Young_et_al_2016_Ecography\Data\FutureClimatologies\',char(gcms(g))];
    direxist = exist(save_dir,'dir');
    if direxist == 0
        mkdir(save_dir);
    end
    
    % Mean Temperature of the Warmest Month -------------------------------
    directory = [wdir, ...
        '\Young_et_al_2016_Ecography\Data\ClimateData\FutureProjected\TEMP\', ...
        char(gcms(g))];
    strN = '01_2007';
    months = 1:12;
    func_hand = @(x) max(x,[],3);
    TempWarm = createClimatologies(directory,...
        strN, ...
        climatologies, ...
        months, ...
        func_hand, ...
        true, ...
        -9999);
    for i = 1:size(climatologies,1)
        filename = ...
            sprintf(...
            '%s\\%s_%d_%d.tif',...
            save_dir,varname(TempWarm), ...
            climatologies(i,1),climatologies(i,end));
        geotiffwrite(filename, ...
            TempWarm(:,:,i), ...
            R, ...
            'GeoKeyDirectoryTag',tifInfo.GeoTIFFTags.GeoKeyDirectoryTag)
    end
    clear TempWarm;
    %% Mean Total Annual Moisture Deficit
    directory = [wdir, ...
        '\Young_et_al_2016_Ecography\Data\ClimateData\FutureProjected\DEF\', ...
        char(gcms(g))];
    strN = '01_2007';
    months = 1:12;
    func_hand = @(x) sum(x,3);
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
            '%s\\%s_%d_%d.tif',...
            save_dir,varname(AnnDEF), ...
            climatologies(i,1),climatologies(i,end));
        geotiffwrite(filename, ...
            AnnDEF(:,:,i), ...
            R, ...
            'GeoKeyDirectoryTag',tifInfo.GeoTIFFTags.GeoKeyDirectoryTag)
    end
    clear AnnDEF;
end

