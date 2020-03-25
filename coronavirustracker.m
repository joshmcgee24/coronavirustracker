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
prediction_enabled = 1; %set to 1 for logistic model curve, 0 to turn off
world_enabled = 1; %set to 1 to enable world statistics, 0 to turn off

%Obtaining and formating data - courtesy of Toshi Takeuchi - https://www.mathworks.com/matlabcentral/profile/authors/951521
result=webread('https://data.humdata.org/hxlproxy/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_covid19_confirmed_global.csv&filename=time_series_covid19_confirmed_global.csv','options','table');
deathresult = webread('https://data.humdata.org/hxlproxy/api/data-preview.csv?url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftime_series_covid19_deaths_global.csv&filename=time_series_covid19_deaths_global.csv','options','table');
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
times_conf_country1.Properties.VariableNames = vars1;
infectedtable = removevars(times_conf_country,[{'GroupCount'},vars(contains(vars,"remove_"))]);
countrytable = infectedtable(strcmp(infectedtable.("Country/Region"),country), :);
deathtable = removevars(times_conf_country1,[{'GroupCount'},vars1(contains(vars1,"remove_"))]);
countrytable1 = deathtable(strcmp(deathtable.("Country/Region"),country), :);
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
infected = Countrytotalinfected;
startidx = zeros(length(infected));
for i = 1:length(infected)
    if i == length(infected)
        break
    end
    if infected(i+1) > 1.5*infected(i) && infected(i) > 10
        startidx(i) = i;
    end
end
startidx = find(startidx~=0, 1, 'first');
warning('off','all')
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
    K = table2array(model.Coefficients(1,1));
    r = table2array(model.Coefficients(2,1));
    A = table2array(model.Coefficients(3,1));
    C0  = fix(K/(A + 1));
    tpeak  = fix(log(A)/r);
    dpeak  = days(tpeak) + first_day;
    dend   = 2*days(tpeak) + first_day;
    dCpeak = fix(r*K/4);
    tau    = fix(4/r);
    newtime = [0:1:daytotal+21];
    newdatetime = first_day:last_day+days(21);
    fitinfected1 = feval(model,newtime);
    projected = fitinfected1(1,[numel(newdatetime)-(21-1)]:numel(newdatetime));
    projectedeaths = max(fitinfected1)*Countrydeathrate/100;
    plot(newdatetime,fitinfected1,'r','LineWidth',2)
    hold on
    plot(time,Countrytotalinfected,'b*','MarkerSize',7)
    hold on
    title(sprintf('COVID-19 Epidemic Simulation for %s',country))
    str1 = sprintf('Total Projected: %0.0f | Total Projected Dead: %0.0f | R^2 = %0.3f \n Date: %s | Toal Cases: %0.0f | Total Deaths: %0.0f',K,Countrydeathrate*K,model.Rsquared.Adjusted,datestr(time(end)),Countrytotalinfected(end),Countrytotaldead(end));
    T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str1);
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
    legend('Predicted Cases','Data from John Hopkins','location','southwest')
    xlabel('Date')
    ylabel('Projected - Confirmed Cases')
else
    plot(time,Countrytotalinfected,'b*','MarkerSize',7)
    hold on
    titlestr = sprintf('Coronavirus Cases in %s',string(country));
    title(titlestr)
    set(gca,'FontSize',11,'Fontweight','Bold')
    legend('Data from John Hopkins','location','southwest')
    xlabel('Date')
    ylabel('Confirmed Cases')
    str2 = sprintf('Total Cases: %0.0f | Total Dead: %0.0f',round(max(Countrytotalinfected)),round(max(Countrytotaldead)));
    T = text(min(get(gca,'xlim')), max(get(gca,'ylim')), str2);
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
end
caseperday = diff(Countrytotalinfected)./diff(day(time));
firstday = datetime(2020,3,10);
timematrix = firstday:last_day;
T = table(caseperday(1,48:numel(Countrytotalinfected)-1)',timematrix');
T.Properties.VariableNames = {(sprintf('New %s Cases',country)),sprintf('Date')};
T
if prediction_enabled == 1
    fprintf('--------- %s Data ----------------- \n',country)
    fprintf(' date: %10s  day: %3d\n',datestr(time(end)),numel(time));
    fprintf(' start date: %s \n',time(startidx));
    fprintf(' number of cases: %d\n',max(Countrytotalinfected));
    fprintf(' number of deaths: %d\n',max(Countrytotaldead));
    fprintf(' estimated epidemic size (cases): %d\n',K);
    fprintf(' estimated epidemic rate (1/day): %d\n',r);
    fprintf(' estimated initial state (cases): %d\n',C0);
    fprintf(' estimated initial doubling time (day): %3.1f\n',round(log(2)/r,1));
    fprintf(' estimated duration of fast growth phase (day): %d\n',tau);
    fprintf(' estimated peak date: %s  day: %d \n',dpeak,tpeak);
    fprintf(' estimated peak rate (cases/day): %d\n',dCpeak);
    fprintf(' estimated end of transition phase: %s  day: %d\n',dend,2*tpeak);
    T = table(round(projected)',round(projected'.*(Countrydeathrate/100)),newdatetime(1,[numel(newdatetime)-(21-1)]:numel(newdatetime))');
    T.Properties.VariableNames = {(sprintf('Projected %s Cases',country)),(sprintf('Projected %s Deaths',country)),sprintf('Projected Date')};
    T
end
fprintf('As of: %s : ----------------------------------\n',last_day)
fprintf('Infected: %0.0f, Dead: %0.0f, Death Rate: %0.4f \n',max(Countrytotalinfected),max(Countrytotaldead),Countrydeathrate)

if world_enabled == 1
    %plotting comparison of all countries
    countries = groupsummary(times_conf_country,"Country/Region", "max");
    vars = countries.Properties.VariableNames;
    countries = removevars(countries,[{'GroupCount'},vars(contains(vars,"remove"))]);
    countries1 = countries(:,5:end);
    cols1 = size(countries1);
    Countrytotalinfected = zeros(cols1(1),cols1(2));
    countries2 = groupsummary(times_conf_country1,"Country/Region", "max");
    vars = countries2.Properties.VariableNames;
    countries2 = removevars(countries2,[{'GroupCount'},vars(contains(vars,"remove"))]);
    countries3 = countries2(:,5:end);
    cols2 = size(countries3);
    Countrytotaldead = zeros(cols2(1),cols2(2));
    for i = 1:cols1(1)
        for j = 1:cols1(2)
            Countrytotalinfected(i,j) = table2array(countries1(i,j));
        end
    end
    for i = 1:cols2(1)
        for j = 1:cols2(2)
            Countrytotaldead(i,j) = table2array(countries3(i,j));
        end
    end
    num_countries = numel(countries(:,1));
    T = table(countries(:,1),Countrytotalinfected(1:num_countries,end));
    T.Properties.VariableNames = {'Country','Cases'};
    sortrows(T,[2],{'descend'})
    [temp,originalpos] = sort(max(Countrytotalinfected')', 'descend' );
    
    figure
    %plot five countries with most cases
    for i = 2:6
        plot(time,Countrytotalinfected(originalpos(i),:),'LineWidth',4);
        hold on
        legendInfo{i-1} = sprintf('%s',countries{originalpos(i), 1});
    end
    t = floor(now);
    d = datetime(t,'ConvertFrom','datenum');
    xlim([datetime(2020,2,15) d])
    title('5 Countries with Most COVID-19 Cases')
    set(gca,'FontSize',9,'Fontweight','Bold')
    legend(legendInfo,'location','northwest')
    
    infected = zeros(10,1);
    for i = 1:10
        infected(i) = Countrytotalinfected(originalpos(i),end);
        legendInfo2{i} = sprintf('%s',countries{originalpos(i), 1});
    end
    figure
    P = pie(infected,legendInfo2);
    hold on
    pText = findobj(P,'Type','text');
    percentValues = infected./(sum(infected))*100;
    percentValues = mat2cell(percentValues',1,10);
    txt = legendInfo2;
    str1 = sprintf('Proportion of Cases | Total World Cases: %0.0f | Total World Dead: %0.0f',sum(sum(Countrytotalinfected(:,end))),sum(sum(Countrytotaldead(:,end))));
    title(str1)
    hold off
    
    T1 = table(countries(:,1),max(Countrytotaldead')');
    T1.Properties.VariableNames = {'Country','Dead'};
    sortrows(T1,[2],{'descend'})
    [temp1,originalpos1] = sort(max(Countrytotaldead')', 'descend' );
    
    figure
    %plot five countries with most deaths
    for i = 2:6
        plot(time,Countrytotaldead(originalpos1(i-1),:),'LineWidth',4);
        hold on
        legendInfo1{i-1} = sprintf('%s',countries{originalpos1(i-1), 1});
    end
    xlim([datetime(2020,2,15) d])
    title('5 Countries with Most COVID-19 Deaths')
    set(gca,'FontSize',9,'Fontweight','Bold')
    legend(legendInfo1,'location','northwest')
    hold off
    
    fprintf('\n ---- World Statistics for: %s \n',last_day)
    fprintf('Total Cases: %d | Total Deaths: %d \n',sum(sum(Countrytotalinfected(:,end))),sum(sum(Countrytotaldead(:,end))))
else
end
