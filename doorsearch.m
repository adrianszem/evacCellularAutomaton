function doors_cell=doorsearch(floor_field)
% DOORSEARCH The function searches for the doors
% Meaning if two doors are next to each other, the output will give one
% door with two cells.
% Input: floorfield - Matrix where the value 1 are the doors
% output: doors_cell - Cells are the door coordinates, which are Nx2 sized
% matrices where N is the number or grids of the door

%Example: 
%   floor_field=zeros(10)
%   floor_field(1,5:7)=1
%   floor_field(10,4)=1
%   floor_field(5:6,10)=1
%   doors_cell=doorsearch(floor_field)
%   Output: {[10 4]}    {[1 5;1 6;1 7]}    {[5 10]}    {[6 10]}

N1=size(floor_field,1);
N2=size(floor_field,2);

[doors_x,doors_y]=find(floor_field==1);
doors=cat(2,doors_x,doors_y);

doors_cell={};

    while ~isempty(doors)
        door_tmp=doors(1,:);%kiválasztjók az ajtót, aminek keressük a szomszédait
        
        doors=doors(2:end,:);
        rest_doors_tmp=doors;
        szomsz=[];
        [szomsz,non_szomsz]=add_door_szomsz(door_tmp, rest_doors_tmp,N1,N2,szomsz);%empty output is no problem
        doors_cell(end+1)={[door_tmp;szomsz]};
        doors=non_szomsz;

    end


%end

function door1_szomsz=door_szomsz(door1,N1,N2)
    door1_szomsz=door1+[1,0;0,1;-1,0;0,-1;1,1;-1,-1;1,-1;-1,1];%szomszédai vektorizált
    i_tmp=door1_szomsz>0&door1_szomsz<[N1,N2];%out of bound
    i_tmp2=i_tmp(:,1)&i_tmp(:,2);
    door1_szomsz=reshape(door1_szomsz([i_tmp2,i_tmp2]),[],2);
end

function [is_one_door_logi,which_door]=is_one_door(door1_szomsz,door2)
    tmp=sum(door1_szomsz==door2,2)==2;
    which_door=reshape(door1_szomsz(repmat(tmp,1,2)),[],2);
    is_one_door_logi=sum(tmp);

end

function [szomsz,non_szomsz]=add_door_szomsz(door_tmp, doors_possible_szomsz,N1,N2,szomsz)
    
    non_szomsz=doors_possible_szomsz;
    if isempty(doors_possible_szomsz)
        return;
    else
        door_tmp_szomsz=door_szomsz(door_tmp,N1,N2);%az ajtó nem feltétlenül ajtó szomszédai
        for j=1:size(doors_possible_szomsz,1)
                [is_one_door_logi,~]=is_one_door(door_tmp_szomsz,doors_possible_szomsz(j,:));
                if is_one_door_logi
                    szomsz=[szomsz;doors_possible_szomsz(j,:)];
                    if j~=size(doors_possible_szomsz,1)
                    non_szomsz=doors_possible_szomsz([1:j-1,j+1:end],:);
                    else 
                    non_szomsz=doors_possible_szomsz(1:j-1,:);
                    end
                    [szomsz,non_szomsz]=add_door_szomsz(doors_possible_szomsz(j,:),non_szomsz,N1,N2,szomsz);%recursion
                else
                    %nonszomsz=[nonszomsz;doors_possible_szomsz(j,:)];%
                    %check later because this looks a bit weird
                end
        end
    end
end

end