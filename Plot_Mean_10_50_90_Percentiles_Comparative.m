%% Comparative Plotting of Mean 10, 50, and 90 Percentile

% Plots the mean 10, 50, and 90 percentiles
% For two different sets of data
% Data sets must be of the same type, i.e 'Precipitation', 'Tmax', or 'Tmin'
% Can run multiple models at once

% Can process Annual, Seasonal, or 10yr Running Mean data

% Mainly used for comparing station data to model output
% Can be used to compare different models as well

% Data Arrays must be formatted in the following way

% Column 1 - Year
% Column 2+ - Mean Data

clearvars 

%% Inputs

% Main Directory
Main_Dir = 'C:\Users\Trevor Riot\Documents\College Stuff\Research\Hunter Research';

%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% Data Set #1 - Use For Models
% Can contain multiple models/ensembles
% Model Folder 
Model_Fol_1 = 'cmip5_may15_2018';

% File Folder - List of the separate file folders - i.e. model folders
%For data files, use empty string
File_Fol_1 = {'5.1_cccma_canesm2_tasmin_output','7.1_ncar_ccsm4_tasmin_output',...
              '21.2_HadGEM2-CC_tasmin_output'};      

% File Name - For 10-yr Mean 
file_name_1 = {'tasmin_day_CCSM4_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_CCSM4_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_CCSM4_historical_r6i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_HadGEM2-CC_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_HadGEM2-CC_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_HadGEM2-CC_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_CanESM2_historical_r1i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_CanESM2_historical_r2i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_CanESM2_historical_r3i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_CanESM2_historical_r4i1p1_10yr_Middle_Running_Mean_Winter',...
               'tasmin_day_CanESM2_historical_r5i1p1_10yr_Middle_Running_Mean_Winter'};

%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% Data Set #2 - Use For Data
% This is what all the files in in Data Set #1 get compared to,
% individually
% Model Folder 
Model_Fol_2 = 'catskills_sta_data_may15_2018';

% File Folder  
File_Fol_2 = [];     %For data files, use empty string or array

% File Name - For 10-yr Mean 
file_name_2 = {'catskill_compare_stations_june2017_TMIN_combined_10yr_Middle_Running_Mean_Winter'};

%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% Auto-save figures
% set tag to true to save figures automatically

save_tag = true;

%% Program Start 
fignum = 1;

for file_idx_1 = 1:length(file_name_1)
    for file_idx_2 = 1:length(file_name_2)
        for fol_idx_1 = 1:length(File_Fol_1)
            %% Data Set #1
            % Data file path
            if  isempty(File_Fol_1{fol_idx_1}) == 1
                File_Path_1 = Model_Fol_1;
            else
                File_Path_1 = strcat(Model_Fol_1,filesep,File_Fol_1{fol_idx_1});
            end

            file_1 = strcat(Main_Dir,filesep,File_Path_1,filesep,file_name_1{file_idx_1},'.mat');

            % Check if file exists
            if ~exist(file_1)
                continue      %Skips to next iteration if the file isnt in this file path
            end
            
            % Loading data
            array_1 = struct2cell(load(file_1));
            array_1 = array_1{1};
            val_array_1 = str2double(array_1(2:end,2:end));
            yr_array_1 = str2double(array_1(2:end,1));

            % Calculate the 10, 50, 90 Percentiles Arrays
            perc_10_array_1 = prctile(val_array_1,10,2);
            perc_50_array_1 = prctile(val_array_1,50,2);
            perc_90_array_1 = prctile(val_array_1,90,2);

            %% Data Set #2
            % Data file path
            if  isempty(File_Fol_2) == 1
                File_Path_2 = Model_Fol_2;
            else
                File_Path_2 = strcat(Model_Fol_2,filesep,File_Fol_2);
            end

            file_2 = strcat(Main_Dir,filesep,File_Path_2,filesep,file_name_2{file_idx_2},'.mat');

            % Loading data file under a specific name
            array_2 = struct2cell(load(file_2));
            array_2 = array_2{1};
            val_array_2 = str2double(array_2(2:end,2:end));
            yr_array_2 = str2double(array_2(2:end,1));

            % Calculate the 10, 50, 90 Percentiles Arrays
            perc_10_array_2 = prctile(val_array_2,10,2);
            perc_50_array_2 = prctile(val_array_2,50,2);
            perc_90_array_2 = prctile(val_array_2,90,2);

            %% Proper File Name
            c = textscan(file_name_1{file_idx_1},'%s','delimiter','_');
            temp_string = c{1};
            for x = 1: length(temp_string)
                if strcmp(temp_string{x},'10yr')
                    if isempty(File_Fol_1{fol_idx_1})
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

            % Second Save Name
            c = textscan(file_name_2{file_idx_2},'%s','delimiter','_');
            temp_string = c{1};
            for x = 1: length(temp_string)
                if strcmp(temp_string{x},'10yr')
                    if isempty(File_Fol_2)
                        save_name_2 = temp_string{1};
                    else
                        save_name_2 = strcat(temp_string{3},'_',temp_string{x-1});
                    end
                    break
                end
            end
            %% Plot Devices

            % Getting the Plot Type
            c = textscan(file_name_1{file_idx_1},'%s','delimiter','_');
            temp_string = c{1};
            if isempty(File_Fol_1{fol_idx_1})
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
            if ~isempty(File_Fol_1{fol_idx_1})
                c = textscan(File_Fol_1{fol_idx_1},'%s','delimiter','_');
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
            c = textscan(file_name_2{file_idx_2},'%s','delimiter','_');
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

                if ~isempty(File_Fol_1{fol_idx_1})
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

                if ~isempty(File_Fol_1{fol_idx_1})
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

            % Creating Legend String
            c = textscan(file_name_1{file_idx_1},'%s','delimiter','_');
            temp_string_1 = c{1};
            if strcmp(temp_string_1{1},'catskill')
                pidx(1) = 1;
            else 
                pidx(1) = 5;
            end

            c = textscan(file_name_2{file_idx_2},'%s','delimiter','_');
            temp_string_2 = c{1};
            if strcmp(temp_string_2{1},'catskill')
                pidx(2) = 1;
            else 
                pidx(2) = 5;
            end

            legend_str{1} = strcat('10',32,temp_string_1{pidx(1)});
            legend_str{2} = strcat('50');
            legend_str{3} = strcat('90');
            legend_str{4} = strcat('10',32,temp_string_2{pidx(2)});
            legend_str{5} = strcat('50');
            legend_str{6} = strcat('90');

            % Fixing file_name string for title
            file_name_1_temp = strrep(file_name_1{file_idx_1},'_',' ');
            file_name_2_temp = strrep(file_name_2{file_idx_2},'_',' ');

            %
            %% Plotting
            title_str = strcat(folder_name,32,plot_type,32,'- 10,50, and 90 Percentiles');

            figure(fignum)
            hold on
            % Data Set #1
            plot(yr_array_1,perc_10_array_1,'b--')
            plot(yr_array_1,perc_50_array_1,'b','LineWidth',2.2)
            plot(yr_array_1,perc_90_array_1,'b-.')
            % Data Set #2
            plot(yr_array_2,perc_10_array_2,'r--')
            plot(yr_array_2,perc_50_array_2,'r','LineWidth',2.2)
            plot(yr_array_2,perc_90_array_2,'r-.')
            title({file_name_1_temp,'Compared to:',file_name_2_temp,title_str})
            ylabel(y_string)
            xlabel('Year')
            if strcmp(plot_type,'Precipitation')
                xlim([1930, yr_array_1(end)])
            else
                xlim([1950, yr_array_1(end)])
            end
            legend(legend_str)

            if(save_tag == 1)
                savefig(strcat(save_folder,filesep,'10_50_90_percent_',save_name_1,'_Compared_to_',save_name_2))
                saveas(gcf,strcat(save_PNG_folder,filesep,'10_50_90_percent_',save_name_1,'_Compared_to_',save_name_2),'png')
            end

            fignum = fignum +1;

            clearvars -except fol_idx_1 Main_Dir Model_Fol_1 File_Fol_1 file_name_1 Model_Fol_2 File_Fol_2 file_name_2 plot_type save_tag fignum file_idx_1 file_idx_2
        end
    end
end

