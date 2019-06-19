%% Annual Mean, Max, and Min Files

% Creates Annual Mean, Max, and Min Files from Combined file data
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
            yr_array = temp_yr_array(d1);

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

                % Tests for completeness of data
                % Only accepts years with 80% usable data
                test_nan = ~isnan(val_array);

                for z = 1:size(test_nan,2)
                    sum_test_nan = sum(test_nan(:,z));
                    if (sum_test_nan >= .8*365) %<--- to change data restriction change here i.e 0.8 == 80%
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

            %% Saving Data Array
            % Creating the new file name from the old name
            % i.e. changing the end of the file name
            name_flag = false;
            c = textscan(file_name{file_idx},'%s','delimiter','_');
            temp_string = c{1};
            for x = 1: length(temp_string)
                if strcmp(temp_string{x},'FULL')
                    name_flag = true;
                    temp_string{x} = 'Annual';
                    for y = x+1:length(temp_string)
                        temp_string{y} = [];
                    end
                    break
                else
                    if strcmp(temp_string{x},'final')
                        name_flag = true;
                        temp_string{x} = 'Annual';
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

            % Creating the output array
            output_array{1,1} = array{1,1};
            for x = 6:size(array,2)
                output_array{1,x-4} = array{1,x};
            end

            for x = 1:size(avg_array,1)
                for y = 1:size(avg_array,2)+1
                    if y == 1
                        output_array{x+1,y} = yr_array{x,1};
                    else
                        output_array{x+1,y} = num2str(avg_array(x,y-1));
                    end
                end
            end
            
            % Saving the year-value Mean array to a matlab usable file
            save(strcat(Main_Dir,filesep,File_Path,filesep,name_string,'_Mean.mat'),'output_array')

            %% Writing Files

            % Writing annual mean file
            new_file = strcat(Main_Dir,filesep,File_Path,filesep,name_string,'_Mean.txt');
            fid = fopen(new_file,'wt');

            fprintf(fid,strcat('Year',32));

            for y = 6:n
                fprintf(fid,strcat(array{1,y},32));
            end

            fprintf(fid,'\n');

            for x = 1:length(yr_array)
                fprintf(fid,strcat(yr_array{x},32));
                for y = 1:n-5

                    fprintf(fid,strcat(num2str(avg_array(x,y)),32));
                end
                fprintf(fid,'\n');
            end

            fclose(fid);

            % Writing annual max file
            new_file = strcat(Main_Dir,filesep,File_Path,filesep,name_string,'_Max.txt');
            fid = fopen(new_file,'wt');

            fprintf(fid,strcat('Year',32));

            for y = 6:n
                fprintf(fid,strcat(array{1,y},32));
            end

            fprintf(fid,'\n');

            for x = 1:length(yr_array)
                fprintf(fid,strcat(yr_array{x},32));
                for y = 1:n-5

                    fprintf(fid,strcat(num2str(max_array(x,y)),32));
                end
                fprintf(fid,'\n');
            end

            fclose(fid);

            % Writing Annual Min file
            if (min_tag == 1)
                new_file = strcat(Main_Dir,filesep,File_Path,filesep,name_string,'_Min.txt');
                fid = fopen(new_file,'wt');

                fprintf(fid,strcat('Year',32));

                for y = 6:n
                    fprintf(fid,strcat(array{1,y},32));
                end

                fprintf(fid,'\n');

                for x = 1:length(yr_array)
                    fprintf(fid,strcat(yr_array{x},32));
                    for y = 1:n-5

                        fprintf(fid,strcat(num2str(min_array(x,y)),32));
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