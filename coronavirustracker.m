% Coronavirus Tracker - Country Tracker - Joshua McGee
% Created to track the spread of Coronavirus (COVID-19) 
% Data is stored online and is provided via JHU CSSE from various sources including:
% "the World Health Organization (WHO), DXY.cn. Pneumonia. 2020, BNO News,
% National Health Commission of the People? Republic of China (NHC),
% China CDC (CCDC), Hong Kong Department of Health, Macau Government, Taiwan CDC, US CDC,
% Government of Canada, Australia Government Department of Health,
% European Centre for Disease Prevention and Control (ECDC) and Ministry of
% Health Singapore (MOH)"
% data set is updated every day and an additional column is added for the
% previous days data

%important settings:
country = "US"; %specify country to model
dp = 7; %number of days to predict for
prediction_enabled = 1; %set to 1 for logistic model curve, 0 to turn off

%Obtaining and formating data - courtesy of Toshi Takeuchi - https://www.mathworks.com/matlabcentral/profile/authors/951521
result=webread('https://proxy.hxlstandard.org/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_19-covid-Confirmed.csv&filename=time_series_2019-ncov-Confirmed.csv','options','table');
deathresult = webread('https://proxy.hxlstandard.org/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_19-covid-Deaths.csv&filename=time_series_2019-ncov-Deaths.csv','options','table');
writetable(result,'result.txt','WriteVariableNames',false);
writetable(deathresult,'deathresult.txt','WriteVariableNames',false);
opts = detectImportOptions('result.txt', "TextType","string");
opts1 = detectImportOptions('deathresult.txt', "TextType","string");
opts.VariableNamesLine = 1;
opts.DataLines = [2,inf];
opts.PreserveVariableNames = true;
opts1.VariableNamesLine = 1;
opts1.DataLines = [2,inf];
opts1.PreserveVariableNames = true;
times_conf = readtable('result.txt',opts);
times_conf1 = readtable('deathresult.txt',opts);
times_conf.("Country/Region")(times_conf.("Country/Region") == "China") = "Mainland China";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Czechia") = "Czech Republic";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Iran (Islamic Republic of)") = "Iran";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Republic of Korea") = "Korea, South";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Republic of Moldova") = "Moldova";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Russian Federation") = "Russia";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Taipei and environs") = "Taiwan";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Taiwan*") = "Taiwan";
times_conf.("Country/Region")(times_conf.("Country/Region") == "United Kingdom") = "UK";
times_conf.("Country/Region")(times_conf.("Country/Region") == "Viet Nam") = "Vietnam";
times_conf.("Country/Region")(times_conf.("Province/State") == "St Martin") = "St Martin";
times_conf.("Country/Region")(times_conf.("Province/State") == "Saint Barthelemy") = "Saint Barthelemy";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "China") = "Mainland China";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Czechia") = "Czech Republic";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Iran (Islamic Republic of)") = "Iran";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Republic of Korea") = "Korea, South";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Republic of Moldova") = "Moldova";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Russian Federation") = "Russia";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Taipei and environs") = "Taiwan";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Taiwan*") = "Taiwan";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "United Kingdom") = "UK";
times_conf1.("Country/Region")(times_conf1.("Country/Region") == "Viet Nam") = "Vietnam";
times_conf1.("Country/Region")(times_conf1.("Province/State") == "St Martin") = "St Martin";
times_conf1.("Country/Region")(times_conf1.("Province/State") == "Saint Barthelemy") = "Saint Barthelemy";
vars = times_conf.Properties.VariableNames;
vars1 = times_conf1.Properties.VariableNames;
times_conf_country = groupsummary(times_conf,"Country/Region",{'sum','mean'},vars(3:end));
times_conf_country1 = groupsummary(times_conf1,"Country/Region",{'sum','mean'},vars1(3:end));
vars = times_conf_country.Properties.VariableNames;
vars = regexprep(vars,"^(sum_)(?=L(a|o))","remove_");
vars = regexprep(vars,"^(mean_)(?=[0-9])","remove_");
vars = erase(vars,{'sum_','mean_'});
times_conf_country.Properties.VariableNames = vars;
vars1 = times_conf_country1.Properties.VariableNames;
vars1 = regexprep(vars1,"^(sum_)(?=L(a|o))","remove_");
vars1 = regexprep(vars1,"^(mean_)(?=[0-9])","remove_");
vars1 = erase(vars1,{'sum_','mean_'});
times_conf_country1.Properties.VariableNames = vars;
infectedtable = removevars(times_conf_country,[{'GroupCount'},vars(contains(vars,"remove_"))]);
countrytable = infectedtable(strcmp(infectedtable.("Country/Region"),country), :);
deathtable = removevars(times_conf_country1,[{'GroupCount'},vars1(contains(vars1,"remove_"))]);
countrytable1 = deathtable(strcmp(deathtable.("Country/Region"),country), :);
cols2 = size(countrytable1);
countrytable = countrytable(:,4:end);
countrytable1 = countrytable1(:,4:end);
cols2 = size(countrytable1);
cols1 = size(countrytable);
Countrytotaldead = zeros(1,cols2(2));
Countrytotalinfected = zeros(1,cols1(2));
for i = 1:cols1(2)
    Countrytotalinfected(i) = table2array(countrytable(1,i));
    Countrytotaldead(i) = table2array(countrytable1(1,i));
end
cols2 = size(result);
last_day = datetime(countrytable.Properties.VariableNames(end),'InputFormat','MM/dd/yy');
first_day = datetime(2020,1,22);
time = first_day:last_day;
Countrydeathrate = max(Countrytotaldead)/max(Countrytotalinfected)*100;
daytotal = abs(datenum(last_day) - datenum(first_day));
if prediction_enabled == 1
    beta0 = [max(Countrytotalinfected) 0.5 max(Countrytotalinfected)];
    [x, y] = prepareCurveData([0:1:daytotal], Countrytotalinfected);
    myfun = 'y~A/(1+C*exp(-B*x))';
    tbl = table(x,y);
    model = fitnlm(tbl,myfun,beta0)
    newtime = [0:1:daytotal+dp];
    newdatetime = first_day:last_day+days(dp);
    fitinfected1 = feval(model,newtime);
    projected = fitinfected1(1,[numel(newdatetime)-(dp-1)]:numel(newdatetime));
    projectedeaths = max(fitinfected1)*Countrydeathrate/100;
    plot(newdatetime,fitinfected1,'r','LineWidth',2)
    hold on
    plot(time,Countrytotalinfected,'b*','MarkerSize',7)
    hold on
    titlestr = sprintf('Predicted Coronavirus Cases in %s on %s',country,datetime(last_day+days(dp),'Format','yyyy-MM-dd'));
    title(titlestr)
    set(gca,'FontSize',11,'Fontweight','Bold')
    legend('Predicted Cases','Data from John Hopkins')
    xlabel('Date')
    ylabel('Projected - Confirmed Cases')
    str1 = sprintf('Total Projected: %0.0f | Total Projected Dead: %0.0f | R^2 = %0.3f',round(max(fitinfected1)),abs(round(projectedeaths)),model.Rsquared.Adjusted);
    T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str1);
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
else
    plot(time,Countrytotalinfected,'b*','MarkerSize',7)
    hold on
    titlestr = sprintf('Coronavirus Cases in %s',string(country));
    title(titlestr)
    set(gca,'FontSize',11,'Fontweight','Bold')
    legend('Data from John Hopkins')
    xlabel('Date')
    ylabel('Confirmed Cases')
    str2 = sprintf('Total Cases: %0.0f | Total Dead: %0.0f',round(max(Countrytotalinfected)),round(max(Countrytotaldead)));
    T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str2);
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
end
fprintf('--------- Country Data ----------------- \n')
caseperday = diff(Countrytotalinfected)./diff(day(time));
firstday = datetime(2020,3,10);
timematrix = firstday:last_day;
T = table(caseperday(1,48:numel(Countrytotalinfected)-1)',timematrix');
T.Properties.VariableNames = {'New Country Cases','Date'};
T
if prediction_enabled == 1
    T = table(round(projected)',newdatetime(1,[numel(newdatetime)-(dp-1)]:numel(newdatetime))');
    T.Properties.VariableNames = {'Projected Country Cases','Projected Date'};
    T
end
fprintf('As of: %s : ----------------------------------\n',last_day)
fprintf('Infected: %0.0f, Dead: %0.0f, Death Rate: %0.4f \n',max(Countrytotalinfected),max(Countrytotaldead),Countrydeathrate)
