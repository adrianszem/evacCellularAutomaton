
function EvacCA(N1,N2,doors,num_of_people,tnum)
%példafuttatások:
%EvacCA
%EvacCA(14,18,[8,1;9,1],100,100)
%EvacCA(14,18,[8,1;9,1;1,5;1,6],200,100)

    %Ez a fõ függvényem, ezt kell meghívni
    %E függvény futattja le az evakuációs szimulációt
    
    %Bemenet:
        %0 db bemenet esetén: Elõre definiált osztályteremre szimuláció
        
        %4 db bemenet esetén: üres teremre szimuláció, ahol
            %N1: terem függõleges celláinak száma
            %N2: terem vízszintes celláinak száma
            %doors: ajtók helyzetei a következõképpen:[elsõ ajtó elsõ
                %koordinátája, elsõ ajtó második koordinátája; második ajtó elsõ
                %koordinátája, második ajtó második koordinátája;...]
                %sarkok megadása nem megengedett!!!
            %peoplenum: személyek száma
            %tnum: idõlépések száma

if (nargin==0)
   doors=[12,1;13,1];
   floor_field=FloorField;
elseif (nargin==5)
   floor_field=FloorField(N1,N2,doors);
   
   if size(doors,2)~=2
       error('Ajtók megadása nem megfelelõ!');
   end
   
   if num_of_people>N1*N2
       error('Ennyi személy nem fér el a szobában!');
   end
   
   if (N1<1 || N2<1 || num_of_people<1 || tnum<1)
       error('negatív szám vagy 0 megadása nem értelmezhetõ!');
   end
    
else
    error('Bemenetek nem megfelelõek');
end          
%N1=14;
%N2=18;

%doors=[8,1;9,1];
%doors=[12,1;13,1];
%doors=[8,1;9,1;8,18;9,18];
%doors=[3,1;4,1;10,1;11,1];
%doors=[5,1;12,1];

%floor_field=FloorField(N1,N2,doors);
%floor_field=FloorField;
grid_size=size(floor_field);

%cellában struktúrák...ez tünt logikusnak... (és tervbe volt véve 3D
%terekre való kiegészítés...
Grid=struct('ffval',[],'isobject',[],'isperson',cell(size(floor_field)));   %cella létrehozáse

%floor_field értékek hozzáadása
temp=num2cell(floor_field);     
[Grid.ffval]=temp{:};

%fal vagy objektum értékek hozzáadása 
temp=(floor_field==500);
temp1=num2cell(temp);
[Grid.isobject]=temp1{:};

%személyek random
if (nargin==5)
    %num_of_people=100;

    %egyenletes eloszlásba személyek kezdeti helyei (lineáris indexeléssel)
    not_obj_indices=find(temp==0);                               %indexek ahol nincs tárgy se fal
    rand_indices=randperm(size(not_obj_indices,1),num_of_people); %ebbõl random 50 darab index(ahova majd kezdetben személy kerül)
    rand_indices=rand_indices';
    not_obj_indices=not_obj_indices(rand_indices);                %személyek kezdeti (lineáris) indexei
    temp=zeros(size(floor_field));
    temp(not_obj_indices)=1;
    temp=num2cell(temp);
    [Grid.isperson]=temp{:};                                     %cella feltöltése
    plot_timesteps=round(linspace(0,tnum,4));                                  %melyik idõlépéseket plotolja
end

%személyek az osztályteremben
if (nargin==0)
    doors=[12,1;13,1];
    osztalyterem_emberek=num2cell(double(struct2array(load('oterem_emberek.mat'))));
    [Grid.isperson]=osztalyterem_emberek{:};
    tnum=45;
    plot_timesteps=[0,5,20,35];        %melyik idõlépéseket plotolja
end

%plot_timesteps=[0,5,20,30];         %melyik idõlépéseket plotolja
plot_timemat=[Grid];                 %kezdeti elhelyezkedés plotoláshoz
%zeros([size(floor_field),size(plot_timesteps,2)]);
for t=1:tnum
    %adott idõpontban ha két személnyek is ugyanaz a koordináta a kedvezõ lépés, akkor
    %azonos valószínûséggel lép oda az egyik mint a másik
    %ha az egyik odalép, akkor a másik helyben marad (felhasznált
    %publikációval megegyezõen)
    
    %ezt úgy oldottam meg, hogy a személyek koordinátáit "megkevertem"
    %a randperm függvény segítségével, a dokumentáció alapján: The sequence of numbers
    %produced by randperm is determined by the internal settings of the uniform pseudorandom
    %number generator that underlies rand, randi, randn, and randperm
    
    person_coords=find([Grid.isperson]==1);                     %megkeresem a személyek koordinátáit
    rand_person_coords_indices=randperm(size(person_coords,2)); %indexeket hozok létre
    person_coords=person_coords(rand_person_coords_indices);    %személyek koordinátáit "megkeverem
    
    %find((sort(person_coords)==find([Grid.isperson]==1))==0)%csekk: a kettõ ugyanaz
    
    NewGrid=Grid;                                               %következõ idõlépés cellája
    ttt=num2cell(zeros(size(Grid)));                            %nullára inicializálás
    [NewGrid.isperson]=ttt{:};
    %ahhoz hogy egy idõpontban több személy ne tudjon kimenni ugyanazon az
    %ajtó koordinátán
    %is_door_occupied=false([1,size(doors,2)]);
    
    for i=1:size(person_coords,2)
        
        [instant_coord_x,instant_coord_y]=ind2sub(grid_size,person_coords(i));      %a vizsgált személy koordinátái
        
        %izgulás beletevése:5% az esély arra, hogy nem lép semerre
        if rand<=0.05
            NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            continue;
        end
        
        %ha már az ajtóban van,"eltûnik" a newgridbõl (pontosabban a köv.
        %idõponthoz tartozó cellából)
        if isempty(find((sum(doors==[instant_coord_x,instant_coord_y],2))==2,1))==false
            NewGrid(instant_coord_x,instant_coord_y).isperson=0;
            continue;
        end
        
        nhood=Grid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1);        %vizsgált személy környezete 
        nhood_new=NewGrid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1); %vizsgált személy környezete a köv. idõpontban (azért, hogy ha már valaki oda lépett, ahova õ akarna, akkor helybe maradjon)
        nhood_ffval=[nhood(:).ffval];                                                               %vizsgált személy környezetének floor field értékei

        %ha valahol van személy vagy tárgy/fal, akkor ode ne lépjen (ne
        %ott legyen a minimum ahova lép:
        nhood_ffval(logical([nhood(:).isperson]))=inf;        
        nhood_ffval(logical([nhood(:).isobject]))=inf;
        %nhood_ffval(logical([nhood_new(:).isperson]))=inf;%ne lépjen két személy ugyanoda
        [minval,minind]=min(nhood_ffval);
        
        %ha több legkisebb elem is van, akkor azonos valséggel lép valamelyikre... 
        if sum(sum(nhood_ffval([1 2 3 4 6 7 8 9])==minval))~=1 

            more_than_one_indices=find(nhood_ffval==minval);
            minind=more_than_one_indices(randi(size(more_than_one_indices,2)));
            
        end

        %a vizsgált személy lép, ha tud hova lépni és ha még ebben az idõpontban nem lépett oda
        %senki
        if minval==inf %ha nemtud sehova lépni, akkor egyhelyben marad
            NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
        elseif minind==1
            if NewGrid(instant_coord_x-1,instant_coord_y-1).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
                NewGrid(instant_coord_x-1,instant_coord_y-1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            end
        elseif minind==2
             if NewGrid(instant_coord_x,instant_coord_y-1).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            NewGrid(instant_coord_x,instant_coord_y-1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==3
             if NewGrid(instant_coord_x+1,instant_coord_y-1).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            NewGrid(instant_coord_x+1,instant_coord_y-1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==4
             if NewGrid(instant_coord_x-1,instant_coord_y).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            NewGrid(instant_coord_x-1,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==6
             if NewGrid(instant_coord_x+1,instant_coord_y).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            NewGrid(instant_coord_x+1,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==7
             if NewGrid(instant_coord_x-1,instant_coord_y+1).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            NewGrid(instant_coord_x-1,instant_coord_y+1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==8
             if NewGrid(instant_coord_x,instant_coord_y+1).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            NewGrid(instant_coord_x,instant_coord_y+1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==9
             if NewGrid(instant_coord_x+1,instant_coord_y+1).isperson==1
                NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            NewGrid(instant_coord_x+1,instant_coord_y+1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        end
         
         %egy idõ alatt lehet az, hogy aki ellép a koordinátából oda abban
         %az idõben más odaléphet...
        %Grid(instant_coord_x,instant_coord_y).isperson=0;
        
    end
    
        plot_grid(NewGrid,t);       %pillanatnyi idõpont plottolása
        
        Grid=NewGrid;               %Grid frissítése
        
        %a subplottolni akart idõpontok lementése
        if isempty(find(plot_timesteps==t,1))==false
            plot_timemat=cat(3,plot_timemat,Grid);
        end
        
        %pause(0.05);
        
        waitforbuttonpress;
end

plot_four_time(plot_timemat,plot_timesteps);    %subplotolni akart idõpontok plotolása

function plot_four_time(dat,plot_timesteps)
    
    %a default subplot túl nagy térközöket hagy, ami miatt a képek túl
    %kicsik lesznek, subtightplot függvénnyel ez kiküszöbölhetõ (nem saját
    %függvény, fileexchangerrõl "loptam" 
    subplot = @(m,n,p) subtightplot (m, n, p, [0.04 0.05], [0.1 0.1], [0.1 0.01]);
    
    figure;
    subplot(2,2,1);
    plot_grid(dat(:,:,1),plot_timesteps(1));
    axis off;
    subplot(2,2,2);
    plot_grid(dat(:,:,2),plot_timesteps(2));
    axis off;
    subplot(2,2,3);
    plot_grid(dat(:,:,3),plot_timesteps(3));
    axis off;
    subplot(2,2,4);
    plot_grid(dat(:,:,4),plot_timesteps(4));
    axis off;
    
end

%egy idõpont plotolása
function plot_grid(Grid,t)

A=2*reshape([Grid.isperson],[size(Grid)]);
B=1*reshape([Grid.isobject],[size(Grid)]);
mymap=[1 1 1;0 0 0;1 0 1];
%figure;

imagesc(A+B);
title(['t= ',num2str(t)]);
colormap(mymap);
set(gca,'YDir','normal');
colorbar('Ticks',[0,1,2,],...
         'TickLabels',{'Üres cella','Fal/Objektum','Személy'})
axis equal;

end
end