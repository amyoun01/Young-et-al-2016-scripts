% FIG_5.m
%
% This script creates Figure 5 in Young et al. 2016.
%
% Fig. 5: Interactions between the mean temperature of the warmest month 
% (TWARM) and annual moisture deficit (P-PETANN), and the 30-yr probability 
% of fire occurrence per pixel for the (a) AK, (b) BOREAL, and (c) TUNDRA 
% models. The response surface represents the median predicted probability 
% of fire occurrence from 100 boosted regression tree models for each model 
% type. Darker (lighter) colors in the response surface represent higher 
% (lower) probabilities of fire occurrence. A lowess function (span=0.1) 
% was used to smooth the response surface.
%
% FILE REQUIREMENTS:
%    - 'climlims.mat' - 
%    - 'TempWarm_AnnDEF_int.csv' - TempWarm and AnnDEF interaction 
%                                  partial dependence results
%
% DEPENDENCIES:
%    (1) From curve fitting toolbox:
%        - smooth.m
%
% CITATION, FILES, AND SELF-AUTHORED FUNCTIONS AVAILABLE FROM ...
%
% Created by: Adam Young
% Created on: May 2015
% Edited for publication: January 2016
%
% Contact info: Philip E. Higuera, PhD, philip.higuera[at]umontana.edu
%%
% set working directory (where 'Young_et_al_2016_Ecography' is located)
wdir = 'G:\test';

% change directory
cd([wdir,'\Young_et_al_2016_Ecography\Data\AncillaryData\']);
% load historical climatic limits for each spatial region and climate
% variable
load('climlims.mat');
climlims = flipud(cell2mat(struct2cell(climlims)));

% Directory of results
output_dir = '\Young_et_al_2016_Ecography\Output\';
modeltype = {'3_TUNDRA_FINAL_RESULTS', ...
             '2_BOREAL_FINAL_RESULTS', ...
             '1_AK_FINAL_RESULTS'};

% axis limits
xlims = [4 20];
ylims = [-500 750];
zlims = [ 0.0 0.08; 0.0 0.50; 0.0 0.50];

% number of ticks per axis
nticks = [4 5 5];


xscl = [0.86 0.98];
yscl = [0.83 0.98];
zscl = [1.3 1.3];

% INITIALIZE FIGURE
figure(5); 
clf; 
set(gcf, ...
    'color','w', ...
    'units','centimeters',...
    'position',[28.0 5.0 8.0 17.2]);

% PARAMETRS TO CREATE FIGURE AND PANELS WITH
ystart = 0.8;
xstart = 1.25;
dx     = 6.0;
dy     = 4.9;
ychg   = 0.65;

% FOR EACH MODEL TYPE
for u = 1:length(modeltype)
    
    % change directory to model folder (e.g., BOREAL)
    chgdir = [wdir,output_dir,cell2mat(modeltype(u))];
    cd(chgdir);
    
    % Load interaction partial dependence results
    TempWarm_AnnDEF = importdata('TempWarm_AnnDEF_int.csv');
    TempWarm_AnnDEF = TempWarm_AnnDEF.data;
    
    % extract variables from loaded dataset
    TempWarm = TempWarm_AnnDEF(:,1);
    AnnDEF   = TempWarm_AnnDEF(:,2);
    prob     = TempWarm_AnnDEF(:,3:end);
    med_prob = median(prob,2);
    
    % Number of predicted probability points for each covariate
    resolution = size(TempWarm,1)/100;
    
    x = TempWarm(1:resolution);
    y = AnnDEF(1:resolution:((resolution^2)-(resolution-1)));
    
    % Include only those locations on the surface plot where climatic 
    twrm_include = find(x(:,1) >= climlims((u*2),1) & ...
                        x(:,1) <= climlims((u*2),2));
    
    adef_include = find(y(:,1) >= climlims((u*2)-1,1) & ...
                        y(:,1) <= climlims((u*2)-1,2));
                    
    Z = reshape(med_prob,resolution,resolution)';
    Z = Z(adef_include,twrm_include);
    
    % Meshgrid of x and y data values for plotting
    [X,Y] = meshgrid(x(twrm_include),y(adef_include));
    
    % Smooth 3-d plane
    [n m] = size(Z);
    smoothInt1 = 0.10;
    smoothInt2 = 0.10;
    Zsmooth = NaN*ones(size(Z));
    for j = 1:m
        Zsmooth(:,j) = smooth(Z(:,j),smoothInt1,'lowess');
        for i = 1:n
            Zsmooth(i,:) = smooth(Z(i,:),smoothInt2,'lowess');
        end
    end
    for j = 1:m
        Zsmooth(:,j) = smooth(Zsmooth(:,j),smoothInt1,'lowess');
        for i = 1:n
            Zsmooth(i,:) = smooth(Zsmooth(i,:),smoothInt2,'lowess');
        end
    end
    
    % Create colormap
    lmt = 0.9;
    lwr = 0.0;
    fireCmap = NaN*ones(resolution,3);
    fireCmap(:,1) = flipud([lwr:(lmt-lwr)/(resolution-1):lmt]');
    fireCmap(:,2) = flipud([lwr:(lmt-lwr)/(resolution-1):lmt]');
    fireCmap(:,3) = flipud([lwr:(lmt-lwr)/(resolution-1):lmt]');
    
    % Set up axes for figures
    v = u - 1; % use to help shift position for each panel
    axes('Units','Centimeters', ...
         'Position',[xstart ystart+v*ychg+v*dy dx dy]);
     
    % Create interaction (i.e., surface) plot 
    sf = surf(x(twrm_include(1:4:end)),y(adef_include(1:4:end)), ...
              Zsmooth(1:4:n,1:4:m), ...
              'EdgeColor','k', ...
              'FaceAlpha',0.75); 
    hold on;
    
    % Set colormap for surface plot
    colormap(fireCmap)
    
    % SET X-, Y-, AND Z-AXIS LIMITS
    xlim(xlims);
    ylim(ylims);
    zlim(zlims(u,:));
    
    % Add text to figure panels
    if u == 3
        text(xscl(2)*max(xlims),yscl(2)*max(ylims),zscl(2)*max(zlims(u,:)), ...
            '(a)', ...
            'FontName','Arial', ...
            'FontSize',11, ...
            'FontWeight','Bold');
        text(xscl(1)*max(xlims),yscl(1)*max(ylims),zscl(1)*max(zlims(u,:)), ...
            'AK', ...
            'FontName','Arial', ...
            'FontSize',10);
    elseif u == 2
        text(xscl(2)*max(xlims),yscl(2)*max(ylims),zscl(2)*max(zlims(u,:)), ...
            '(b)', ...
            'FontName','Arial', ...
            'FontSize',11, ...
            'FontWeight','Bold');
        text(xscl(1)*max(xlims),yscl(1)*max(ylims),zscl(1)*max(zlims(u,:)), ...
            'BOREAL', ...
            'FontName','Arial', ...
            'FontSize',10);
    elseif u == 1
        text(xscl(2)*max(xlims),yscl(2)*max(ylims),zscl(2)*max(zlims(u,:)), ...
            '(c)', ...
            'FontName','Arial', ...
            'FontSize',11, ...
            'FontWeight','Bold');
        text(xscl(1)*max(xlims),yscl(1)*max(ylims),zscl(1)*max(zlims(u,:)), ...
            'TUNDRA', ...
            'FontName','Arial', ...
            'FontSize',10);
    end
    
    % Add z-label
    if u == 2
        text(24.5,845,0.25, ...
            'Probability of fire occurring in 30 years (per pixel)', ...
            'FontName','Arial', ...
            'FontSize',8, ...
            'Rotation',90, ...
            'HorizontalAlignment','Center');
    end
    
    % Add x- and y-axis labels
    if u == 1
        text(14,850,-0.03,'T_W_A_R_M (\circC)', ...
            'FontSize',8);
        text(-4,600,-0.012,'P - PET_A_N_N (mm)', ...
            'FontSize',8);
    end
    
    % Format axes
    set(gca, ...
        'FontName','Arial', ...
        'FontSize',8, ...
        'XTick',[2 6 10 14 18], ...
        'YTick',[-500 -250 0 250 500], ...
        'ZTick',[range(zlims(u,:))/nticks(u):range(zlims(u,:))/nticks(u):zlims(u,2)], ...
        'LineWidth',0.72, ...
        'TickDir','in', ...
        'XGrid','on', ...
        'YGrid','on', ...
        'ZGrid','on');
    
    % Rotate view of 3-d surface plot
    view(-137,20);
    
end

% SAVE FIGURE 5
cd([wdir,output_dir,'5_FIGS']);
set(gcf,'PaperType','usletter','PaperPositionMode','auto');
print('FIG_5_v2','-dtiff','-r450');
saveas(gcf,'FIG_5_v2.fig');