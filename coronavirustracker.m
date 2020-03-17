%Coronavirus Tracker - Massachusetts + United States - Joshua McGee

%Created to track the spread of Coronavirus (COVID-19) in the United States
%Data is stored online and is provided via JHU CSSE from various sources including:
%"the World Health Organization (WHO), DXY.cn. Pneumonia. 2020, BNO News, 
%National Health Commission of the People’s Republic of China (NHC), 
%China CDC (CCDC), Hong Kong Department of Health, Macau Government, Taiwan CDC, US CDC, 
%Government of Canada, Australia Government Department of Health, 
%European Centre for Disease Prevention and Control (ECDC) and Ministry of
%Health Singapore (MOH)"
%data set is updated every day and an additional column is added for the
%previous days data

%In order to update the amount of time that the code will predict cases
%for,change the variable "dp"

dp = 3; %number of days to predict for

%receive confirmed case data and death data
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
countries(empties) = {NaN};
USdata1 = data(~USempties,:);
USempties1 = cellfun('isempty',strfind(countries1,'US'));
countries1(empties1) = {NaN};
USdata2 = data1(~USempties1,:);
first_day = datetime(2020,1,22);
cols = size(USdata1);
USinfecteddata = cellfun(@str2num,USdata1(:,5:cols(2)));
USdeathdata = cellfun(@str2num,USdata2(:,5:cols(2)));
cols1 = size(USinfecteddata);
UStotalinfected = zeros(1,cols1(2));
UStotaldead = zeros(1,cols1(2));

for i = 1:cols1(2)
    UStotalinfected(i) = sum(USinfecteddata(:,i));
    UStotaldead(i) = sum(USdeathdata(:,i));
end
cols2 = size(result);
last_day = datetime(result{1,cols2(2)},'InputFormat','MM/dd/yy');
time = first_day:last_day;

figure(1)
plot(time,UStotalinfected,'bo','LineWidth',2,'MarkerSize',3)
title('Confirmed Coronavirus Cases in the US')
set(gca,'FontSize',11,'Fontweight','Bold')
legend('Data from Johns Hopkins')
str1 = sprintf('Total Cases: %0.0f Total Dead: %0.0f',max(UStotalinfected),max(UStotaldead));
T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str1); 
set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
hold off
xlabel('Date')
ylabel('Confirmed Cases')

figure(2)
USdeathrate = UStotaldead/UStotalinfected*100;
daytotal = abs(datenum(last_day) - datenum(first_day));

[x, y] = prepareCurveData([0:1:daytotal], UStotalinfected);
model = fittype('1/(A+B*exp(-C*x))','independent','x','dependent','y');
ftype = fittype(model);
fopt = fitoptions(ftype);
fopt.StartPoint = [1 1 1];
[fitresult, rsquare] = fit(x, y, ftype, fopt);

Coeff = polyfit([0:1:daytotal],UStotalinfected, 5);
newtime = [0:1:daytotal+dp];
newdatetime = first_day:last_day+days(dp);
fitinfected1 = fitresult(newtime);
projected = fitinfected1([numel(newdatetime)-(dp-1)]:numel(newdatetime),1);
projectedeaths = max(fitinfected1)*USdeathrate/100;
plot(newdatetime,fitinfected1,'r','LineWidth',2)
hold on 
plot(time,UStotalinfected,'bo','LineWidth',2,'MarkerSize',3)
titlestr = sprintf('Predicted Coronavirus Cases in US on %s',datetime(last_day+days(dp),'Format','yyyy-MM-dd'));
title(titlestr)
set(gca,'FontSize',11,'Fontweight','Bold')
legend('Predicted Cases','Data from John Hopkins')
xlabel('Date')
ylabel('Projected - Confirmed Cases')
str1 = sprintf('Total Projected: %0.0f | Total Projected Dead: %0.0f | R^2 = %0.3f',round(max(fitinfected1)),round(projectedeaths),rsquare.rsquare);
T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str1); 
set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
hold off

fprintf('--------- United States Data ----------------- \n')
caseperday = diff(UStotalinfected)./diff(day(time));
firstday = datetime(2020,1,22);
timematrix = firstday:last_day;
newdatetime = first_day:last_day+days(dp);
cols = size(timematrix);
T = table(caseperday',timematrix(:,2:cols(2))');
T.Properties.VariableNames = {'New U.S. Cases','Date'};
T
T = table(round(projected),newdatetime(1,[numel(newdatetime)-(dp-1)]:numel(newdatetime))');
T.Properties.VariableNames = {'Projected US Cases','Projected Date'};
T
fprintf('As of: %s --------------------------------------\n',last_day)
fprintf('Infected: %0.0f, Dead: %0.0f, Death Rate: %0.4f \n',max(UStotalinfected),max(UStotaldead),USdeathrate)
