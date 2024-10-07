%egy lefutás 0.150 sec, ennek fele a FloorField fgv, melyet 3x hív meg
num_of_people=20;
t_num=30;
alpha=1;

terem=open('proba.mat');
floor_field=terem.floor_field;
%floor_field(12,8)=1;
doors=doorsearch(floor_field);

%ezen mtx-ek fixek
floor_fields_mtx=zeros([size(floor_field),size(doors,2)]);
smaller_elements_mtx=zeros(size(floor_fields_mtx)); %ehelyett lehet, hogy minden lépésben csak azon cellákra számolom ki, ahol van személy...
equal_elements_mtx=zeros(size(floor_fields_mtx));   %hogy melyik jobb függ az emberek, lépések számától

doors_range=1:size(doors,2);
for ind1=doors_range
    floor_field_tmp=floor_field;
    for ind2=doors_range(doors_range~=ind1)
            d=doors{ind2};
            floor_field_tmp(sub2ind(size(floor_field_tmp),d(:,1),d(:,2)))=500; %így változó hosszú ajtókat is tud kezelni
    end
    ff_tmp=FloorField(floor_field_tmp,doors{ind1});
    floor_fields_mtx(:,:,ind1)=ff_tmp;
    smaller_elements_mtx(:,:,ind1)=reshape(sum(ff_tmp(:)>(ff_tmp(:))',2),size(ff_tmp)); %mennyi kisebb elem (lin indexelés) - vektorizált
    equal_elements_mtx(:,:,ind1)=0.5*reshape(sum(ff_tmp(:)==(ff_tmp(:))',2)-1,size(ff_tmp));
end

grid_size=size(floor_field);

Grid=struct('ffval',[],'isobject',[],'isperson',cell(size(floor_field)),'num_of_smaller',[]);   %cella létrehozáse

%egyenletes eloszlásba személyek kezdeti helyei (lineáris indexeléssel)
temp=(floor_field==500);
not_obj_indices=find(temp==0);                                %indexek ahol nincs tárgy se fal
rand_indices=randperm(size(not_obj_indices,1),num_of_people); %ebbõl random 50 darab index(ahova majd kezdetben személy kerül)
rand_indices=rand_indices';
not_obj_indices=not_obj_indices(rand_indices);                %személyek kezdeti (lineáris) indexei
temp=zeros(size(floor_field));
temp(not_obj_indices)=1;
temp=zeros(size(floor_field));
temp([2:11],[2:4])=1;
temp=num2cell(temp);
[Grid.isperson]=temp{:};                                     %cella feltöltése
plot_timesteps=round(linspace(0,t_num,4));                    %melyik idõlépéseket plotolja

%fal vagy objektum értékek hozzáadása 
temp=(floor_field==500);
temp1=num2cell(temp);
[Grid.isobject]=temp1{:};

plot_timemat=[Grid];                                         %kezdeti elhelyezkedés plotoláshoz

%floor_field értékek hozzáadása
temp=num2cell(CalcDynamicFloorField(Grid,floor_fields_mtx,alpha,doors));
[Grid.ffval]=temp{:};

for t=1:t_num

    person_coords=find([Grid.isperson]==1);                     %megkeresem a személyek koordinátáit
    rand_person_coords_indices=randperm(size(person_coords,2)); %indexeket hozok létre
    person_coords=person_coords(rand_person_coords_indices);    %személyek koordinátáit "megkeverem
    
    %find((sort(person_coords)==find([Grid.isperson]==1))==0)%csekk: a kettõ ugyanaz
    
    new_grid=Grid;                                               %következõ idõlépés cellája
    ttt=num2cell(zeros(size(Grid)));                            %nullára inicializálás
    [new_grid.isperson]=ttt{:};
    %ahhoz hogy egy idõpontban több személy ne tudjon kimenni ugyanazon az
    %ajtó koordinátán
    %is_door_occupied=false([1,size(doors,2)]);
    
    for i=1:size(person_coords,2)
        
        [instant_coord_x,instant_coord_y]=ind2sub(grid_size,person_coords(i));      %a vizsgált személy koordinátái
        
        %izgulás beletevése:5% az esély arra, hogy nem lép semerre
        if rand<=0.05
            new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            continue;
        end
        
        %ha már az ajtóban van,"eltûnik" a newgridbõl (pontosabban a köv.
        %idõponthoz tartozó cellából)
        if isempty(find((sum(vertcat(doors{:})==[instant_coord_x,instant_coord_y],2))==2,1))==false %régi kódban a doors nem cellak%isempty(find((sum(doors==[instant_coord_x,instant_coord_y],2))==2,1))==false
            new_grid(instant_coord_x,instant_coord_y).isperson=0;
            continue;
        end
        
        nhood=Grid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1);        %vizsgált személy környezete 
        nhood_new=new_grid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1); %vizsgált személy környezete a köv. idõpontban (azért, hogy ha már valaki oda lépett, ahova õ akarna, akkor helybe maradjon)
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
            new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
        elseif minind==1
            if new_grid(instant_coord_x-1,instant_coord_y-1).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
                new_grid(instant_coord_x-1,instant_coord_y-1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            end
        elseif minind==2
             if new_grid(instant_coord_x,instant_coord_y-1).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            new_grid(instant_coord_x,instant_coord_y-1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==3
             if new_grid(instant_coord_x+1,instant_coord_y-1).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            new_grid(instant_coord_x+1,instant_coord_y-1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==4
             if new_grid(instant_coord_x-1,instant_coord_y).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            new_grid(instant_coord_x-1,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==6
             if new_grid(instant_coord_x+1,instant_coord_y).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            new_grid(instant_coord_x+1,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==7
             if new_grid(instant_coord_x-1,instant_coord_y+1).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            new_grid(instant_coord_x-1,instant_coord_y+1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==8
             if new_grid(instant_coord_x,instant_coord_y+1).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            new_grid(instant_coord_x,instant_coord_y+1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        elseif minind==9
             if new_grid(instant_coord_x+1,instant_coord_y+1).isperson==1
                new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            else
            new_grid(instant_coord_x+1,instant_coord_y+1).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
             end
        end
         
         %egy idõ alatt lehet az, hogy aki ellép a koordinátából oda abban
         %az idõben más odaléphet...
        %Grid(instant_coord_x,instant_coord_y).isperson=0;
        
    end
        CalcDynamicFloorField(new_grid,floor_fields_mtx,alpha,doors)
        temp=num2cell(CalcDynamicFloorField(new_grid,floor_fields_mtx,alpha,doors));
        [new_grid.ffval]=temp{:};

        PlotGrid(new_grid,t);       %pillanatnyi idõpont plottolása      
        Grid=new_grid;               %Grid frissítése
        
        %a subplottolni akart idõpontok lementése
        if isempty(find(plot_timesteps==t,1))==false
            plot_timemat=cat(3,plot_timemat,Grid);
        end
        
        %pause(0.05);
        
        waitforbuttonpress;
end

PlotFourTimes(plot_timemat,plot_timesteps);    %subplotolni akart idõpontok plotolása

function PlotFourTimes(dat,plot_timesteps)
    
    %a default subplot túl nagy térközöket hagy, ami miatt a képek túl
    %kicsik lesznek, subtightplot függvénnyel ez kiküszöbölhetõ (nem saját
    %függvény, fileexchangerrõl "loptam" 
    subplot = @(m,n,p) subtightplot (m, n, p, [0.04 0.05], [0.1 0.1], [0.1 0.01]);
    
    figure;
    subplot(2,2,1);
    PlotGrid(dat(:,:,1),plot_timesteps(1));
    axis off;
    subplot(2,2,2);
    PlotGrid(dat(:,:,2),plot_timesteps(2));
    axis off;
    subplot(2,2,3);
    PlotGrid(dat(:,:,3),plot_timesteps(3));
    axis off;
    subplot(2,2,4);
    PlotGrid(dat(:,:,4),plot_timesteps(4));
    axis off;
    
end

%egy idõpont plotolása
function PlotGrid(Grid,t)

    A=2*reshape([Grid.isperson],[size(Grid)]);
    B=1*reshape([Grid.isobject],[size(Grid)]);
    my_map=[1 1 1;0 0 0;1 0 1];
    %figure;
    
    imagesc(A+B);
    title(['t= ',num2str(t)]);
    colormap(my_map);
    set(gca,'YDir','normal');
    colorbar('Ticks',[0,1,2,],...
             'TickLabels',{'Üres cella','Fal/Objektum','Személy'})
    axis equal;

end


function dyn_floor_field=CalcDynamicFloorField(Grid,floor_fields_mtx,alpha,doors)
    doors_range=1:size(doors,2);
    %smaller_elements_mtx=zeros(size(floor_fields_mtx)); %ehelyett lehet, hogy minden lépésben csak azon cellákra számolom ki, ahol van személy...
    %equal_elements_mtx=zeros(size(floor_fields_mtx));   %hogy melyik jobb függ az emberek, lépések számától
    dynamic_floor_field=zeros(size(floor_fields_mtx));   %de talan a 01 matrix
                                                         %szorzások gyorsabbak,
                                                         %mint kül, indexelések
    
    for ind1=doors_range
        persons_mtx=reshape([Grid.isperson],size(floor_fields_mtx,[1,2]));%repmat(reshape([Grid.isperson],size(floor_field)),1,1,3);
        ff_tmp1=floor_fields_mtx(:,:,ind1);
        ff_tmp2=ff_tmp1;%.*persons_mtx;
        %smaller_elements_mtx(:,:,ind1)=reshape((ff_tmp2(:)>(ff_tmp2(:))')*(persons_mtx(:)~=0),size(ff_tmp2)); %mennyi kisebb elem (lin indexelés) - vektorizált
        %equal_elements_mtx(:,:,ind1)=0.5*reshape((ff_tmp2(:)==(ff_tmp2(:))'*(persons_mtx(:)~=0)-1),size(ff_tmp2));%mennyi egyenlő, amin állnak
        %a kettő kikommentelt együtt+ statikus rész is
        dynamic_floor_field(:,:,ind1)=ff_tmp1+(alpha/size(doors{ind1},1))*(reshape((ff_tmp2(:)>(ff_tmp2(:))')*(persons_mtx(:)~=0),size(ff_tmp2))+0.5*reshape((ff_tmp2(:)==(ff_tmp2(:))'*(persons_mtx(:)~=0)-1),size(ff_tmp2)));
    end
    
    dyn_floor_field=min(dynamic_floor_field,[],3);
    dyn_floor_field(reshape([Grid.isobject],size(floor_fields_mtx,[1,2]))==1)=500;
    doors_tmp=vertcat(doors{:});
    dyn_floor_field(sub2ind(size(dyn_floor_field),doors_tmp(:,1),doors_tmp(:,2)))=1;%ez így egy kicsit csúnya...

end