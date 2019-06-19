%% Plotting Mean, 10, 50, 90 Percentile Overlay

% Plots the mean data for each location 
% Overlays the 10, 50, and 90 percentiles

% Can process Annual, Seasonal, or 10yr Running Mean data

% Data Arrays must be formatted in the following way

% Column 1 - Year
% Column 2+ - Mean Data

%%%%%%%%%%%%%% 
% This program plays a loud gong when finished
% To disable set this flag to false
gong_flag = true;

clearvars -except gong_flag

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
file_name = {'tasmin_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
               'tasmin_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
               'tasmin_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Summer'};
           
%             {'catskill_compare_stations_june2017_TMIN_combined_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CCSM4_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CCSM4_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CCSM4_historical_r6i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_HadGEM2-CC_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_HadGEM2-CC_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_HadGEM2-CC_historical_r3i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CanESM2_historical_r4i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmin_day_CanESM2_historical_r5i1p1_10yr_Middle_Running_Mean_Summer',...
%              'catskill_compare_stations_june2017_TMAX_combined_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CCSM4_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CCSM4_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CCSM4_historical_r6i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_HadGEM2-CC_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_HadGEM2-CC_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_HadGEM2-CC_historical_r3i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CanESM2_historical_r4i1p1_10yr_Middle_Running_Mean_Summer',...
%              'tasmax_day_CanESM2_historical_r5i1p1_10yr_Middle_Running_Mean_Summer',...
%              'catskill_compare_stations_june2017_PRCP_combined_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CCSM4_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CCSM4_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CCSM4_historical_r6i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_HadGEM2-CC_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_HadGEM2-CC_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_HadGEM2-CC_historical_r3i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CanESM2_historical_r4i1p1_10yr_Middle_Running_Mean_Summer',...
%              'pr_day_CanESM2_historical_r5i1p1_10yr_Middle_Running_Mean_Summer',...
%              'catskill_compare_stations_june2017_TMIN_combined_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CCSM4_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CCSM4_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CCSM4_historical_r6i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_HadGEM2-CC_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_HadGEM2-CC_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_HadGEM2-CC_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CanESM2_historical_r4i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmin_day_CanESM2_historical_r5i1p1_10yr_Middle_Running_Mean_Winter',...
%              'catskill_compare_stations_june2017_TMAX_combined_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CCSM4_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CCSM4_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CCSM4_historical_r6i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_HadGEM2-CC_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_HadGEM2-CC_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_HadGEM2-CC_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CanESM2_historical_r4i1p1_10yr_Middle_Running_Mean_Winter',...
%              'tasmax_day_CanESM2_historical_r5i1p1_10yr_Middle_Running_Mean_Winter',...
%              'catskill_compare_stations_june2017_PRCP_combined_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CCSM4_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CCSM4_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CCSM4_historical_r6i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_HadGEM2-CC_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_HadGEM2-CC_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_HadGEM2-CC_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CanESM2_historical_r4i1p1_10yr_Middle_Running_Mean_Winter',...
%              'pr_day_CanESM2_historical_r5i1p1_10yr_Middle_Running_Mean_Winter'};


% Auto-save figures
% set tag to true to save figures automatically

save_tag = true;

%% Program Start
fignum = 1;

for file_idx = 1:length(file_name)
    for fol_idx = 1:length(File_Fol)
        for model_idx = 1:length(Model_Fol)
            % Data file path
            if  isempty(File_Fol{fol_idx}) == 1
                File_Path = Model_Fol{model_idx};
            else
                File_Path = strcat(Model_Fol{model_idx},filesep,File_Fol{fol_idx});
            end

            file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'.mat');

            % Loading data file under a specific name
            if ~exist(file)
                continue      %Skips to next iteration if the file isnt in this file path
            end

            % Loading data file under a specific name
            array = struct2cell(load(file));
            array = array{1};
            val_array = str2double(array(2:end,2:end));
            yr_array = str2double(array(2:end,1));

            % Calculate the 10, 50, 90 Percentiles Arrays
            perc_10_array = prctile(val_array,10,2);
            perc_50_array = prctile(val_array,50,2);
            perc_90_array = prctile(val_array,90,2);

            %% Proper File Name
            c = textscan(file_name{file_idx},'%s','delimiter','_');
            temp_string = c{1};
            for x = 1: length(temp_string)
                if (strcmp(temp_string{x},'10yr') || strcmp(temp_string{x},'Annual') || strcmp(temp_string{x},'Seasonal'))
                    if isempty(File_Fol{fol_idx})
                        temp_string{x} = 'final';
                    else
                        temp_string{x} = 'FULL_NE_ts';
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
            loc_str = array(1,2:end);

            % Getting the Plot Type
            c = textscan(file_name{file_idx},'%s','delimiter','_');
            temp_string = c{1};
            if isempty(File_Fol{fol_idx})
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
            if ~isempty(File_Fol{fol_idx})
                c = textscan(File_Fol{fol_idx},'%s','delimiter','_');
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
            c = textscan(file_name{file_idx},'%s','delimiter','_');
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
                save_folder = strcat(Main_Dir,filesep,Model_Fol{model_idx},filesep,'Figures_',Model_Fol{model_idx});
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end

                save_folder = strcat(save_folder,filesep,plot_type);
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end

                if ~isempty(File_Fol{fol_idx})
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
                save_PNG_folder = strcat(Main_Dir,filesep,Model_Fol{model_idx},filesep,'PNGs_',Model_Fol{model_idx});
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                save_PNG_folder = strcat(save_PNG_folder,filesep,plot_type);
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                if ~isempty(File_Fol{fol_idx})
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

            % Fixing file_name string for title
            file_name_temp = strrep(file_name{file_idx},'_',' ');

            %% Plotting
            title_str = strcat(folder_name,32,plot_type,32,'- 10,50,90 Percent');
            legend_str = [loc_str,'10 percentile','50 percentile','90 percentile'];

            figure(fignum)
            hold on
            for x = 1:size(val_array,2)
                plot(yr_array,val_array(:,x),'c')
            end
            plot(yr_array,perc_10_array,'r','LineWidth',0.75)
            plot(yr_array,perc_50_array,'r','LineWidth',2.2)
            plot(yr_array,perc_90_array,'r','LineWidth',0.75)
            title({file_name_temp,title_str})
            ylabel(y_string)
            xlabel('Year')
            if strcmp(plot_type,'Precipitation')
                xlim([1930, inf])
            else
                xlim([1950, inf])
            end
            %legend(legend_str)
            if(save_tag == 1)
                savefig(strcat(save_folder,filesep,title_str))
                saveas(gcf,strcat(save_PNG_folder,filesep,title_str),'png')
            end

            fignum = fignum +1;

            clearvars -except Main_Dir Model_Fol File_Fol file_name save_tag fignum file_idx fol_idx model_idx gong_flag
        end
    end
end

%% End Gong
% Lets you know when the program finishes
if (gong_flag == true)
    load('gong.mat');
    soundsc(y,Fs);
end