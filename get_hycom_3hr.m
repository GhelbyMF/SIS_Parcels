
% ----------
% get_hycom_3hr.m 
% 
% Matlab script to batch-download a temporal series of 3-hr hycom model outputs of standard variables at all depths
% This script is used to download hycom model data from www.hycom.org 

% Greg Pelletier (gjpelletier@gmail.com) (https://github.com/gjpelletier/get_hycom)
% ----------

% ----------
% USER INPUT SECTION

% - - -
% Edit the var_list as needed to download any subset of these available variables:
var_list = 'water_u,water_v';

% specify spatial limits (default below is Parker MacCready's HYCOM bounding box for the boundary of the LiveOcean model):
north =  65;              % -80 to 80 degN          
south =  10;              % -80 to 80 degN
west = 110;       % 0 to 360 degE
east = 160;       % 0 to 360 degE

% - - -
% specify the directory where the extracted nc files will be saved:
resultDirectory = 'G:\hycom\data\';         % include the ending '\

% -  
% Specify the glb, expt, date_start, and number_of_days up to one year at a time between 1994 to present
glb = 'GLBy0.08';                        % code for the HYCOM grid that (see the note below for guidance)
expt = '93.0';                           % code for the HYCOM experiment (see the note below for guidance)
date_start = datetime(2021,12,12,21,0,0);  % starting datetime (starting hour must be either 0, 3, 6, 9, 12, 15, 18, or 21, and must be 12 if the date_start is Jan 1 of the year or first day of the expt. The date_start must be within the range of dates for the glb and expt as described at www.hycom.org)
date_end = datetime(2022,1,1,9,0,0);  % ending datetime (hour must be either 0, 3, 6, 9, 12, 15, 18, or 21, and must be 21 if the date_end is Dec 31 of the year or last day of the expt. The date_end must be within the range of dates for the glb and expt as described at www.hycom.org)

% IMPORTANT: Note for selecting the correct glb and expt for the dates to be downloaded (more info on the glb and expt is available at www.hycom.org if needed):
% Use glb = 'GLBv0.08' and expt = '53.X' for dates between 1994-2015
% Use glb = 'GLBv0.08' and expt = '56.3' for dates between 1/1/2016 or 7/1/2014 to 4/30/2016
% Use glb = 'GLBv0.08' and expt = '57.2' for dates between 5/1/2016 to 1/31/2017
% Use glb = 'GLBv0.08' and expt = '92.8' for dates between 2/1/2017 to 5/31/2017
% Use glb = 'GLBv0.08' and expt = '57.7' for dates between 6/1/2017 to 9/30/2017
% Use glb = 'GLBv0.08' and expt = '92.9' for dates between 10/1/2017 to 12/31/2017
% Use glb = 'GLBv0.08' and expt = '93.0' for dates between 1/1/2018 to 12/31/2018 or 2/18/2020
% Use glb = 'GLBy0.08' and expt = '93.0' for dates between 12/4/2018 or 1/1/2019-present

% END OF USER INPUTS
% ----------
% ----------

% ----------

% make a list of datetimes to loop through at 3-hourly intervals
dt_list = (date_start:hours(3):date_end)';		
 
% - - -
% create a directory if it does not already exist
%if not(isfolder(resultDirectory))
%	   mkdir(resultDirectory);
%end

% loop over all datetimes to download hycom nc files for each datetime
pause('on');
tt1=now;
maxtry = 100;
disp(['** Working on ', glb, '/expt_', expt, ' **'])
for i = 1:numel(dt_list)
	dstr0 = datestr(datenum(dt_list(i,1)),'yyyy-mm-dd-Thh:00:00');							% current datetime in hycom url format
	disp(['Attempting to download hycom data from ', dstr0]);
	yyyy = datestr(datenum(dt_list(i,1)),'yyyy');											% current datetime year string (for 53.X url)
	out_fn = [resultDirectory, datestr(datenum(dt_list(i,1)),'yyyymmdd_hh.nc')];			% output nc file name
	counter = 1;
	got_file = false;
	while counter <= maxtry & ~got_file
		if strcmp(expt,'53.X')
			url = ['http://ncss.hycom.org/thredds/ncss/', glb, '/expt_', expt, '/data/', yyyy, ...
				'?var=', var_list, ...
				'&north=', num2str(north), '&south=', num2str(south), '&west=', num2str(west), '&east=', num2str(east), ...
				'&disableProjSubset=on&horizStride=1', ...
				'&time_start=', dstr0, '&time_end=', dstr0, '&timeStride=8', ...
				'&vertCoord=&addLatLon=true&accept=netcdf4'];
		else
			url = ['http://ncss.hycom.org/thredds/ncss/', glb, '/expt_', expt, ...
				'?var=', var_list, ...
				'&north=', num2str(north), '&south=', num2str(south), '&west=', num2str(west), '&east=', num2str(east), ...
				'&disableProjSubset=on&horizStride=1', ...
				'&time_start=', dstr0, '&time_end=', dstr0, '&timeStride=8', ...
				'&vertCoord=&addLatLon=true&accept=netcdf4'];
		end
		try
			urlwrite(url,out_fn);		
			disp(['Successfully downloaded: ', out_fn]);
			got_file = true;
		catch
			if counter == maxtry
				disp(['Failed to download: ', out_fn]);
			end
			counter = counter + 1;
			pause(0.1);		% pause for 0.1 seconds between trials
			got_file = false;
		end
	end
end
pause('off');

totmin = (now - tt1)*1440;             % total time elapsed for loop over all datetimes in minutes
disp('All downloads are completed.')
disp(['Total time elapsed: ', num2str(round(totmin,1)), ' minutes'])



