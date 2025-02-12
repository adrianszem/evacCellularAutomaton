function [floor_field]=FloorField(N1,N2,doors)
    %FLOORFIELD Calculates the static potential field of the room, i.e. each cell is assigned a constant value
    %representing its distance to the door, when diagonal movement is allowed.  
    %Inputs:
    %   In the case of 0 inputs, it calculates the floor field of an example
    %       room
    %   In the case of 3 inputs, the inputs are:
    %       N1:length of the room
    %       N2: width of the room
    %       doors: coordinates of the room in the following way: [first door's first
    %           coord, first door's second coordinate; second door's first
    %           coordinate, second door's second coordinate;...]        
    %Output:
    %   floor_field: Static floorfield (matrix) with size N1xN2 calculated
    %       as in Varas, A., et al. "Cellular automaton model for evacuation process with obstacles." Physica A: Statistical Mechanics and its Applications 382.2 (2007): 631-642.
    %       
        
%N1=14;
%N2=18;
%doors=[7,1;8,1];
%doors=[4,1;5,1;10,1;11,1];
%value for the diagonal movement
lambda=3/2;  
%in the case when diagonal movement is not allowed
%lambda=500;                                           

%1:door
%200:empty
%500:obstacle

%schoolroom example
if (nargin==0)
    %
    osztalyterem=load('oterem.mat');
    floor_field=struct2array(osztalyterem.osztalyterem);
    %-2 because of the walls on the edges
    N1=size(floor_field,1)-2;
    N2=size(floor_field,2)-2;
    %change of the coordinates of the door
    %{
    floor_field(floor_field==1)=500;
    floor_field([8,9,8,9],[1,1,18,18])=1;
    %}
    [doors_x,doors_y]=find(floor_field==1);
    doors=cat(2,doors_x,doors_y);
    
%empty room (with walls dim n1+2 x n2+2)
elseif (nargin==3)
    %floor field inicialization
    floor_field=200*ones(N1,N2);
    %adding walls
    floor_field=padarray(floor_field,[1,1],500,'both');
    %adding doors
    floor_field(sub2ind(size(floor_field),doors(:,1),doors(:,2)))=1;     

elseif (nargin==2)
    floor_field=N1;
    doors=N2;
    N1=size(floor_field,1)-2;
    N2=size(floor_field,2)-2;
    
elseif (nargin~=3 && nargin ~=0 && nargin ~=2)
    error('Zero or 3 input arguments is required');
end

%neighbours of the doors
[szomsz_cell]=DoorSzomsz(doors,N1,N2);                  

now_szomsz=[];
% while cycle until not all elements of the matrix has a value (it was
% inicialized to 200)
while sum(ismember(floor_field(:),200))~=0             
    for i=1:size(szomsz_cell,1)
        
       szomsz=szomsz_cell(i,:);
       %check and update all neighbours of a cell, if this neighbour can give
       % it a lower value, then update to the lower value and find its neighbours
       % (nowszomsz) 
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

%plotting of the floor field
%PlotFloorField(floor_field);                      

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
%The function plots the floor_field values with a colormap
   
    figure('Name','Floor Field values');
    imagesc((floor_field));
    %reverse y-axis (imagesc has it reversed by default)
    set(gca,'YDir','normal');
    %white is the lowest value, the higher the value the redder
    colormap(flipud(hot));
    %should not go up to 500(values of the walls/objects, because the floor
    %field values are between 0-22 for decently sized rooms
    caxis([0,max(max(floor_field(floor_field~=500)))+3]);
    
    %writing text on the figure based on partly the code:
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
    %change of the position of the colorbar
    cb.Position=[0.9189 0.1900 0.0236 0.6500]; 
end  

function [new_szomsz]=SzomszedberakEsFalkiszed(floor_field,now_szomsz)
%get the neighbouring coordinates (which are not walls/objects
    now_szomsz=unique(now_szomsz,'rows');
    %first way to calculate it: nonvectorised version
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
    %second way
    new_szomsz=zeros(8*size(now_szomsz,2),2);
    for ii=1:size(now_szomsz,1)
        new_szomsz(8*(ii-1)+1:8*ii,:)=now_szomsz(ii,:)+[1,0;-1,0;0,1;0,-1;1,1;-1,-1;1,-1;-1,1];
    end
    %}
    %vectorised version:fastest, but with bsxfun it can be possibly faster...
    %
    a=[1,0;-1,0;0,1;0,-1;1,1;-1,-1;1,-1;-1,1];
    new_szomsz=now_szomsz(reshape(repmat(1:size(now_szomsz,1),8,1),size(now_szomsz,1)*8,1),:)+repmat(a,size(now_szomsz,1),1);
    %}
    
    new_szomsz=unique(new_szomsz,'rows');
    %removing wall and object indexes
    linear_new_szomsz = sub2ind(size(floor_field), new_szomsz(:,1), new_szomsz(:,2));
    AA=(floor_field(linear_new_szomsz)~=500 & floor_field(linear_new_szomsz)~=1);
    linear_new_szomsz=linear_new_szomsz(AA);
    [x,y]=ind2sub(size(floor_field),linear_new_szomsz);
    new_szomsz=cat(2,x,y);
end

function [szomsz_cell]=DoorSzomsz(door,N1,N2)
%finds the non-door neighbours of a door (in the case if the door is in the
%edge 
    %without vectorization:
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
    %with  vectorization 
    a=[1,0;-1,0;0,1;0,-1;1,1;-1,-1;1,-1;-1,1];
    szomsz_cell=door(reshape(repmat(1:size(door,1),8,1),size(door,1)*8,1),:)+repmat(a,size(door,1),1);
    szomsz_cell=unique(szomsz_cell,'rows');       %duplikátumok kiszedése
    %kiszed ami a termen kivül van, vagy fal
    l_tmp=sum(szomsz_cell>[0,0] & szomsz_cell<[N1+2,N2+2],2)==2;
    szomsz_cell=reshape(szomsz_cell([l_tmp,l_tmp]),[],2);
    l_tmp=floor_field(sub2ind(size(floor_field),szomsz_cell(:,1),szomsz_cell(:,2)))~=500&floor_field(sub2ind(size(floor_field),szomsz_cell(:,1),szomsz_cell(:,2)))~=1;
    szomsz_cell=reshape(szomsz_cell([l_tmp,l_tmp]),[],2);
end

end
