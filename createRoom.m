%function createRoom(N1,N2)

%kell még
%1. add emberek

N1=10;
N2=10;

fig=uifigure("Name", "Make Room");
g1=uigridlayout(fig,[3,3]);
g1.RowHeight={'1x',35,35};
g1.ColumnWidth={'1x','1x','fit'};

floor_field=200*ones(N1,N2);
floor_field=padarray(floor_field,[1,1],500,'both');
uit = uitable(g1,"Data",floor_field,"ColumnWidth","fit","ColumnEditable",logical(ones(1,N2+2)));

btn=uibutton(g1,"Text",["Save as: _AddText_.mat","_AddText_ppl.mat"],"Tooltip", "If no persons are placed, it does not save an empty mtx, by the logic that in this case, one would probably use random distribution of persons");
lbl=uilabel(g1,"Text",["1:Door,2: Person,", "200:Empty, 500:Obstacle"]);
editfld=uieditfield(g1);

btn2=uibutton(g1,"Text",["Generate _AddNumber_ of"," randomly distributed people"],"Tooltip","Többszöri klikk esetén a korábbi emberek eltünnek, így érdemes elösször random generálni, majd hozzáadni embereket a táblázat értékeinek megváltoztatásásval... mivel fordított sorrendben ez nem lehetséges");
lbl2=uilabel(g1,"Text"," ");
editfld2=uieditfield(g1);

btn.Layout.Row=3;
btn.Layout.Column=2;
editfld.Layout.Row=3;
editfld.Layout.Column=3;
lbl.Layout.Row=3;
lbl.Layout.Column=1;

btn2.Layout.Row=2;
btn2.Layout.Column=2;
editfld2.Layout.Row=2;
editfld2.Layout.Column=3;
lbl2.Layout.Row=2;
lbl2.Layout.Column=1;




uit.Layout.Row=1;
uit.Layout.Column=[1 3];

yellowcell=uistyle("backgroundColor",[1 1 0]);
greycell=uistyle("backgroundColor",[.5 .5 .5]);
whitecell=uistyle("backgroundColor",[1 1 1]);
bluecell=uistyle("backgroundColor",[0  0 1]);
orangecell=uistyle("backgroundColor",[1  0.5 0]);



addStyle(uit,yellowcell,"cell",[findrc(floor_field,200)]);
addStyle(uit,greycell,"cell",findrc(floor_field,500));
addStyle(uit,whitecell,"cell",findrc(floor_field,1));
addStyle(uit,orangecell,"cell",findrc(floor_field,1));


uit.DisplayDataChangedFcn=@(src,event) updateTable(src,uit,yellowcell,greycell,whitecell,bluecell,orangecell);
btn.ButtonPushedFcn={@saveTable,editfld,uit,fig};
fig.CloseRequestFcn = @(src,event)my_closereq(src);
%ennél biztos lehetne szebben....
btn2.ButtonPushedFcn={@GeneratePeople,editfld2,uit,fig,yellowcell,greycell,whitecell,bluecell,orangecell};


function updateTable(src,uit,yellowcell,greycell,whitecell,bluecell,orangecell)
    t=src.DisplayData;
    
    addColors(uit,t,yellowcell,greycell,whitecell,bluecell,orangecell)


end

function saveTable(src,event,editfld,uit,fig)
    floor_field=uit.DisplayData;
    %floor_field=mtx;
    if isempty(editfld.Value)
        uialert(fig,"The matrix can not be saved. Please Add a File Name!","No filename Added")
    else
        if sum(sum(floor_field==1|floor_field==200|floor_field==500|floor_field==2))~=(size(floor_field,1)*size(floor_field,2))
            uialert(fig,"The matrix can not be saved. The matrix can only have values 1,2, 200, 500... see the blue values!","Wrong values")

        else 
            if sum(sum(floor_field==2))==0
                save(editfld.Value,'floor_field'); %we save the people independently
            else 
                ppl=(floor_field==2);
                floor_field(ppl)=500;
                save(editfld.Value,'floor_field'); %we save the people independently
                save(strcat(editfld.Value,"_ppl"),'ppl')
            end
        end
    end

end

function GeneratePeople(src,event,editfld2,uit,fig,yellowcell,greycell,whitecell,bluecell,orangecell)
    num_of_ppl=str2num(editfld2.Value);

    floor_field=uit.DisplayData;
    floor_field(floor_field==2)=200;%ha már volt ember, eltünnek
    temp=(floor_field==500);%& floor_field==1 %ajtóba is kerülhet ember... mert miért ne
    %floor_field=mtx;
    if isempty(num_of_ppl)
        uialert(fig,"The given input is not just one number!","Please write only a number.")
    elseif num_of_ppl>sum(sum(temp))
        uialert(fig,"More ppl are given as there are empty cells!","Please change the input.")
    elseif sum(sum(floor_field==1|floor_field==200|floor_field==500|floor_field==2))~=(size(floor_field,1)*size(floor_field,2))
        uialert(fig,"The cannot be generated. The matrix can only have values 1,2, 200, 500... see the blue values!","Wrong values")
    else
        %személyek random: egyenletes eloszlásba személyek kezdeti helyei (lineáris indexeléssel)
        not_obj_indices=find(temp==0);                               %indexek ahol nincs tárgy se fal, find lassú...
        rand_indices=(randperm(size(not_obj_indices,1),num_of_ppl))'; %ebbõl random 'num_of_ppl' darab index(ahova majd kezdetben személy kerül)
        not_obj_indices=not_obj_indices(rand_indices);                %személyek kezdeti (lineáris) indexei
        floor_field(not_obj_indices)=2;
        %change table
        uit.Data=floor_field;
        addColors(uit,uit.Data,yellowcell,greycell,whitecell,bluecell,orangecell)
    end

   
end

function my_closereq(fig)
    selection = uiconfirm(fig,'Close the figure window?',...
        'Confirmation');
    
    switch selection
        case 'OK'
            delete(fig)
        case 'Cancel'
            return
    end
    end

function rc=findrc(mtx,val)
    [r,c]=find(mtx==val);
    rc=cat(2,r,c);
end

function addColors(uit,t,yellowcell,greycell,whitecell,bluecell,orangecell)
    addStyle(uit,yellowcell,"cell",findrc(t,200));
    addStyle(uit,greycell,"cell",findrc(t,500));
    addStyle(uit,whitecell,"cell",findrc(t,1));
    addStyle(uit,orangecell,"cell",findrc(t,2));

    [invalidcells_r,invalidcells_c]=find(t~=1&t~=200&t~=500&t~=2);
    addStyle(uit,bluecell,"cell",[invalidcells_r,invalidcells_c]);
end

%end