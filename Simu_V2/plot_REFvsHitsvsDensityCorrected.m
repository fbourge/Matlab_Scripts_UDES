function plot_REFvsHitsvsDensityCorrected( LARCHI_density, hits, PAD , corrected2, size_voxel , placette)

plotName = strcat('PLOT ', num2str(100*size_voxel),' cm');
nameOutput = strcat(placette,'/Finalplot_', placette,'_',num2str(100*size_voxel),'cm');


if(size(LARCHI_density,2)==2)
LARCHI_density=LARCHI_density(:,1)+LARCHI_density(:,2);
end


scaleZ = (size_voxel:size_voxel:size(hits,1)*size_voxel)'; % nouvelle échelle en mètres


%%Fitting Weibull
Weibull_modelfun = @(b,x)b(3)*((b(1)/b(2)).*((x/b(2)).^(b(1)-1)).*exp(-(x/b(2)).^b(1)));
b0_hits = [1;1;1];
b0_PAD = [3;4;4];
%b0_PAD = [1;1;1];

% Fitting of Weibull to Hits profile
mdl_hits = NonLinearModel.fit(scaleZ,hits,Weibull_modelfun,b0_hits);
hits_fitted=mdl_hits.Fitted;
[C,I] = max(hits_fitted);
pt_max_hits = [C,I];

% Fitting of Weibull LARCHI profile
mdl_larchi = NonLinearModel.fit(scaleZ,LARCHI_density,Weibull_modelfun,b0_PAD);
LARCHI_density_fitted = mdl_larchi.Fitted;
[C,I] = max(LARCHI_density_fitted);
pt_max_larchi = [C,I];

% FItting of Weibeull to PAD profile
mdl_pads = NonLinearModel.fit(scaleZ,PAD,Weibull_modelfun,b0_PAD);
PAD_fitted = mdl_pads.Fitted;
[C,I] = max(PAD_fitted);
pt_max_pads = [C,I];
% Fitting of PAD to LARCHI
mdl_Z = LinearModel.fit(PAD, LARCHI_density);



%% Trace
hFig = figure('Name',plotName,'NumberTitle','off', 'Position', [50 50 1800 700]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subplot #1
 subplot(1,3,1);
l10 = line(hits,scaleZ,'Color','r','LineWidth',2);
ax1 = get(gca); % current axes
%l11 = line(hits_fitted,scaleZ,'Color','r','LineStyle','--','LineWidth',1);


xlabel('\% returns $-$ (averaged per Z layer)','Interpreter','Latex','FontSize',16);
ylabel(' Height (m) $-$ Z ','Interpreter','Latex','FontSize',16);

set(gca,'XColor','r');
set(gca,'YColor','k');
set(gca,'YGrid','on');
%set(gca,'LineWidth','2');

ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

l20 = line(LARCHI_density,scaleZ,'Parent',ax2,'Color','b','LineWidth',2);
%l21 = line(LARCHI_density_fitted,scaleZ,'Parent',ax2,'Color','b','LineStyle','--','LineWidth',1);
l22 = line(PAD,scaleZ,'Parent',ax2,'Color','k','LineStyle','-','LineWidth',2);
%l23 = line(PAD_fitted,scaleZ,'Parent',ax2,'Color','k','LineStyle','--','LineWidth',2);

legend([l20 l22 l10],'L-ARCHITECT','LVOX PAD / 3', 'Raw lidar-t returns');
xlabel('PAD ($m^{2}/m^{3}$) $-$ (averaged per Z layer)','Interpreter','Latex','FontSize',16);

set(gca,'XColor','b');
set(gca,'YColor','k');

%title(plotName,'Interpreter','Latex','FontSize',16);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBPLOT n2
ax = subplot(1,3,2);


ax1 = get(gca); % current axes
l11 = line(hits_fitted,scaleZ,'Color','r','LineStyle','--','LineWidth',1);

xlabel('\% returns $-$ (averaged per Z layer)','Interpreter','Latex','FontSize',16);
ylabel(' Height (m) $-$ Z ','Interpreter','Latex','FontSize',16);

set(gca,'XColor','r');
set(gca,'YColor','k');
set(gca,'YGrid','on');
%set(gca,'LineWidth','2');

ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

l21 = line(LARCHI_density_fitted,scaleZ,'Parent',ax2,'Color','b','LineStyle','--','LineWidth',1);
l23 = line(PAD_fitted,scaleZ,'Parent',ax2,'Color','k','LineStyle','--','LineWidth',2);

legend([l21 l23 l11],'L-ARCHITECT (weibull fit)', 'LVOX PAD (weibull fit)', 'Raw lidar-t returns (weibull fit)');
xlabel('PAD ($m^{2}/m^{3}$) $-$ (averaged per Z layer)','Interpreter','Latex','FontSize',16);

set(gca,'XColor','b');
set(gca,'YColor','k');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBPLOT #3
ax = subplot(1,3,3);
font_size = 14;
fix1 = 1;
% /////// LARCHI ///////
weibull2 = sprintf('Weibull param : k = %0.3f, lambda = %0.3f, C = %0.3f', ...
                        mdl_larchi.Coefficients.Estimate(1),mdl_larchi.Coefficients.Estimate(2),mdl_larchi.Coefficients.Estimate(3)); 
r22 = sprintf('$R^{2}$:  %0.3f // RMSE: %0.3f // Echantillons : %i', mdl_larchi.Rsquared.Ordinary, mdl_larchi.RMSE, mdl_larchi.NumObservations); 
pt2 = strcat('Max LARCHI value = ', num2str(pt_max_larchi(1)),'; $\bf {Z max =}$',num2str(pt_max_larchi(2)*size_voxel),' m') ;


text(0,fix1,'LARCHI Weibull Fit','Interpreter','Latex','FontSize',font_size);
text(0,fix1-0.05,weibull2,'Interpreter','Latex','FontSize',font_size);
text(0,fix1-0.10,r22,'Interpreter','Latex','FontSize',font_size);
text(0,fix1-0.15,pt2,'Interpreter','Latex','FontSize',font_size,'FontWeight', 'bold');

% /////// PAD ///////
weibull2 = sprintf('Weibull param : k = %0.3f, lambda = %0.3f, C = %0.3f', ...
                        mdl_pads.Coefficients.Estimate(1),mdl_pads.Coefficients.Estimate(2),mdl_pads.Coefficients.Estimate(3)); 
r22 = sprintf('$R^{2}$:  %0.3f  //  RMSE: %0.3f  // Echantillons : %i ', mdl_pads.Rsquared.Ordinary, mdl_pads.RMSE, mdl_pads.NumObservations); 
%pt2 = sprintf('Max PAD value =  %0.3f; Z max = %0.1f m ;',pt_max_pads(1),pt_max_pads(2)*size_voxel);
pt2 = strcat('Max PAD value = ', num2str(pt_max_pads(1)),'; $\bf {Z max =}$',num2str(pt_max_pads(2)*size_voxel),' m') ;


fix2 = fix1-0.25;
text(0,fix2,'PAD Weibull Fit','Interpreter','Latex','FontSize',font_size);
text(0,fix2-0.05,weibull2,'Interpreter','Latex','FontSize',font_size);
text(0,fix2-0.10,r22,'Interpreter','Latex','FontSize',font_size);
text(0,fix2-0.15,pt2,'Interpreter','Latex','FontSize',font_size);

% /////// HITS ///////
weibull1 = sprintf('Weibull param : k = %0.3f, lambda = %0.3f, C = %0.3f', ...
                        mdl_hits.Coefficients.Estimate(1),mdl_hits.Coefficients.Estimate(2),mdl_hits.Coefficients.Estimate(3)); 
r21 = sprintf('$R^{2}$:  %0.3f  // RMSE: %0.3f  //  Echantillons : %i', mdl_hits.Rsquared.Ordinary, mdl_hits.RMSE, mdl_hits.NumObservations); 
pt1 = strcat('Max hits = ', num2str(pt_max_hits(1)),'; $\bf {Z max =}$',num2str(pt_max_hits(2)*size_voxel),' m') ;

fix3 = fix2-0.25;
text(0,fix3,'HITS Weibull Fit','Interpreter','Latex','FontSize',font_size);
text(0,fix3-0.05,weibull1,'Interpreter','Latex','FontSize',font_size);
text(0,fix3-0.10,r21,'Interpreter','latex','FontSize',font_size);
text(0,fix3-0.15,pt1,'Interpreter','latex','FontSize',font_size);

% /////// PAD -> LARCHI  ///////
weibull1 = sprintf('Equation : LARCHI(Z) = a.PAD(Z) + b: a = %0.3f, b = %0.3f ', ...
                        mdl_Z.Coefficients.Estimate(2),mdl_Z.Coefficients.Estimate(1)); 
r21 = sprintf('$R^{2}$:  %0.3f  // RMSE: %0.3f  //  Echantillons : %i', mdl_Z.Rsquared.Ordinary, mdl_Z.RMSE, mdl_Z.NumObservations); 
%pt1 = sprintf('Max hits =  %0.3f; Z max = %0.1f m ;',pt_max_hits(1),pt_max_hits(2)*size_voxel);

fix4 = fix3-0.25;
text(0,fix4,'PAD to LARCHI : linear regression fit','Interpreter','Latex','FontSize',font_size,'FontWeight', 'bold');
text(0,fix4-0.05,weibull1,'Interpreter','Latex','FontSize',font_size);
text(0,fix4-0.10,r21,'Interpreter','Latex','FontSize',font_size);
%text(0,fix3-0.15,pt1,'Interpreter','Latex','FontSize',font_size);


text(0,fix4-0.20,strcat('$ Placette : ',placette),'Interpreter','Latex','FontSize',font_size+2,'color','blue');
text(0,fix4-0.25,strcat('$ Resolution : ', num2str(100*size_voxel),' cm'),'FontSize',font_size+2,'color','blue');


set ( ax, 'visible', 'off'); 

% Save
pathfig = strcat(nameOutput,'_2','.fig');
pathpdf = strcat(nameOutput,'_2','.pdf');

saveas(hFig,pathfig);
export_fig('-q101' ,'-a1','-transparent',pathpdf );

end