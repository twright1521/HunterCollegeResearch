%% Seasonal Mean, Max, Min Files

% Creates Seasonal Mean, Max, and Min Files from Combined file data
% (generated from the "Create_Combined_Output_File.m" and "Create_Data_Array.m" programs)

% Also saves mean data into a data array for future use
% Runs multiple files

% This program takes a very long time

% Input Data files must be formatted in the following way

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
            '21.2_HadGEM2-CC_tasmin_output','5.1_cccma_canesm2_tasmax_output',...
            '7.1_ncar_ccsm4_tasmax_output','21.2_HadGEM2-CC_tasmax_output',...
            '5.1_cccma_canesm2_output','7.1_ncar_ccsm4_output',...
            '21.2_HadGEM2-CC_output'};     

% File Name - must end with  "_FULL_NE_ts"
% List of the individual files
file_name = {'catskill_compare_stations_june2017_TMIN_combined_final',...
             'catskill_compare_stations_june2017_TMAX_combined_final',...
             'catskill_compare_stations_june2017_PRCP_combined_final'};

% Create Minimum Values File
% set the tag to true to create minimum values file

min_tag = true;

%% Program Start

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

            clearvars m1 d1 temp_yr_array a

            % Calculate Annual Average, Maximum, and Minimum 
            % for each location for each season
            y = 2;
            avg_array_Summer = [];
            avg_array_Winter = [];

            max_array_Summer = [];
            max_array_Winter = [];

            min_array_Summer = [];
            min_array_Winter = [];

            next_winter = [];

            for x = str2double(array{2,1}):str2double(array{m,1})

                temp_winter = next_winter;
                temp_summer = [];
                next_winter = []; % This array is added for the next winter season from the end of the year

                while (str2double(array{y,1}) == x)

                    vals = str2double(array(y,6:n));

                    if  (str2double(array{y,3}) >= 1 && str2double(array{y,3}) <= 5)
                        temp_winter = [temp_winter; vals];
                    else
                        if (str2double(array{y,3}) >= 6 && str2double(array{y,3}) <= 10)
                            temp_summer = [temp_summer; vals];
                        else
                            if (str2double(array{y,3}) >= 11 && str2double(array{y,3}) <= 12)
                                next_winter = [next_winter; vals];
                            end
                        end
                    end

                    clearvars vals

                    if (y == m)
                        break
                    else
                        y = y + 1;
                    end

                end

                winter_test_nan = ~isnan(temp_winter);
                summer_test_nan = ~isnan(temp_summer);

                temp_avg_array_Summer = [];
                temp_avg_array_Winter = [];

                for z = 1:size(winter_test_nan,2)
                    sum_winter_test_nan = sum(winter_test_nan(:,z));
                    if (sum_winter_test_nan >= .8*210)
                        temp_avg_array_Winter(1,z) = mean(temp_winter(:,z),'omitnan');
                        temp_min_array_Winter(1,z) = min(temp_winter(:,z));
                        temp_max_array_Winter(1,z) = max(temp_winter(:,z));
                    else
                        temp_avg_array_Winter(1,z) = NaN;
                        temp_min_array_Winter(1,z) = NaN;
                        temp_max_array_Winter(1,z) = NaN;
                    end
                    clearvars sum_winter_test_nan
                end

                for z = 1:size(summer_test_nan,2)
                    sum_summer_test_nan = sum(summer_test_nan(:,z));
                    if (sum_summer_test_nan >= .8*150)
                        temp_avg_array_Summer(1,z) = mean(temp_summer(:,z),'omitnan');
                        temp_min_array_Summer(1,z) = min(temp_summer(:,z));
                        temp_max_array_Summer(1,z) = max(temp_summer(:,z));
                    else
                        temp_avg_array_Summer(1,z) = NaN;
                        temp_min_array_Summer(1,z) = NaN;
                        temp_max_array_Summer(1,z) = NaN;
                    end
                    clearvars sum_summer_test_nan
                end

                if ~isempty(temp_avg_array_Summer)
                    avg_array_Summer = [avg_array_Summer; temp_avg_array_Summer];
                    min_array_Summer = [min_array_Summer; temp_min_array_Summer];
                    max_array_Summer = [max_array_Summer; temp_max_array_Summer];
                else
                    for idx = 1:n-5
                        temp_nan_array(1,idx) = NaN;
                    end
                    avg_array_Summer = [avg_array_Summer; temp_nan_array];
                    min_array_Summer = [min_array_Summer; temp_nan_array];
                    max_array_Summer = [max_array_Summer; temp_nan_array];
                end

                if ~isempty(temp_avg_array_Winter)
                    avg_array_Winter = [avg_array_Winter; temp_avg_array_Winter];
                    min_array_Winter = [min_array_Winter; temp_min_array_Winter];
                    max_array_Winter = [max_array_Winter; temp_max_array_Winter];
                else
                    for idx = 1:n-5
                        temp_nan_array(1,idx) = NaN;
                    end
                    avg_array_Winter = [avg_array_Winter; temp_nan_array];
                    min_array_Winter = [min_array_Winter; temp_nan_array];
                    max_array_Winter = [max_array_Winter; temp_nan_array];
                end

                clearvars temp_max_array_Winter temp_min_array_Winter temp_avg_array_Winter temp_max_array_Summer temp_min_array_Summer temp_avg_array_Summer

            end

            %% Saving Data Array
            % Creating the new file name from the old name
            % i.e. changing the end of the file name
            name_flag = false;
            c = textscan(file_name{file_idx},'%s','delimiter','_');
            temp_string = c{1};
            for x = 1: length(temp_string)
                if strcmp(temp_string{x},'FULL')
                    name_flag = true;
                    temp_string{x} = 'Seasonal';
                    for y = x+1:length(temp_string)
                        temp_string{y} = [];
                    end
                    break
                else
                    if strcmp(temp_string{x},'final')
                        name_flag = true;
                        temp_string{x} = 'Seasonal';
                        for y = x+1:length(temp_string)
                            temp_string{y} = [];
                        end
                        break
                    end
                end
            end

            % Checks to ensure the proper file name was used
            if name_flag == false
                error('Check File Name - Incorrect File Used')
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

            % Creating the output array - Summer
            output_array{1,1} = array{1,1};
            for x = 6:size(array,2)
                output_array{1,x-4} = array{1,x};
            end

            for x = 1:size(avg_array_Summer,1)
                for y = 1:size(avg_array_Summer,2)+1
                    if y == 1
                        output_array{x+1,y} = num2str(yr_array(x,1));
                    else
                        output_array{x+1,y} = num2str(avg_array_Summer(x,y-1));
                    end
                end
            end
            
            % Saving the year-value Mean array to a matlab usable file
            save(strcat(Main_Dir,filesep,File_Path,filesep,name_string,'_Mean_Summer.mat'),'output_array')
            
            clearvars output_array
            
             % Creating the output array - Winter
            output_array{1,1} = array{1,1};
            for x = 6:size(array,2)
                output_array{1,x-4} = array{1,x};
            end

            for x = 1:size(avg_array_Winter,1)
                for y = 1:size(avg_array_Winter,2)+1
                    if y == 1
                        output_array{x+1,y} = num2str(yr_array(x,1));
                    else
                        output_array{x+1,y} = num2str(avg_array_Winter(x,y-1));
                    end
                end
            end
            
            % Saving the year-value Mean array to a matlab usable file
            save(strcat(Main_Dir,filesep,File_Path,filesep,name_string,'_Mean_Winter.mat'),'output_array')
            
            
            %% Writing Summer Files

            % Writing mean file
            new_file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'_Jun_Oct_Mean.txt');
            fid = fopen(new_file,'wt');

            fprintf(fid,strcat('Year',32));

            for y = 6:n
                fprintf(fid,strcat(array{1,y},32));
            end

            for x = 1:length(yr_array)
                fprintf(fid,strcat(num2str(yr_array(x)),32));
                for y = 1:n-5

                    fprintf(fid,strcat(num2str(avg_array_Summer(x,y)),32));
                end
                fprintf(fid,'\n');
            end

            fclose(fid);

            % Writing max file
            new_file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'_Jun_Oct_Max.txt');
            fid = fopen(new_file,'wt');

            fprintf(fid,strcat('Year',32));

            for y = 6:n
                fprintf(fid,strcat(array{1,y},32));
            end

            for x = 1:length(yr_array)
                fprintf(fid,strcat(num2str(yr_array(x)),32));
                for y = 1:n-5

                    fprintf(fid,strcat(num2str(max_array_Summer(x,y)),32));
                end
                fprintf(fid,'\n');
            end

            fclose(fid);

            % Writing min file
            if (min_tag == 1)
                new_file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'_Jun_Oct_Min.txt');
                fid = fopen(new_file,'wt');

                fprintf(fid,strcat('Year',32));

                for y = 6:n
                    fprintf(fid,strcat(array{1,y},32));
                end

                for x = 1:length(yr_array)
                    fprintf(fid,strcat(num2str(yr_array(x)),32));
                    for y = 1:n-5

                        fprintf(fid,strcat(num2str(min_array_Summer(x,y)),32));
                    end
                    fprintf(fid,'\n');
                end

                fclose(fid);
            end

            %% Writing Winter Files

            % Writing mean file
            new_file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'_Nov_May_Mean.txt');
            fid = fopen(new_file,'wt');

            fprintf(fid,strcat('Year',32));

            for y = 6:n
                fprintf(fid,strcat(array{1,y},32));
            end

            for x = 1:length(yr_array)
                fprintf(fid,strcat(num2str(yr_array(x)),32));
                for y = 1:n-5

                    fprintf(fid,strcat(num2str(avg_array_Winter(x,y)),32));
                end
                fprintf(fid,'\n');
            end

            fclose(fid);

            % Writing max file
            new_file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'_Nov_May_Max.txt');
            fid = fopen(new_file,'wt');

            fprintf(fid,strcat('Year',32));

            for y = 6:n
                fprintf(fid,strcat(array{1,y},32));
            end

            for x = 1:length(yr_array)
                fprintf(fid,strcat(num2str(yr_array(x)),32));
                for y = 1:n-5

                    fprintf(fid,strcat(num2str(max_array_Winter(x,y)),32));
                end
                fprintf(fid,'\n');
            end

            fclose(fid);

            % Writing min file
            if (min_tag == 1)
                new_file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'_Nov_May_Min.txt');
                fid = fopen(new_file,'wt');

                fprintf(fid,strcat('Year',32));

                for y = 6:n
                    fprintf(fid,strcat(array{1,y},32));
                end

                for x = 1:length(yr_array)
                    fprintf(fid,strcat(num2str(yr_array(x)),32));
                    for y = 1:n-5

                        fprintf(fid,strcat(num2str(min_array_Winter(x,y)),32));
                    end
                    fprintf(fid,'\n');
                end

                fclose(fid);
            end
            
            clearvars -except Main_Dir Model_Fol File_Fol file_name file_idx fol_idx model_idx gong_flag min_tag
        end
    end
end

%% End Gong
if (gong_flag == true)
    load('gong.mat');
    soundsc(y,Fs);
end