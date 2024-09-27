function [floor_field]=FloorField(N1,N2,doors)

    %Statikus potenciálmezõt kiszámoló függvény
    
    %Bemenetek:
    %0 db bemenet esetén egy elõre elkészített osztályteremmel számol
    %3 db bemenet esetén:
        %N1: terem hossza
        %N2: terem szélessége
        %ajtók elhelyezkedése a következõképpen: [elsõ ajtó elsõ
        %koordinátája, elsõ ajtó második koordinátája; második ajtó elsõ
        %koordinátája, második ajtó második koordinátája;...]
        %[oszlop,sor]---EZT MAJD JAVÍT
        
    %Kimenet:
        %floor_field: Statikus potenciálmezõ (MÁTRIX) (minden cellához egy érték.)
        
%N1=14;
%N2=18;
%doors=[7,1;8,1];
%doors=[4,1;5,1;10,1;11,1];
lambda=3/2;                                            %diagonális mozgás "távolsága"
%lambda=500;                                           %diagonális mozgás nem megengedett

%1:ajtó
%200:üres
%500:obstacle

%osztályterem
if (nargin==0)
    %
    osztalyterem=load('oterem.mat');%MIeRT STRUCT TALaN KeSoBB MIATT, CHECK
    floor_field=struct2array(osztalyterem.osztalyterem);
    N1=size(floor_field,1)-2;%-2 a fal  miatt
    N2=size(floor_field,2)-2;
    %ajtó helyének lehetséges megváltoztatása
    %{
    floor_field(floor_field==1)=500;
    floor_field([8,9,8,9],[1,1,18,18])=1;
    %}
    [doors_x,doors_y]=find(floor_field==1);
    doors=cat(2,doors_x,doors_y);
    
%üres terem (fallal dim n1+2 x n2+2)
elseif (nargin==3)
    floor_field=200*ones(N1,N2);                       %floor field inicializálása
    floor_field=padarray(floor_field,[1,1],500,'both');%falak
 
    for kk=1:size(doors,1)                              %ajtók
        door=doors(kk,:);
        floor_field(sub2ind(size(floor_field),door(1),door(2)))=1;       
    end
    
elseif (nargin~=3 && nargin ~=0)
    error('Zero or 3 input arguments is required');
end

%innentõl a grid minden cellájának floor field értéket ad a dokumentációban
%leírt algoritmus szerint

[szomszcell]=doorszomsz(doors,N1,N2);                  %ajtó szomszédai

nowszomsz=[];
while sum(ismember(floor_field(:),200))~=0             %ameddig nincs minden cellának értéke (200-ra volt inicializálva)
    for i=1:size(szomszcell,1)
        
       szomsz=szomszcell(i,:);
       %egy cella összes szomszédának megnézése és frissítése, ha ez a
       %szomszéd tud adni neki kisebb értéket, akkor frissítjük a kisebb
       %értékre és megkeressük az õ szomszédait is majd (nowszomsz)
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)-1,szomsz(2))+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)-1,szomsz(2))+1; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)];  end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)+1,szomsz(2))+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)+1,szomsz(2))+1; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1),szomsz(2)+1)+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1),szomsz(2)+1)+1; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1),szomsz(2)-1)+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1),szomsz(2)-1)+1; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)]; end

       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)+1,szomsz(2)-1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)+1,szomsz(2)-1)+lambda; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)-1,szomsz(2)-1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)-1,szomsz(2)-1)+lambda; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)-1,szomsz(2)+1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)-1,szomsz(2)+1)+lambda; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)-1,szomsz(2)-1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)-1,szomsz(2)-1)+lambda; nowszomsz=[nowszomsz;szomsz(1),szomsz(2)]; end
       
    end
    
    szomszcell=SzomszedberakEsFalkiszed(floor_field,nowszomsz);%            
    
end

%PlotFloorField(floor_field);                      %floor_field plotolása

%Manhattan metrika-féle floor field, amikor diagonális mozgás nem
%megengedett
%{
for i=2:size(floor_field,1)-1
    for j=2:size(floor_field,2)-1
        pathsize=[];
        for k=1:size(doors,2)
            pathsize_new=abs(doors(k,1)-i)+abs(doors(k,2)-j);
            pathsize=[pathsize,pathsize_new];
        end
        floor_field(i,j)=min(pathsize)+1;
    end
end
%}

function PlotFloorField(floor_field)
   
    figure('Name','Floor Field values');
    imagesc((floor_field));
    set(gca,'YDir','normal');                   %y tengely megfordítása (imagesc-nél fordítva van a default) 
    colormap(flipud(hot));                      %fehér a legkisebb érték, egyre nagyobb érték egyre pirosabb
    caxis([0,max(max(floor_field(floor_field~=500)))+3]);%ne 500-ig menjen a colormap, mert a floor field értékek kb 0-22 között vannak
    
    %szöveg ráírása a figure-ra:
    %ehhez a következõ kódot írtam át:
    %(https://www.mathworks.com/matlabcentral/answers/91384-how-can-i-display-the-numerical-values-of-each-cell-as-text-in-my-pcolor-plot)
    %
    pos=get(gca,'position');
    [rows,cols]=size(floor_field);
    width=pos(3)/(cols);
    height =pos(4)/(rows);
    %
    %create textbox annotations
    for hh=1:cols
          for hhh=rows:-1:1    
              
           annotation('textbox',[pos(1)+width*(hh-1),pos(2)+height*(hhh-1),width,height], ...
           'string',num2str(floor_field(hhh,hh)),'LineStyle','none','HorizontalAlignment','center',...
           'VerticalAlignment','middle');
       
          end
    end
    
    cb=colorbar;
    cb.Position=[0.9189 0.1900 0.0236 0.6500]; %colorbar helyének megváltoztatása
    
end

function [newszomsz]=SzomszedberakEsFalkiszed(floor_field,nowszomsz)
    nowszomsz=unique(nowszomsz,'rows');
    newszomsz=[];
    
    for ii=1:size(nowszomsz,1)
        
            newszomsz=[newszomsz;
                nowszomsz(ii,1)+1, nowszomsz(ii,2);
                nowszomsz(ii,1)-1, nowszomsz(ii,2);
                nowszomsz(ii,1),   nowszomsz(ii,2)+1;
                nowszomsz(ii,1),   nowszomsz(ii,2)-1;
                nowszomsz(ii,1)+1, nowszomsz(ii,2)+1;
                nowszomsz(ii,1)-1, nowszomsz(ii,2)-1;
                nowszomsz(ii,1)+1, nowszomsz(ii,2)-1;
                nowszomsz(ii,1)-1, nowszomsz(ii,2)+1];
    end
    
    newszomsz=unique(newszomsz,'rows');
    %a fal indexeinek kiszedése
    linear_newszomsz = sub2ind(size(floor_field), newszomsz(:,1), newszomsz(:,2));
    AA=(floor_field(linear_newszomsz)~=500 & floor_field(linear_newszomsz)~=1);
    linear_newszomsz=linear_newszomsz(AA);
    [x,y]=ind2sub(size(floor_field),linear_newszomsz);
    newszomsz=cat(2,x,y);
end

%az ajtók szomszédainak megkeresése
%sajnos a sarkokon ez megbukik
function [szomszcell]=doorszomsz(door,N1,N2)
    szomszcell=[];

    for ii=1:size(door,1)
        if door(ii,2)==1
            szomszcell=[szomszcell;door(ii,1),door(ii,2)+1;door(ii,1)+1,door(ii,2)+1;door(ii,1)-1,door(ii,2)+1]; end
        if door(ii,2)==N2
            szomszcell=[szomszcell;door(ii,1),door(ii,2)-1;door(ii,1)+1,door(ii,2)-1;door(ii,1)-1,door(ii,2)+1]; end
        if door(ii,1)==1
            szomszcell=[szomszcell;door(ii,1)+1,door(ii,2);door(ii,1)+1,door(ii,2)+1;door(ii,1)+1,door(ii,2)-1]; end
        if door(ii,1)==N1
            szomszcell=[szomszcell;door(ii,1)-1,door(ii,2);door(ii,1)-1,door(ii,2)+1;door(ii,1)-1,door(ii,2)+1]; end
        
    end
    
    szomszcell=unique(szomszcell,'rows');       %duplikátumok kiszedése%
end

end
