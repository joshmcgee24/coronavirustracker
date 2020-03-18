%Coronavirus Tracker - States Within United States - Joshua McGee
%Created to track the spread of Coronavirus (COVID-19) in States within the
%United States
%Data is stored online and is provided via JHU CSSE from various sources including:
%"the World Health Organization (WHO), DXY.cn. Pneumonia. 2020, BNO News,
%National Health Commission of the People痴 Republic of China (NHC),
%China CDC (CCDC), Hong Kong Department of Health, Macau Government, Taiwan CDC, US CDC,
%Government of Canada, Australia Government Department of Health,
%European Centre for Disease Prevention and Control (ECDC) and Ministry of
%Health Singapore (MOH)"
%data set is updated every day and an additional column is added for the
%previous days data

%Important Settings:
state = 'Massachusetts'; %state to display data for
dp = 1;%number of days to predict
prediction_enabled = 1; %set to 1 for logistic model curve, 0 to turn off

result=webread('https://proxy.hxlstandard.org/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_19-covid-Confirmed.csv&filename=time_series_2019-ncov-Confirmed.csv');
deathresult = webread('https://proxy.hxlstandard.org/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_19-covid-Deaths.csv&filename=time_series_2019-ncov-Deaths.csv');
data = table2array(result);
empties = cellfun('isempty',data);
data1 = table2array(deathresult);
empties1 = cellfun('isempty',data1);
data(empties) = {NaN};
countries = cellstr(data(:,2));
data1(empties1) = {NaN};
countries1 = cellstr(data1(:,2));
% US DATA
USempties = cellfun('isempty',strfind(countries,'US'));
USdata1 = data(~USempties,:);
USempties1 = cellfun('isempty',strfind(countries1,'US'));
USdata2 = data1(~USempties1,:);
first_day = datetime(2020,1,22);
cols = size(USdata1);
USinfecteddata = str2double(USdata1(:,5:cols(2)));
USdeathdata = str2double(USdata2(:,5:cols(2)));
cols1 = size(USinfecteddata);
UStotalinfected = zeros(1,cols1(2));
UStotaldead = zeros(1,cols1(2));
Statetotalinfected = zeros(1,cols1(2));
Statetotaldead = zeros(1,cols1(2));
for i = 1:cols1(2)
    UStotalinfected(i) = sum(USinfecteddata(:,i));
    Statetotalinfected(i) = sum(USinfecteddata(find(strcmp(USdata2,state)),i));
    UStotaldead(i) = sum(USdeathdata(:,i));
    Statetotaldead(i) = sum(USdeathdata(find(strcmp(USdata2,state)),i));
end
cols2 = size(result);
last_day = datetime(result{1,cols2(2)},'InputFormat','MM/dd/yy');
time = first_day:last_day;
Statedeathrate = max(Statetotaldead)/max(Statetotalinfected)*100;
daytotal = abs(datenum(last_day) - datenum(first_day));
if prediction_enabled == 1
    [x, y] = prepareCurveData([0:1:daytotal], Statetotalinfected);
    model = fittype('1/(A+B*exp(-C*x))','independent','x','dependent','y');
    ftype = fittype(model);
    fopt = fitoptions(ftype);
    fopt.StartPoint = [1 1 1];
    [fitresult, rsquare] = fit(x, y, ftype, fopt);
    newtime = [0:1:daytotal+dp];
    newdatetime = first_day:last_day+days(dp);
    fitinfected1 = fitresult(newtime);
    projected = fitinfected1([numel(newdatetime)-(dp-1)]:numel(newdatetime),1);
    projectedeaths = max(fitinfected1)*Statedeathrate/100;
    plot(newdatetime,fitinfected1,'r','LineWidth',2)
    hold on
    plot(time,Statetotalinfected,'b*','MarkerSize',7)
    hold on
    titlestr = sprintf('Predicted Coronavirus Cases in %s on %s',state,datetime(last_day+days(dp),'Format','yyyy-MM-dd'));
    title(titlestr)
    set(gca,'FontSize',11,'Fontweight','Bold')
    legend('Predicted Cases','Data from John Hopkins')
    xlabel('Date')
    ylabel('Projected - Confirmed Cases')
    str1 = sprintf('Total Projected: %0.0f | Total Projected Dead: %0.0f | R^2 = %0.3f',round(max(fitinfected1)),abs(round(projectedeaths)),rsquare.rsquare);
    T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str1);
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
else
    plot(time,Statetotalinfected,'b*','MarkerSize',7)
    hold on
    titlestr = sprintf('Coronavirus Cases in %s',state);
    title(titlestr)
    set(gca,'FontSize',11,'Fontweight','Bold')
    legend('Data from John Hopkins')
    xlabel('Date')
    ylabel('Confirmed Cases')
    str2 = sprintf('Total Cases: %0.0f | Total Dead: %0.0f',round(max(Statetotalinfected)),round(max(Statetotaldead)));
    T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str2);
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
end
fprintf('--------- State Data ----------------- \n')
caseperday = diff(Statetotalinfected)./diff(day(time));
firstday = datetime(2020,3,10);
timematrix = firstday:last_day;
T = table(caseperday(1,48:numel(Statetotalinfected)-1)',timematrix');
T.Properties.VariableNames = {'New State Cases','Date'};
T
if prediction_enabled == 1
    T = table(round(projected),newdatetime(1,[numel(newdatetime)-(dp-1)]:numel(newdatetime))');
    T.Properties.VariableNames = {'Projected State Cases','Projected Date'};
    T
end
fprintf('As of: %s : ----------------------------------\n',last_day)
fprintf('Infected: %0.0f, Dead: %0.0f, Death Rate: %0.4f \n',max(Statetotalinfected),max(Statetotaldead),Statedeathrate)
