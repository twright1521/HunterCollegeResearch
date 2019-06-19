%% Comparative Plotting of  Mean 50 Percentile

% Plots the mean 50 percentiles
% For Multiple Ensemble Members vs one set of data
% Data sets must be of the same type, i.e 'Precipitation', 'Tmax', or 'Tmin'

% Can process Annual, Seasonal, or 10yr Running Mean data

% Mainly used for comparing station data to multiple model outputs
% Can be used to compare different models as well

% Data Arrays must be formatted in the following way

% Column 1 - Year
% Column 2+ - Mean Data

clearvars

%% Inputs

% Main Directory
Main_Dir = 'C:\Users\Trevor Riot\Documents\College Stuff\Research\Hunter Research';

%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% Data Set #1 - Use For Data File
% Model Folder 
Model_Fol_1 = 'catskills_sta_data_may15_2018';

% File Folder  
File_Fol_1 = [];     %For data files, leave this empty and use model folder

% File Name 
file_name_1 = 'catskill_compare_stations_june2017_PRCP_combined_10yr_Middle_Running_Mean_Summer';

%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% Data Set #2 - Use For Model Ensembles
% Model Folder 
Model_Fol_2 = 'cmip5_may15_2018';

% File Folder  
File_Fol_2 = '21.2_HadGEM2-CC_output';    

% File Name - For 10-yr Mean 
file_name_2_pre = 'pr_day_HadGEM2-CC_historical_';

% List of the ensemble identifiers - include only the ensembles that you
% want to plot - nonexistant ensembles wont affect the program
file_name_2 = {'r1i1p1','r2i1p1','r3i1p1','r4i1p1','r5i1p1','r6i1p1'};

file_name_2_suf = '_10yr_Middle_Running_Mean_Summer';

%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% Auto-save figures
% set tag to true to save figures automatically

save_tag = true;

%% Data Set #1
% Data file path
if  isempty(File_Fol_1) == 1
    File_Path_1 = Model_Fol_1;
else
    File_Path_1 = strcat(Model_Fol_1,filesep,File_Fol_1);
end

file_1 = strcat(Main_Dir,filesep,File_Path_1,filesep,file_name_1,'.mat');
            
% Loading data file under a specific name
array_1 = struct2cell(load(file_1));
array_1 = array_1{1};
val_array_1 = str2double(array_1(2:end,2:end));
yr_array_1 = str2double(array_1(2:end,1));

% Calculate the 10, 50, 90 Percentiles Arrays
perc_50_array_1 = prctile(val_array_1,50,2);

%% Data Set #2
% Data file path
if  isempty(File_Fol_2) == 1
    File_Path_2 = Model_Fol_2;
else
    File_Path_2 = strcat(Model_Fol_2,filesep,File_Fol_2);
end

%data_cell_2 = cell(2,length(file_name_2));

%% Program Start

%Getting the data
k = 0;
good_name_idx = [];

for x = 1:length(file_name_2)
    file_2 = strcat(Main_Dir,filesep,File_Path_2,filesep,file_name_2_pre,file_name_2{x},file_name_2_suf,'.mat');

    % Check if file exists
    if ~exist(file_2)
        k = k + 1;
        continue      %Skips to next iteration if the file isnt in this file path
    end
         
    good_name_idx = [good_name_idx, x];
    
    % Loading data file under a specific name
    array_2 = struct2cell(load(file_2));
    array_2 = array_2{1};
    val_array_2 = str2double(array_2(2:end,2:end));
    temp_yr_array_2 = str2double(array_2(2:end,1));
    
    % Calculate the 10, 50, 90 Percentiles Arrays
    temp_perc_50_array_2 = prctile(val_array_2,50,2);
    
    data_cell_2{1,x-k} = temp_yr_array_2;
    data_cell_2{2,x-k} = temp_perc_50_array_2;
end

file_name_2 = file_name_2(good_name_idx);

%% Proper File Name
c = textscan(file_name_1,'%s','delimiter','_');
temp_string = c{1};
for x = 1: length(temp_string)
    if strcmp(temp_string{x},'10yr')
        if isempty(File_Fol_1)
            temp_string{x} = 'final';
            save_name_1 = temp_string{1};
        else
            temp_string{x} = 'FULL_NE_ts';
            save_name_1 = strcat(temp_string{3},'_',temp_string{x-1});
        end
        for y = x+1:length(temp_string)
            temp_string{y} = [];
        end
        break
    end
end

for x = 1:length(temp_string)
    if x == 1
        name_string = temp_string{x};
    else
        if isempty(temp_string{x})
            name_string = strcat(name_string,temp_string{x});
        else
            name_string = strcat(name_string,'_',temp_string{x});
        end
    end
end

%% Plot Devices

% Getting the Plot Type
c = textscan(file_name_1,'%s','delimiter','_');
temp_string = c{1};
if isempty(File_Fol_1)
    if strcmp(temp_string{5},'PRCP')
        plot_type = 'Precipitation';
    else
        if strcmp(temp_string{5},'TMAX')
            plot_type = 'Tmax';
        else
            plot_type = 'Tmin';
        end
    end
else
    if strcmp(temp_string{1},'pr')
        plot_type = 'Precipitation';
    else
        if strcmp(temp_string{1},'tasmax')
            plot_type = 'Tmax';
        else
            plot_type = 'Tmin';
        end
    end
end

clearvars c temp_string

% Setting the Y-axis label
if strcmp(plot_type,'Precipitation')
    y_string = 'Precipitation - mm';
else
    y_string = 'Temperature - Celsius';
end

% Getting the Model Name
if ~isempty(File_Fol_1)
    c = textscan(File_Fol_1,'%s','delimiter','_');
    temp_string = c{1};
    for x = 1: length(temp_string)
        k1 = strfind(temp_string{x},'output');
        k2 = strfind(temp_string{x},'tas');
        if ~isempty(k1) || ~isempty(k2) 
            for y = x:length(temp_string)
                temp_string{y} = [];
            end

            for y = 1:length(temp_string)
                if y == 1
                    Model_Name = temp_string{y};
                else
                    if isempty(temp_string{y})
                        break
                    else
                        Model_Name = strcat(Model_Name,'_',temp_string{y});
                    end
                end
            end
            break
        end
    end
end

% Getting the file type - i.e mean, 10 yr mean, etc.
c = textscan(file_name_1,'%s','delimiter','_');
c = c{1};

name_flag = false;
for x = 1:length(c)
    if strcmp(c{x},'FULL') || strcmp(c{x},'final')
        folder_name = 'Daily Time Series';
        name_flag = true;
        break
    else
        if strcmp(c{x},'10yr')
            for y = x:length(c)
                if y == x
                    folder_name = c{x};
                else
                    folder_name = strcat(folder_name,32,c{y});
                end
            end
            name_flag = true;
            break
        end
    end
end

if (name_flag == false)
    if strcmp(c{end},'Mean')
        folder_name = strcat(c{end-1},32,c{end});
    else
        folder_name = strcat(c{end-2},32,c{end-1},32,c{end});
    end
end

%% Save Folders
% Create folders to save figures
if (save_tag == 1)
    save_folder = strcat(Main_Dir,filesep,Model_Fol_1,filesep,'Figures_',Model_Fol_1);
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end
    
    save_folder = strcat(save_folder,filesep,plot_type);
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end
    
     if ~isempty(File_Fol_1)
        save_folder = strcat(save_folder,filesep,Model_Name);
        if (exist(save_folder,'dir') == 0)
            mkdir(save_folder)
        end
     end
            
    save_folder = strcat(save_folder,filesep,name_string);
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end
    
    save_folder = strcat(save_folder,filesep,folder_name);
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end   
end

% Create folders to save PNGs
if (save_tag == 1)
    save_PNG_folder = strcat(Main_Dir,filesep,Model_Fol_1,filesep,'PNGs_',Model_Fol_1);
    if (exist(save_PNG_folder,'dir') == 0)
        mkdir(save_PNG_folder)
    end
    
    save_PNG_folder = strcat(save_PNG_folder,filesep,plot_type);
    if (exist(save_PNG_folder,'dir') == 0)
        mkdir(save_PNG_folder)
    end
    
    if ~isempty(File_Fol_1)
        save_PNG_folder = strcat(save_PNG_folder,filesep,Model_Name);
        if (exist(save_PNG_folder,'dir') == 0)
            mkdir(save_PNG_folder)
        end
    end
            
    save_PNG_folder = strcat(save_PNG_folder,filesep,name_string);
    if (exist(save_PNG_folder,'dir') == 0)
        mkdir(save_PNG_folder)
    end
    
    save_PNG_folder = strcat(save_PNG_folder,filesep,folder_name);
    if (exist(save_PNG_folder,'dir') == 0)
        mkdir(save_PNG_folder)
    end
end

%% Legend and Title
% Creating Legend String
c = textscan(file_name_1,'%s','delimiter','_');
temp_string_1 = c{1};
if strcmp(temp_string_1{1},'catskill')
    pidx = 1;
else 
    pidx = 5;
end

legend_str{1} = strcat(temp_string_1{pidx});
for x = 1:length(file_name_2)
    legend_str{x+1} = file_name_2{x};
end

% Fixing file_name string for title
file_name_1 = strrep(file_name_1,'_',' ');

c = textscan(file_name_2_pre,'%s','delimiter','_');
temp_str = c{1};

model_str = temp_str{3};
for x = 1:length(file_name_2)
    if x == 1
        model_str = strcat(model_str,32,file_name_2{x});
    else 
        model_str = strcat(model_str,',',32,file_name_2{x});
    end
end

%% Plotting
colormap jet
cmap = colormap;

title_str = strcat('10-yr Running Mean',32,plot_type,32,'50 Percentiles');

figure(1)
hold on
% Data Set #1
plot(yr_array_1,perc_50_array_1,'k','LineWidth',2)
% Data Set #2
for x = 1:size(data_cell_2,2)
    yr_vals = data_cell_2{1,x};
    perc_50_vals = data_cell_2{2,x};
    
    Plot_color = cmap(round(x*64/(size(data_cell_2,2))),:);
    
    plot(yr_vals,perc_50_vals,'Color',Plot_color,'LineWidth',2)
end
title({file_name_1,'Compared to:',model_str,title_str})
ylabel(y_string)
xlabel('Year')
if strcmp(plot_type,'Precipitation')
    xlim([1930, yr_vals(end)])
else
    xlim([1950, yr_vals(end)])
end
legend(legend_str)

if(save_tag == 1)
    savefig(strcat(save_folder,filesep,save_name_1,'_Compared_to_',model_str))
    saveas(gcf,strcat(save_PNG_folder,filesep,save_name_1,'_Compared_to_',model_str),'png')
end

