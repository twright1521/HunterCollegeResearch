%% Trend Analysis

% Does a trend analysis on each set of data
% Deposits the results into a table 
% Does this for multiple sets of data
% Data sets must be of the same type, i.e 'Precipitation', 'Tmax', or 'Tmin'

% Can process Annual, Seasonal, or 10yr Running Mean data

% Data Arrays must be formatted in the following way

% Column 1 - Year
% Column 2+ - Mean Data

clearvars

%% Inputs

% Main Directory
Main_Dir = 'C:\Users\Trevor Riot\Documents\College Stuff\Research\Hunter Research';

% Model Folder - List of Main Folders for the models
Model_Fol = {'catskills_sta_data_may15_2018','cmip5_may15_2018'};

% File Folder - List of the separate file folders - i.e. model folders
% For catskill data files, include an empty string
File_Fol = {'','5.1_cccma_canesm2_tasmin_output','7.1_ncar_ccsm4_tasmin_output',...
            '21.2_HadGEM2-CC_tasmin_output','5.1_cccma_canesm2_tasmax_output',...
            '7.1_ncar_ccsm4_tasmax_output','21.2_HadGEM2-CC_tasmax_output',...
            '5.1_cccma_canesm2_output','7.1_ncar_ccsm4_output',...
            '21.2_HadGEM2-CC_output'}; 
% File Name
file_name = {'catskill_compare_stations_june2017_PRCP_combined_Seasonal_Mean_Winter',...
             'pr_day_CCSM4_historical_r1i1p1_Seasonal_Mean_Winter',...
             'pr_day_CCSM4_historical_r2i1p1_Seasonal_Mean_Winter',...
             'pr_day_CCSM4_historical_r6i1p1_Seasonal_Mean_Winter',...
             'pr_day_HadGEM2-CC_historical_r1i1p1_Seasonal_Mean_Winter',...
             'pr_day_HadGEM2-CC_historical_r2i1p1_Seasonal_Mean_Winter',...
             'pr_day_HadGEM2-CC_historical_r3i1p1_Seasonal_Mean_Winter',...
             'pr_day_CanESM2_historical_r1i1p1_Seasonal_Mean_Winter',...
             'pr_day_CanESM2_historical_r2i1p1_Seasonal_Mean_Winter',...
             'pr_day_CanESM2_historical_r3i1p1_Seasonal_Mean_Winter',...
             'pr_day_CanESM2_historical_r4i1p1_Seasonal_Mean_Winter',...
             'pr_day_CanESM2_historical_r5i1p1_Seasonal_Mean_Winter'};
         

% Auto-save figures
% set tag to true to save figures automatically

save_tag = true;

% Delete old trend analysis table/data?
delete_flag = true;

%% Program Start

c = textscan(file_name{1},'%s','delimiter','_');
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

%% Trend Analysis
x = 1;

for file_idx = 1:length(file_name)
    for fol_idx = 1:length(File_Fol)
        for model_idx = 1:length(Model_Fol)
            
            % Data file path
            if  isempty(File_Fol{fol_idx})
                File_Path = Model_Fol{model_idx};
            else
                File_Path = strcat(Model_Fol{model_idx},filesep,File_Fol{fol_idx});
            end

            file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'.mat');

            % Loading data file under a specific name
            if ~exist(file)
                continue      %Skips to next iteration if the file isnt in this file path
            end
            
            
            % Getting the Model Type
            c = textscan(file_name{file_idx},'%s','delimiter','_');
            c = c{1};
            if strcmp(c{1},'catskill')
                if strcmp(c{5},'PRCP')
                    model_type = 'Precipitation';
                else
                    if strcmp(c{5},'TMAX')
                        model_type = 'Tmax';
                    else
                        model_type = 'Tmin';
                    end
                end
            else
                if strcmp(c{1},'pr')
                    model_type = 'Precipitation';
                else
                    if strcmp(c{1},'tasmax')
                        model_type = 'Tmax';
                    else
                        model_type = 'Tmin';
                    end
                end
            end
            
            % Data Arrays
            array = struct2cell(load(file));
            array = array{1};
            
            if strcmp(folder_name,'Daily Time Series')
                val_array = str2double(array(2:end,6:end));
            else
                val_array = str2double(array(2:end,2:end));
            end
            
            yr_array_init = str2double(array(2:end,1));

            if strcmp(model_type,'Precipitation')
                yr_idx = find(yr_array_init >= 1930);
            else
                yr_idx = find(yr_array_init >= 1950);
            end
            
            yr_array = yr_array_init(yr_idx);
            
            % Calculate the 50 Percentile Array
            perc_50_init = prctile(val_array,50,2);
            perc_50_array = perc_50_init(yr_idx);
            
            % Trend Analysis and saving desired outputs into an array
            trend_model = fitlm(yr_array,perc_50_array);
            
            D{x,2} = trend_model.Coefficients.Estimate(2);
            D{x,3} = trend_model.Coefficients.pValue(2);
            D{x,4} = trend_model.Coefficients.Estimate(1);
            
            % Saving the file name
            if isempty(File_Fol{fol_idx})
                c = textscan(Model_Fol{model_idx},'%s','delimiter','_');
                c = c{1};
                temp_str = c{1};
            else
                c = textscan(file_name{file_idx},'%s','delimiter','_');
                c = c{1};
                temp_str = strcat(c{3},32,c{5});
            end
            
            D{x,1} = temp_str; 
            
            x = x + 1;

            clearvars -except name_flag folder_name delete_flag D x Main_Dir Model_Fol File_Fol file_name save_tag file_idx fol_idx model_idx
        end
    end
end



%% Table Devices

% Table Variable Names 
var_names = {'Model','Slope','pValue','Intercept'};

% Getting the Model Type
c = textscan(file_name{1},'%s','delimiter','_');
c = c{1};
if strcmp(c{1},'catskill')
    if strcmp(c{5},'PRCP')
        model_type = 'Precipitation';
    else
        if strcmp(c{5},'TMAX')
            model_type = 'Tmax';
        else
            model_type = 'Tmin';
        end
    end
else
    if strcmp(c{1},'pr')
        model_type = 'Precipitation';
    else
        if strcmp(c{1},'tasmax')
            model_type = 'Tmax';
        else
            model_type = 'Tmin';
        end
    end
end
            
% Folder paths for saving figures and data
save_folder = strcat(Main_Dir,filesep,'Trend Analysis');
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end

save_folder = strcat(save_folder,filesep,folder_name);
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end

save_folder = strcat(save_folder,filesep,model_type);
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end

save_data_file = strcat(save_folder,filesep,'Trend_Analysis_Data');

if exist(save_data_file)
    if (delete_flag == true)
        delete(strcat(save_data_file,'.mat'))
        trend_data_array = [var_names; D];
    else
        trend_data_array = struct2cell(load(save_data_file));
        trend_data_array = [trend_data_array; D];
    end
else
    trend_data_array = [var_names; D];
end

if save_tag == true
    save(strcat(save_data_file,'.mat'), 'trend_data_array')
end

%% Table
Data_Table = [];

for x = 2:size(trend_data_array,2)  
    
    for y = 2:size(trend_data_array,1)
        tempmat(y-1) = trend_data_array{y,x};
    end
    Data_Table = [Data_Table, table(tempmat.', 'VariableNames',trend_data_array(1,x))];
end

Data_Table.Properties.RowNames = trend_data_array(2:end,1);

figure(1)
uitable('Data',Data_Table{:,:},'ColumnName',...
    Data_Table.Properties.VariableNames,'RowName',Data_Table.Properties.RowNames,'Units',...
    'Normalized','Position',[0,0,1,1]);


if delete_flag == 1 && exist(strcat(save_data_file,'.txt'))
    delete(strcat(save_data_file,'.txt'))
end

if save_tag == true
    saveas(gcf,strcat(save_data_file),'png')
    writetable(Data_Table,strcat(save_data_file,'.txt'),'WriteRowNames',true)
end
