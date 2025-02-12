function EvacCaDistr(fname,num_of_ppl)
%EVACCADIST outer function for the dynamical floor field CA evacuation model
%
% EVACCADISTR(fname) Do the CA simulation with room given by fname.mat, ppl
%   initial conditions given by fname_ppl.mat
%
% EVACCADISTR(fname,num_of_ppl) Do the CA simulation with room given by fname.mat, ppl
%   initial conditions given randomly for num_of_ppl number of ppl
%Example: EvacCaDistr('teremkeke')
%         EvacCaDistr('teremkeke',10)


%one run 0.150 sec, half of which is FloorField fnc, called 3x

t_num=30;
alpha=1;

strcat(fname,'.mat')

terem=open(strcat(fname,'.mat'));
floor_field=terem.floor_field;
doors=doorsearch(floor_field);

%this matrices fixed
floor_fields_mtx=zeros([size(floor_field),size(doors,2)]);
%instead, I may calculate in each step only for the cells where there is a
%person...
%which is better depends on the number of people and steps
smaller_elements_mtx=zeros(size(floor_fields_mtx)); 
equal_elements_mtx=zeros(size(floor_fields_mtx));  

doors_range=1:size(doors,2);
for ind1=doors_range
    floor_field_tmp=floor_field;
    for ind2=doors_range(doors_range~=ind1)
            d=doors{ind2};
            %can also handle variable length doors
            floor_field_tmp(sub2ind(size(floor_field_tmp),d(:,1),d(:,2)))=500; 
    end
    ff_tmp=FloorField(floor_field_tmp,doors{ind1});
    floor_fields_mtx(:,:,ind1)=ff_tmp;
    %how much smaller elements (lin indexing) - vectorised
    smaller_elements_mtx(:,:,ind1)=reshape(sum(ff_tmp(:)>(ff_tmp(:))',2),size(ff_tmp));
    equal_elements_mtx(:,:,ind1)=0.5*reshape(sum(ff_tmp(:)==(ff_tmp(:))',2)-1,size(ff_tmp));
end

grid_size=size(floor_field);
%cell initialization
Grid=struct('ffval',[],'isobject',[],'isperson',cell(size(floor_field)),'num_of_smaller',[]);   

num_of_people=40;

if (nargin==2)
    %initial locations of persons uniformly distributed (by linear indexing)
    temp=(floor_field==500);
    %indexes where no object or wall
    not_obj_indices=find(temp==0);
    %of which random num_of_people indexes (where a person will initially be placed)
    rand_indices=randperm(size(not_obj_indices,1),num_of_people); 
    rand_indices=rand_indices';
    %initial (linear) indices of persons
    not_obj_indices=not_obj_indices(rand_indices);                
    temp=zeros(size(floor_field));
    temp(not_obj_indices)=1;
elseif (nargin==1)
    szemelyek=open(strcat(fname,'_ppl.mat'));
    temp=szemelyek.ppl;
else
    error('ppl_given should be 0 or 1');
end


temp=num2cell(temp);
[Grid.isperson]=temp{:}; 
%cell filling part
%which time steps to plot
plot_timesteps=[0,10,20,30];%round(linspace(0,t_num,4));                    

%add wall or object values
temp=(floor_field==500);
temp1=num2cell(temp);
[Grid.isobject]=temp1{:};

%for the plotting of initial locations
plot_timemat=[Grid];                                        

%adding the dinamyc floor_field values for the init pos
temp=num2cell(CalcDynamicFloorField(Grid,floor_fields_mtx,alpha,doors));
[Grid.ffval]=temp{:};

for t=1:t_num
    %find the coordinates of the persons
    person_coords=find([Grid.isperson]==1); 
    %I create indexes
    rand_person_coords_indices=randperm(size(person_coords,2));
    %"shuffle" the coordinates of the ppl
    person_coords=person_coords(rand_person_coords_indices);  
    
    %find((sort(person_coords)==find([Grid.isperson]==1))==0)%csekk:two is
    %the same
    
    %cell of the next timestep
    new_grid=Grid;  
    %initialization to 0
    ttt=num2cell(zeros(size(Grid)));                            
    [new_grid.isperson]=ttt{:};
    %to prevent several people from going out at the same time on the same
    %door coordinate
    %is_door_occupied=false([1,size(doors,2)]);
    
    for i=1:size(person_coords,2)
        %coordinates of the person under investigation
        [instant_coord_x,instant_coord_y]=ind2sub(grid_size,person_coords(i));      
        
        %excited person:5% chance that it will go nowhere
        if rand<=0.05
            new_grid(instant_coord_x,instant_coord_y).isperson=Grid(instant_coord_x,instant_coord_y).isperson;
            continue;
        end
        
        %once in the doorway, it "disappears" from the newgrid
        % (more precisely, from the cell corresponding to the next time)
        if isempty(find((sum(vertcat(doors{:})==[instant_coord_x,instant_coord_y],2))==2,1))==false %old code w not cells%isempty(find((sum(doors==[instant_coord_x,instant_coord_y],2))==2,1))==false
            new_grid(instant_coord_x,instant_coord_y).isperson=0;
            continue;
        end
        
        %the test person's environment 
        nhood=Grid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1);       
        %the subject's environment at the next time point
        % (so that if someone has already moved to where they want to be, they stay put)
        nhood_new=new_grid(instant_coord_x-1:instant_coord_x+1,instant_coord_y-1:instant_coord_y+1); 
        %the tested person's ngbhd-s floor field values
        nhood_ffval=[nhood(:).ffval];                                                               

        %if there is a person or an object/wall somewhere,
        % do not step on it (don't step on it as a minimum):
        nhood_ffval(logical([nhood(:).isperson]))=inf;        
        nhood_ffval(logical([nhood(:).isobject]))=inf;
        %nhood_ffval(logical([nhood_new(:).isperson]))=inf;%ne lépjen két személy ugyanoda
        [minval,minind]=min(nhood_ffval);
        
        %if there is more than one smallest element, it will step on one with the same chance... 
        if sum(sum(nhood_ffval([1 2 3 4 6 7 8 9])==minval))~=1 

            more_than_one_indices=find(nhood_ffval==minval);
            minind=more_than_one_indices(randi(size(more_than_one_indices,2)));
            
        end

        %the person under investigation moves if he/she can move and if no one has moved there at this time
        %if he cannot move anywhere, than stays there
        if minval==inf
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
         
        %for the simultaneous update..
        %Grid(instant_coord_x,instant_coord_y).isperson=0;
        
    end
        CalcDynamicFloorField(new_grid,floor_fields_mtx,alpha,doors)
        temp=num2cell(CalcDynamicFloorField(new_grid,floor_fields_mtx,alpha,doors));
        [new_grid.ffval]=temp{:};
        
        %for plotting
        PlotGrid(new_grid,t);
        %grid refresh/update
        Grid=new_grid;               
        
        %save the times which we want to subplot
        if isempty(find(plot_timesteps==t,1))==false
            plot_timemat=cat(3,plot_timemat,Grid);
        end
        
        pause(0.05);
        
        %waitforbuttonpress;
end

%plot the steps you want to subplot
PlotFourTimes(plot_timemat,plot_timesteps);    

function PlotFourTimes(dat,plot_timesteps)
%default subplot leaves too big spaces, which makes the images too small,
% subtightplot function can be used to avoid this (not my own function,
% I "stole" it from fileexchanger )

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

%plot of one time instance
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
%Update for the dynamic floorfield
    doors_range=1:size(doors,2);
    %smaller_elements_mtx=zeros(size(floor_fields_mtx)); 
    %equal_elements_mtx=zeros(size(floor_fields_mtx));   
    dynamic_floor_field=zeros(size(floor_fields_mtx));  
                                                         
                                                        
    
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
    dyn_floor_field(sub2ind(size(dyn_floor_field),doors_tmp(:,1),doors_tmp(:,2)))=1;

end

end