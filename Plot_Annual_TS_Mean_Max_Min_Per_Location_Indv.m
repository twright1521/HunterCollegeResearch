%% Plotting Annual Time Series Data

% Plots Mean, Max, and Min Annual time series data on separate graphs
% Each location plotted on seperate graph
% Does this for multiple sets of data
% (generated from the "Create_Combined_Output_File.m" and "Create_Data_Array.m" programs)

% Files must be formatted in the following way

% Column 1 - year
% Column 2 - year fraction
% Column 3 - month
% Column 4 - date
% Column 5 - day of year
% Column 6+ - Data

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
            '21.2_HadGEM2-CC_tasmin_output'};     

% File Name - must end with  "_FULL_NE_ts"
% List of the individual files
file_name = {'catskill_compare_stations_june2017_TMIN_combined_FULL_NE_ts',...
             'tasmin_day_CCSM4_historical_r1i1p1_FULL_NE_ts',...
             'tasmin_day_CCSM4_historical_r2i1p1_FULL_NE_ts',...
             'tasmin_day_CCSM4_historical_r6i1p1_FULL_NE_ts',...
             'tasmin_day_HadGEM2-CC_historical_r1i1p1_FULL_NE_ts',...
             'tasmin_day_HadGEM2-CC_historical_r2i1p1_FULL_NE_ts',...
             'tasmin_day_HadGEM2-CC_historical_r3i1p1_FULL_NE_ts',...
             'tasmin_day_CanESM2_historical_r1i1p1_FULL_NE_ts',...
             'tasmin_day_CanESM2_historical_r2i1p1_FULL_NE_ts',...
             'tasmin_day_CanESM2_historical_r3i1p1_FULL_NE_ts',...
             'tasmin_day_CanESM2_historical_r4i1p1_FULL_NE_ts',...
             'tasmin_day_CanESM2_historical_r5i1p1_FULL_NE_ts'};


% Plot Minimum Values
% set the tag to true to plot minimum values

min_plot_tag = true;

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

            [m,n] = size(array);

            % Vecter of each year in data array 
            a = array(2:end,1);

            [temp_yr_array,m1,~] = unique(a,'first');
            [~,d1] = sort(m1);
            yr_array = str2double(temp_yr_array(d1));

            clearvars a m1 d1 temp_yr_array

            % Calculate Annual Average, Maximum, and Minimum for each location
            y = 2;
            avg_array = [];
            min_array = [];
            max_array = [];

            for x = str2double(array{2,1}):str2double(array{m,1})

                val_array = [];

                while (str2double(array{y,1}) == x)
                    vals = str2double(array(y,6:n));
                    val_array = [val_array; vals];

                    clearvars vals
                    if (y == m)
                        break
                    else
                        y = y + 1;
                    end

                end

                test_nan = ~isnan(val_array);

                for z = 1:size(test_nan,2)
                    sum_test_nan = sum(test_nan(:,z));
                    if (sum_test_nan >= .8*365)
                        temp_avg_array(1,z) = mean(val_array(:,z),'omitnan');
                        temp_min_array(1,z) = min(val_array(:,z));
                        temp_max_array(1,z) = max(val_array(:,z));
                    else
                        temp_avg_array(1,z) = NaN;
                        temp_min_array(1,z) = NaN;
                        temp_max_array(1,z) = NaN;
                    end
                    clearvars sum_test_nan
                end

                avg_array = [avg_array; temp_avg_array];
                min_array = [min_array; temp_min_array];
                max_array = [max_array; temp_max_array];

                clearvars val_array temp_avg_array temp_max_array temp_min_array test_nan

            end

            %% Plot Devices
            loc_str = array(1,6:n);

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

                save_folder = strcat(save_folder,filesep,file_name{file_idx});
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end

                save_folder = strcat(save_folder,filesep,'Annual');
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end   

                save_folder_mean = strcat(save_folder,filesep,'Mean');
                if (exist(save_folder_mean,'dir') == 0)
                    mkdir(save_folder_mean)
                end

                save_folder_max = strcat(save_folder,filesep,'Max');
                if (exist(save_folder_max,'dir') == 0)
                    mkdir(save_folder_max)
                end

                save_folder_min = strcat(save_folder,filesep,'Min');
                if (exist(save_folder_min,'dir') == 0)
                    mkdir(save_folder_min)
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

                save_PNG_folder = strcat(save_PNG_folder,filesep,file_name{file_idx});
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                save_PNG_folder = strcat(save_PNG_folder,filesep,'Annual');
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                save_PNG_folder_mean = strcat(save_PNG_folder,filesep,'Mean');
                if (exist(save_PNG_folder_mean,'dir') == 0)
                    mkdir(save_PNG_folder_mean)
                end

                save_PNG_folder_max = strcat(save_PNG_folder,filesep,'Max');
                if (exist(save_PNG_folder_max,'dir') == 0)
                    mkdir(save_PNG_folder_max)
                end

                save_PNG_folder_min = strcat(save_PNG_folder,filesep,'Min');
                if (exist(save_PNG_folder_min,'dir') == 0)
                    mkdir(save_PNG_folder_min)
                end
            end

            % Fixing file_name string for title
            file_name_temp = strrep(file_name{file_idx},'_',' ');

            %% Plotting

            for x = 1:n-5
                % Mean
                title_str = strcat('Annual Mean',32,plot_type,32,'-',32,loc_str{x});
                figure(fignum)
                plot(yr_array,avg_array(:,x),'b')
                title({file_name_temp,title_str})
                ylabel(y_string)
                xlabel('Year')
                xlim([yr_array(1),yr_array(length(yr_array))])

                fignum = fignum + 1;

                if(save_tag == 1)
                    savefig(strcat(save_folder_mean,filesep,title_str))
                    saveas(gcf,strcat(save_PNG_folder_mean,filesep,title_str),'png')
                end

                clearvars title_str

                % Max
                title_str = strcat('Annual Max',32,plot_type,32,'-',32,loc_str{x});
                figure(fignum)
                plot(yr_array,max_array(:,x),'r')
                title({file_name_temp,title_str})
                ylabel(y_string)
                xlabel('Year')
                xlim([yr_array(1),yr_array(length(yr_array))])

                fignum = fignum + 1;

                if(save_tag == 1)
                    savefig(strcat(save_folder_max,filesep,title_str))
                    saveas(gcf,strcat(save_PNG_folder_max,filesep,title_str),'png')
                end

                clearvars title_str

                if (min_plot_tag == 1)
                    % Min
                    title_str = strcat('Annual Min',32,plot_type,32,'-',32,loc_str{x});
                    figure(fignum)
                    plot(yr_array,min_array(:,x),'k')
                    title({file_name_temp,title_str})
                    ylabel(y_string)
                    xlabel('Year')
                    xlim([yr_array(1),yr_array(length(yr_array))])
                    fignum = fignum + 1;

                    if(save_tag == 1)
                        savefig(strcat(save_folder_min,filesep,title_str))
                        saveas(gcf,strcat(save_PNG_folder_min,filesep,title_str),'png')
                    end

                    clearvars title_str
                end
            end

            clearvars -except model_idx fol_idx gong_flag Main_Dir Model_Fol File_Fol file_name file_idx save_tag min_plot_tag fignum 

        end
    end
end

%% End Gong
if (gong_flag == true)
    load('gong.mat');
    soundsc(y,Fs);
end