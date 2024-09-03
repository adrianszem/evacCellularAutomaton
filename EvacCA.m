
function EvacCA(N1,N2,doors,num_of_people,tnum)
%p�ldafuttat�sok:
%EvacCA
%EvacCA(14,18,[8,1;9,1],100,100)
%EvacCA(14,18,[8,1;9,1;1,5;1,6],200,100)

    %Ez a f� f�ggv�nyem, ezt kell megh�vni
    %E f�ggv�ny futattja le az evaku�ci�s szimul�ci�t
    
    %Bemenet:
        %0 db bemenet eset�n: El�re defini�lt oszt�lyteremre szimul�ci�
        
        %4 db bemenet eset�n: �res teremre szimul�ci�, ahol
            %N1: terem f�gg�leges cell�inak sz�ma
            %N2: terem v�zszintes cell�inak sz�ma
            %doors: ajt�k helyzetei a k�vetkez�k�ppen:[els� ajt� els�
                %koordin�t�ja, els� ajt� m�sodik koordin�t�ja; m�sodik ajt� els�
                %koordin�t�ja, m�sodik ajt� m�sodik koordin�t�ja;...]
                %sarkok megad�sa nem megengedett!!!
            %peoplenum: szem�lyek sz�ma
            %tnum: id�l�p�sek sz�ma

if (nargin==0)
   doors=[12,1;13,1];
   floor_field=FloorField;
elseif (nargin==5)
   floor_field=FloorField(N1,N2,doors);
   
   if size(doors,2)~=2
       error('Ajt�k megad�sa nem megfelel�!');
   end
   
   if num_of_people>N1*N2
       error('Ennyi szem�ly nem f�r el a szob�ban!');
   end
   
   if (N1<1 || N2<1 || num_of_people<1 || tnum<1)
       error('negat�v sz�m vagy 0 megad�sa nem �rtelmezhet�!');
   end
    
else
    error('Bemenetek nem megfelel�ek');
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

%cell�ban strukt�r�k...ez t�nt logikusnak... (�s tervbe volt v�ve 3D
%terekre val� kieg�sz�t�s...
Grid=struct('ffval',[],'isobject',[],'isperson',cell(size(floor_field)));   %cella l�trehoz�se

%floor_field �rt�kek hozz�ad�sa
temp=num2cell(floor_field);     
[Grid.ffval]=temp{:};

%fal vagy objektum �rt�kek hozz�ad�sa 
temp=(floor_field==500);
temp1=num2cell(temp);
[Grid.isobject]=temp1{:};

%szem�lyek random
if (nargin==5)
    %num_of_people=100;

    %egyenletes eloszl�sba szem�lyek kezdeti helyei (line�ris indexel�ssel)
    not_obj_indices=find(temp==0);                               %indexek ahol nincs t�rgy se fal
    rand_indices=randperm(size(not_obj_indices,1),num_of_people); %ebb�l random 50 darab index(ahova majd kezdetben szem�ly ker�l)
    rand_indices=rand_indices';
    not_obj_indices=not_obj_indices(rand_indices);                %szem�lyek kezdeti (line�ris) indexei
    temp=zeros(size(floor_field));
    temp(not_obj_indices)=1;
    temp=num2cell(temp);
    [Grid.isperson]=temp{:};                                     %cella felt�lt�se
    plot_timesteps=round(linspace(0,tnum,4));                                  %melyik id�l�p�seket plotolja
end

%szem�lyek az oszt�lyteremben
if (nargin==0)
    doors=[12,1;13,1];
    osztalyterem_emberek=num2cell(double(struct2array(load('oterem_emberek.mat'))));
    [Grid.isperson]=osztalyterem_emberek{:};
    tnum=45;
    plot_timesteps=[0,5,20,35];        %melyik id�l�p�seket plotolja
end

%plot_timesteps=[0,5,20,30];         %melyik id�l�p�seket plotolja
plot_timemat=[Grid];                 %kezdeti elhelyezked�s plotol�shoz
%zeros([size(floor_field),size(plot_timesteps,2)]);
for t=1:tnum
    %adott id�pontban ha k�t szem�lnyek is ugyanaz a koordin�ta a kedvez� l�p�s, akkor
    %azonos val�sz�n�s�ggel l�p oda az egyik mint a m�sik
    %ha az egyik odal�p, akkor a m�sik helyben marad (felhaszn�lt
    %publik�ci�val megegyez�en)
    
    %ezt �gy oldottam meg, hogy a szem�lyek koordin�t�it "megkevertem"
    %a randperm f�ggv�ny seg�ts�g�vel, a dokument�ci� alapj�n: The sequence of numbers
    %produced by randperm is determined by the internal settings of the uniform pseudorandom
    %number generator that underlies rand, randi, randn, and randperm
    
    person_coords=find([Grid.isperson]==1);                     %megkeresem a szem�lyek koordin�t�it
    rand_person_coords_indices=randperm(size(person_coords,2)); %indexeket hozok l�tre
    person_coords=person_coords(rand_person_coords_indices);    %szem�lyek koordin�t�it "megkeverem
    
    %find((sort(person_coords)==find([Grid.isperson]==1))==0)%csekk: a kett� ugyanaz
    
    NewGrid=Grid;                                               %k�vetkez� id�l�p�s cell�ja
    ttt=num2cell(zeros(size(Grid)));                            %null�ra inicializ�l�s
    [NewGrid.isperson]=ttt{:};
    %ahhoz hogy egy id�pontban t�bb szem�ly ne tudjon kimenni ugyanazon az
    %ajt� koordin�t�n
    %is_door_occupied=false([1,size(doors,2)]);
    
    for i=1:size(person_coords,2)
        
        [instant_coord_x,instant_coord_y]=ind2sub(grid_size,person_coords(i));      %a vizsg�lt szem�ly koordin�t�i
        
        %izgul�s beletev�se:5% az es�ly arra, hogy nem l�p semerre
        if rand<=0.05
            NewGrid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            continue;
        end
        
        %ha m�r az ajt�ban van,"elt�nik" a newgridb�l (pontosabban a k�v.
        %id�ponthoz tartoz� cell�b�l)
        if isempty(find((sum(doors==[instant_coord_x,instant_coord_y],2))==2,1))==false
            NewGrid(instant_coord_x,instant_coord_y).isperson=0;
            continue;
        end
        
        nhood=Grid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1);        %vizsg�lt szem�ly k�rnyezete 
        nhood_new=NewGrid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1); %vizsg�lt szem�ly k�rnyezete a k�v. id�pontban (az�rt, hogy ha m�r valaki oda l�pett, ahova � akarna, akkor helybe maradjon)
        nhood_ffval=[nhood(:).ffval];                                                               %vizsg�lt szem�ly k�rnyezet�nek floor field �rt�kei

        %ha valahol van szem�ly vagy t�rgy/fal, akkor ode ne l�pjen (ne
        %ott legyen a minimum ahova l�p:
        nhood_ffval(logical([nhood(:).isperson]))=inf;        
        nhood_ffval(logical([nhood(:).isobject]))=inf;
        %nhood_ffval(logical([nhood_new(:).isperson]))=inf;%ne l�pjen k�t szem�ly ugyanoda
        [minval,minind]=min(nhood_ffval);
        
        %ha t�bb legkisebb elem is van, akkor azonos vals�ggel l�p valamelyikre... 
        if sum(sum(nhood_ffval([1 2 3 4 6 7 8 9])==minval))~=1 

            more_than_one_indices=find(nhood_ffval==minval);
            minind=more_than_one_indices(randi(size(more_than_one_indices,2)));
            
        end

        %a vizsg�lt szem�ly l�p, ha tud hova l�pni �s ha m�g ebben az id�pontban nem l�pett oda
        %senki
        if minval==inf %ha nemtud sehova l�pni, akkor egyhelyben marad
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
         
         %egy id� alatt lehet az, hogy aki ell�p a koordin�t�b�l oda abban
         %az id�ben m�s odal�phet...
        %Grid(instant_coord_x,instant_coord_y).isperson=0;
        
    end
    
        plot_grid(NewGrid,t);       %pillanatnyi id�pont plottol�sa
        
        Grid=NewGrid;               %Grid friss�t�se
        
        %a subplottolni akart id�pontok lement�se
        if isempty(find(plot_timesteps==t,1))==false
            plot_timemat=cat(3,plot_timemat,Grid);
        end
        
        %pause(0.05);
        
        waitforbuttonpress;
end

plot_four_time(plot_timemat,plot_timesteps);    %subplotolni akart id�pontok plotol�sa

function plot_four_time(dat,plot_timesteps)
    
    %a default subplot t�l nagy t�rk�z�ket hagy, ami miatt a k�pek t�l
    %kicsik lesznek, subtightplot f�ggv�nnyel ez kik�sz�b�lhet� (nem saj�t
    %f�ggv�ny, fileexchangerr�l "loptam" 
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

%egy id�pont plotol�sa
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
         'TickLabels',{'�res cella','Fal/Objektum','Szem�ly'})
axis equal;

end
end