clear

% [SVSPP, COMNAME, Species]=textread('C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\Raw_input_SP_FA\Fall_Thorny\SurvDatSpec_Fall.csv',...
%     '%d %s %s' , 'delimiter', ',');

[SVSPP, COMNAME, Species]=textread('C:\Users\joseph.caracappa\Documents\Website Visualizations\SurvDatSpec_Fall.csv',...
    '%d %s %s' , 'delimiter', ',');

SpeciesNum = length(SVSPP);

for ss = 1:SpeciesNum
    clear cmax;
    for n=1968:2014
        clf
        Yr=n;
        str=int2str(n)
        strc={Species{ss}, '-Fall', str}
        PlotMultipleYears_loopy;
        text(-73.5,37,strc,'FontSize',16)
%         outdir = ['C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\Output_SP_FA\Fall_Thorny\',Species{ss}, '-Fall\'];
        outdir = ['C:\Users\joseph.caracappa\Documents\Website Visualizations\',Species{ss}, '-Fall\'];
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end
        Name=[outdir, Species{ss}, ' fall_',str]
        print('-dtiff','-r450',Name)
        drawnow;
    end
end