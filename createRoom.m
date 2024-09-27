%function createRoom(N1,N2)

%kell még
%1. add emberek

N1=10;
N2=10;

fig=uifigure("Name", "Make Room");
g1=uigridlayout(fig,[2,3]);
g1.RowHeight={'1x',30};
g1.ColumnWidth={'1x','1x','fit'};

floor_field=200*ones(N1,N2);
floor_field=padarray(floor_field,[1,1],500,'both');
uit = uitable(g1,"Data",floor_field,"ColumnWidth","fit","ColumnEditable",logical(ones(1,N2+2)));
btn=uibutton(g1,"Text","Save as: _AddText_.mat");
lbl=uilabel(g1,"Text","1:Door, 200:Empty, 500:Obstacle");
editfld=uieditfield(g1);

btn.Layout.Row=2;
btn.Layout.Column=1;
editfld.Layout.Row=2;
editfld.Layout.Column=2;
lbl.Layout.Row=2;
lbl.Layout.Column=3;
uit.Layout.Row=1;
uit.Layout.Column=[1 3];

yellowcell=uistyle("backgroundColor",[1 1 0]);
greycell=uistyle("backgroundColor",[.5 .5 .5]);
whitecell=uistyle("backgroundColor",[1 1 1]);
bluecell=uistyle("backgroundColor",[0  0 1]);


addStyle(uit,yellowcell,"cell",[findrc(floor_field,200)]);
addStyle(uit,greycell,"cell",findrc(floor_field,500));
addStyle(uit,whitecell,"cell",findrc(floor_field,1));

uit.DisplayDataChangedFcn=@(src,event) updateTable(src,uit,yellowcell,greycell,whitecell,bluecell);
btn.ButtonPushedFcn={@saveTable,editfld,uit,fig};
fig.CloseRequestFcn = @(src,event)my_closereq(src);


function updateTable(src,uit, yellowcell,greycell,whitecell,bluecell)
    t=src.DisplayData;

    addStyle(uit,yellowcell,"cell",findrc(t,200));
    addStyle(uit,greycell,"cell",findrc(t,500));
    findrc(t,200)
    addStyle(uit,whitecell,"cell",findrc(t,1));
    [invalidcells_r,invalidcells_c]=find(t~=1&t~=200&t~=500);
    addStyle(uit,bluecell,"cell",[invalidcells_r,invalidcells_c]);


end

function saveTable(src,event,editfld,uit,fig)
    floor_field=uit.DisplayData;
    %floor_field=mtx;
    if isempty(editfld.Value)
        uialert(fig,"The matrix can not be saved. Please Add a File Name!","No filename Added")
    else
        if sum(sum(floor_field==1|floor_field==200|floor_field==500))~=(size(floor_field,1)*size(floor_field,2))
            uialert(fig,"The matrix can not be saved. The matrix can only have values 1, 200, 500... see the blue values!","Wrong values")

        else 
            save(editfld.Value,'floor_field');
        end
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

%end