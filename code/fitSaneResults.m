%setupDBQuery;
pickPlot = 6;
[R2out pLIC scanType] = displayResults(out);
figName = 'Sane Fit Results';
if isempty(findobj('type','figure','name',figName))
    hf = figure('name',figName);
    myP = [20 20 500 300];
else
    hf =  findobj('type','figure','name',figName);
    myP = get(hf,'Position');
    clf(hf);
end


%tInd = find( R2out(:,3)> 0 & R2out(:,3) < 140);%700 ) ; %& pLIC'>0);
%tInd = find( R2out(:,4));
%x = R2out(tInd,1);
%x = pLIC(tInd)';
%x = R2out(tInd,3);
%y = R2out(tInd,6);
%y = R2out(tInd,pickPlot);
%scanTypeH = scanType(tInd);
%%
x = [48.0017
  128.2126
   50.8951
   32.8622
  130.2838
  112.7218
   32.1779
   99.2133
   47.5601
   38.0183
   82.5116
   60.2284
  137.4396
   64.2290];

y = [111.4351
  255.0322
  100.5220
   74.2868
  131.8755
  182.4804
   47.7091
  142.6206
  111.0184
   41.3888
  159.1141
  146.1175
  176.5565
   84.6687];

p = polyfit(x,y,1)
%p(1) is the slope and p(2) is the intercept of the linear predictor. You can also obtain regression coefficients using the Basic Fitting UI.

%Call polyval to use p to predict y, calling the result yfit:

yfit = polyval(p,x);

%Using polyval saves you from typing the fit equation yourself, which in this case looks like:

%yfit =  p(1) * x + p(2);

%Compute the residual values as a vector of signed numbers:

yresid = y - yfit;

%Square the residuals and total them to obtain the residual sum of squares:

SSresid = sum(yresid.^2);

%Compute the total sum of squares of y by multiplying the variance of y by the number of observations minus 1:

SStotal = (length(y)-1) * var(y);

%Compute R2 using the formula given in the introduction of this topic:

rsq = 1 - SSresid/SStotal



%plot(x(scanTypeH>1),y(scanTypeH>1),'r*');

ly = [p(1) * 0 + p(2), p(1) * 140 + p(2)];
lx = [0 140];


plot(lx, ly, 'LineWidth',3, 'Color', [.5 .5 .5 ]);
hold on;
plot(x,y,'o', 'MarkerSize',5, 'MarkerFaceColor',[0 0 0], 'MarkerEdgeColor',[0 0 0]);
hold on;

mt = sprintf('Line of best fit\ny = %0.3f x + %0.3f\nR^2 = %0.3f', ...
    p(1), p(2), rsq)

h = text(10,(max(ylim)-40), mt);


set(gcf,'PaperUnits','points')
set(gcf,'PaperSize',[510 310])
set(gcf,'PaperPosition',[3 3 500 300])

get(h,'Position')

h = xlabel(' ');
set(h,'FontSize',15,'FontWeight','bold');
%h = ylabel('R2 Estimate Error[%]');
h = ylabel(' ');
set(h,'FontSize',15,'FontWeight','bold');
set(gca,'FontSize',12');
set(hf,'Position',[myP(1:2) 500 300]);
%x legend label


xlabel('Standard spin echo unconstrained R2 Fit[Hz]');
ylabel('Fast spin echo R2 [Hz]');
saveas(h,'sane_fit.pdf','pdf')