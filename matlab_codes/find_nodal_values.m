function [nodal_values, elem_fluxes] = find_nodal_values(D,alpha,node_num, nodal_coord,...
                                                        element_id,element,left_BC,right_BC)

%% build complete nodal unknown values matrix
    nE = size(element,1);
    w = size(element,2)-4;
    if left_BC(1)==1, D = [left_BC(2);D]; end
    if right_BC(1)==1, D = [D;right_BC(2)]; end
    nodal_values(:,1) = double(node_num);
    nodal_values(:,2) = nodal_coord;
    nodal_values(:,3) = D;

%% compute fluxes and build flux matrix
    elem_fluxes = zeros(nE*w,4);
    m=1;
    for i = 1:nE
        elem_type   = element(i,4);
        elem_no     = element_id(i);
        if elem_type ==1
            nodes   = element(i,[5,end])';
        else
            nodes   = element(i,5:end)';
        end
        coords      = nodal_coord(nodes);
        a_grp       = element(i,1);
        a           = alpha(a_grp);
        y_vals      = D(nodes);
        fluxes      = compute_fluxes(elem_type,a,coords,y_vals);
        n           = length(fluxes);
        elem_fluxes(m:m+n-1,1)      = double(elem_no);
        elem_fluxes(m:m+n-1,2:end)  = [double(nodes),coords,fluxes];
        m = m+n;
    end
    nRows = nE*w;
    if (m-1) < nRows
        elem_fluxes(m:nRows,:) = [];
    end
    
end

function fluxes = compute_fluxes(elem_type,alpha,coords,y_vals)
    if elem_type==1
        L = coords(end)-coords(1);
        y1 = y_vals(1); y2=y_vals(2);
        fluxes(1:2,1) = -(alpha/L)*(y2-y1);
    else
        L = coords(end)-coords(1);
        x1 = coords(1); x2=coords(2); x3=coords(3);
        y1 = y_vals(1); y2=y_vals(2); y3=y_vals(3);
        k = (-alpha/L^2);
        c = k*(x1*(4*y2-2*y3)-2*x2*(y1+y3)-2*x3*(y1-2*y2));
        m = k*(4*y1-8*y2+4*y3);
        fluxes = m*coords + c ;
    end
end