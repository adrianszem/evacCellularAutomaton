function [floor_field]=FloorField(N1,N2,doors)

    %Statikus potenci�lmez�t kisz�mol� f�ggv�ny
    
    %Bemenetek:
    %0 db bemenet eset�n egy el�re elk�sz�tett oszt�lyteremmel sz�mol
    %3 db bemenet eset�n:
        %N1: terem hossza
        %N2: terem sz�less�ge
        %ajt�k elhelyezked�se a k�vetkez�k�ppen: [els� ajt� els�
        %koordin�t�ja, els� ajt� m�sodik koordin�t�ja; m�sodik ajt� els�
        %koordin�t�ja, m�sodik ajt� m�sodik koordin�t�ja;...]
        %[oszlop,sor]---EZT MAJD JAV�T
        
    %Kimenet:
        %floor_field: Statikus potenci�lmez� (M�TRIX) (minden cell�hoz egy �rt�k.)
        
%N1=14;
%N2=18;
%doors=[7,1;8,1];
%doors=[4,1;5,1;10,1;11,1];
lambda=3/2;                                            %diagon�lis mozg�s "t�vols�ga"
%lambda=500;                                           %diagon�lis mozg�s nem megengedett

%1:ajt�
%200:�res
%500:obstacle

%oszt�lyterem
if (nargin==0)
    %
    osztalyterem=load('oterem.mat');%MIeRT STRUCT TALaN KeSoBB MIATT, CHECK
    floor_field=struct2array(osztalyterem.osztalyterem);
    N1=size(floor_field,1)-2;%-2 a fal  miatt
    N2=size(floor_field,2)-2;
    %ajt� hely�nek lehets�ges megv�ltoztat�sa
    %{
    floor_field(floor_field==1)=500;
    floor_field([8,9,8,9],[1,1,18,18])=1;
    %}
    [doors_x,doors_y]=find(floor_field==1);
    doors=cat(2,doors_x,doors_y);
    
%�res terem (fallal dim n1+2 x n2+2)
elseif (nargin==3)
    floor_field=200*ones(N1,N2);                       %floor field inicializ�l�sa
    floor_field=padarray(floor_field,[1,1],500,'both');%falak
 
    floor_field(sub2ind(size(floor_field),doors(:,1),doors(:,2)))=1;   %ajt�k  

elseif (nargin==2)
    floor_field=N1;
    doors=N2;
    N1=size(floor_field,1)-2;
    N2=size(floor_field,2)-2;
    
elseif (nargin~=3 && nargin ~=0 && nargin ~=2)
    error('Zero or 3 input arguments is required');
end

%innent�l a grid minden cell�j�nak floor field �rt�ket ad a dokument�ci�ban
%le�rt algoritmus szerint

[szomsz_cell]=DoorSzomsz(doors,N1,N2);                  %ajt� szomsz�dai

now_szomsz=[];
while sum(ismember(floor_field(:),200))~=0             %ameddig nincs minden cell�nak �rt�ke (200-ra volt inicializ�lva)
    for i=1:size(szomsz_cell,1)
        
       szomsz=szomsz_cell(i,:);
       %egy cella �sszes szomsz�d�nak megn�z�se �s friss�t�se, ha ez a
       %szomsz�d tud adni neki kisebb �rt�ket, akkor friss�tj�k a kisebb
       %�rt�kre �s megkeress�k az � szomsz�dait is majd (nowszomsz)
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)-1,szomsz(2))+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)-1,szomsz(2))+1; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)];  end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)+1,szomsz(2))+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)+1,szomsz(2))+1; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1),szomsz(2)+1)+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1),szomsz(2)+1)+1; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1),szomsz(2)-1)+1 && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1),szomsz(2)-1)+1; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)]; end

       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)+1,szomsz(2)-1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)+1,szomsz(2)-1)+lambda; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)+1,szomsz(2)+1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)+1,szomsz(2)+1)+lambda; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)-1,szomsz(2)+1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)-1,szomsz(2)+1)+lambda; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)]; end
       
       if floor_field(szomsz(1),szomsz(2))>floor_field(szomsz(1)-1,szomsz(2)-1)+lambda && floor_field(szomsz(1),szomsz(2))~=500
           floor_field(szomsz(1),szomsz(2))=floor_field(szomsz(1)-1,szomsz(2)-1)+lambda; now_szomsz=[now_szomsz;szomsz(1),szomsz(2)]; end
       
    end
    
    szomsz_cell=SzomszedberakEsFalkiszed(floor_field,now_szomsz);%nemcsak fal, hanem objektum...            
    
end


%PlotFloorField(floor_field);                      %floor_field plotol�sa

%Manhattan metrika-f�le floor field, amikor diagon�lis mozg�s nem
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
    set(gca,'YDir','normal');                   %y tengely megford�t�sa (imagesc-n�l ford�tva van a default) 
    colormap(flipud(hot));                      %feh�r a legkisebb �rt�k, egyre nagyobb �rt�k egyre pirosabb
    caxis([0,max(max(floor_field(floor_field~=500)))+3]);%ne 500-ig menjen a colormap, mert a floor field �rt�kek kb 0-22 k�z�tt vannak
    
    %sz�veg r��r�sa a figure-ra:
    %ehhez a k�vetkez� k�dot �rtam �t:
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
    cb.Position=[0.9189 0.1900 0.0236 0.6500]; %colorbar hely�nek megv�ltoztat�sa
end  

function [new_szomsz]=SzomszedberakEsFalkiszed(floor_field,now_szomsz)
    now_szomsz=unique(now_szomsz,'rows');
    %{
    new_szomsz=[];
    
    for ii=1:size(now_szomsz,1)
        
            new_szomsz=[new_szomsz;
                now_szomsz(ii,1)+1, now_szomsz(ii,2);
                now_szomsz(ii,1)-1, now_szomsz(ii,2);
                now_szomsz(ii,1),   now_szomsz(ii,2)+1;
                now_szomsz(ii,1),   now_szomsz(ii,2)-1;
                now_szomsz(ii,1)+1, now_szomsz(ii,2)+1;
                now_szomsz(ii,1)-1, now_szomsz(ii,2)-1;
                now_szomsz(ii,1)+1, now_szomsz(ii,2)-1;
                now_szomsz(ii,1)-1, now_szomsz(ii,2)+1];
    end
    %}
    %{
    %kerdes, hogy ez a gyorsabb, vagy a fenti...
    new_szomsz=zeros(8*size(now_szomsz,2),2);
    for ii=1:size(now_szomsz,1)
        new_szomsz(8*(ii-1)+1:8*ii,:)=now_szomsz(ii,:)+[1,0;-1,0;0,1;0,-1;1,1;-1,-1;1,-1;-1,1];
    end
    %}
    %vektoriz�lt:leggyorsabb, de  bsxfun-all tal�n m�ggyorsabb is lehetne...
    %
    a=[1,0;-1,0;0,1;0,-1;1,1;-1,-1;1,-1;-1,1];
    new_szomsz=now_szomsz(reshape(repmat(1:size(now_szomsz,1),8,1),size(now_szomsz,1)*8,1),:)+repmat(a,size(now_szomsz,1),1);
    %}
    
    new_szomsz=unique(new_szomsz,'rows');
    %a fal �s objektumok indexeinek kiszed�se
    linear_new_szomsz = sub2ind(size(floor_field), new_szomsz(:,1), new_szomsz(:,2));
    AA=(floor_field(linear_new_szomsz)~=500 & floor_field(linear_new_szomsz)~=1);
    linear_new_szomsz=linear_new_szomsz(AA);
    [x,y]=ind2sub(size(floor_field),linear_new_szomsz);
    new_szomsz=cat(2,x,y);
end




%az ajt�k nemajt�/fal szomsz�dainak megkeres�se (cska ha az ajt� a sz�len
%van) szebb, mint anno
%sajnos a sarkokon ez megbukik
function [szomsz_cell]=DoorSzomsz(door,N1,N2)
    %{
    szomsz_cell=zeros(size(door,1)*3,2);

    for ii=1:size(door,1)
        door_ii=door(ii,:);
        if door_ii(2)==1
            door_szomsz=door_ii+[0,1;1,1;-1,1]; end
        if door_ii(2)==N2+2
            door_szomsz=door_ii+[0,-1;-1,-1;1,-1]; end
        if door_ii(1)==1
            door_szomsz=door_ii+[1,0;1,1;1,-1]; end
        if door_ii(1)==N1+2
            door_szomsz=door_ii+[-1,0;-1,1;-1,-1]; end

        szomsz_cell(3*(ii-1)+1:3*ii,:)=door_szomsz;
    end
    %}
    %vektoriz�lt v�ltozat (bsxfun k�s�bb)
    a=[1,0;-1,0;0,1;0,-1;1,1;-1,-1;1,-1;-1,1];
    szomsz_cell=door(reshape(repmat(1:size(door,1),8,1),size(door,1)*8,1),:)+repmat(a,size(door,1),1);
    szomsz_cell=unique(szomsz_cell,'rows');       %duplik�tumok kiszed�se
    %kiszed ami a termen kiv�l van, vagy fal
    l_tmp=sum(szomsz_cell>[0,0] & szomsz_cell<[N1+2,N2+2],2)==2;
    szomsz_cell=reshape(szomsz_cell([l_tmp,l_tmp]),[],2);
    l_tmp=floor_field(sub2ind(size(floor_field),szomsz_cell(:,1),szomsz_cell(:,2)))~=500&floor_field(sub2ind(size(floor_field),szomsz_cell(:,1),szomsz_cell(:,2)))~=1;
    szomsz_cell=reshape(szomsz_cell([l_tmp,l_tmp]),[],2);
end

end
