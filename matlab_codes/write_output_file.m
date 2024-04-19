function write_output_file(outfile_name, alpha, beta, force,flux_node, nodal_flux, ...
                  node_num,nodal_coord,element_id, element, left_BC,right_BC,...
                  eN, nodal_values, elem_fluxes, peak_data)

    nE = length(element_id);
    nN = length(node_num);
    nA = length(alpha);
    nB = length(beta);
    nF = length(force);
    nFx = length(nodal_flux);

    fid = fopen(outfile_name,'w');
    fprintf(fid, "***********************************************************\n");
    fprintf(fid, "    Analysis of One dimesnional Boundary Value Problem     \n");
    fprintf(fid, "         ... program written for CEE 526 FEM ...           \n");
    fprintf(fid, "                             > Dharanidharan Arumugam <    \n");
    fprintf(fid, "***********************************************************\n\n");
    
    fprintf(fid, "__________________________________________________________\n\n");
    fprintf(fid, "Part A: DETAILS OF THE 1DBVP FINITE ELEMENT MODEL           \n");
    fprintf(fid, "__________________________________________________________\n\n");
    fprintf(fid, "$ Model Summary    \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, " ->  Number of alpha groups   : %d\n", nA);
    fprintf(fid, " ->  Number of beta groups    : %d\n", nB);
    fprintf(fid, " ->  Number of force groups   : %d\n", nF);
    fprintf(fid, " ->  Number of nodal flux     : %d\n", nFx);
    fprintf(fid, " ->  Number of elements       : %d\n", nE);
    fprintf(fid, " ->  Number of nodes          : %d\n", nN);
    fprintf(fid, "\n\n\n");

    fprintf(fid, "$ Nodal coordinates \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, "  nodes   x_coordinate \n");
    fprintf(fid, "------------------------\n");
    fprintf(fid, "%5d %12.4f\n", [double(node_num) nodal_coord]');
    fprintf(fid, "\n\n\n");


    fprintf(fid, "$ Nodal Fluxes \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, "  nodes     flux \n");
    fprintf(fid, "------------------------\n");
    if ~isempty(nodal_flux)
    fprintf(fid, "%5d %12.4f\n", [double(flux_node) nodal_flux]');
    else
    fprintf(fid, "No nodal fluxes provided\n");
    end
    fprintf(fid, "\n\n\n");

    fprintf(fid, "$ Element properties \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, "  element      alpha       beta       force\n");
    fprintf(fid, "---------------------------------------------\n");
    for i = 1:nE
        No = element_id(i);
        alpha_grp = element(i,1);
        beta_grp = element(i,2);
        force_grp = element(i,3);
        a = alpha(alpha_grp);
        b = beta(beta_grp);
        f = force(force_grp);
        fprintf(fid,"%6d %12.4g %12.4g %12.4g\n",No,a,b,f);
    end
    fprintf(fid, "\n\n\n");

    fprintf(fid, "$ Element connectivity \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, "  element   connected nodes\n");
    fprintf(fid, "---------------------------------\n");
    for i = 1:nE
        No = element_id(i);
        if element(i,4)==1
            cnodes = node_num(element(i,[5,end]));
            fprintf(fid, "%5d      %4d %4d\n",No,cnodes);
        else 
            cnodes = node_num(element(i,5:end));
            fprintf(fid, "%5d      %4d %4d %4d\n",No,cnodes);
        end
    end
    fprintf(fid, "\n\n\n");

    fprintf(fid, "$ Boundary Conditions \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, "  node   condition      value1       value2\n");
    fprintf(fid, "--------------------------------------------\n");
    
    nodes =[1 nN];
    BCs =[left_BC;right_BC];
    for i = 1:2
        ty = BCs(i,1);
        if ty==1
            cond = 'essential';
            val = BCs(i,2);
            fprintf(fid,"%5d    %-12s %8.2f\n",nodes(i),cond,val);
        elseif ty==2
            cond = 'natural';
            val = BCs(i,3);
            fprintf(fid,"%5d    %-12s            %8.2f\n",nodes(i),cond,val);
        else
            cond = 'mixed';
            val = BCs(i,2:3);
            fprintf(fid,"%5d    %-12s %8.2f      %8.2f\n",nodes(i),cond,val);
        end
    end
    fprintf(fid, "\n\n");
    fprintf(fid, "__________________________________________________________\n\n");
    fprintf(fid, "Part B: ANALYSIS OUTPUTS          \n");
    fprintf(fid, "__________________________________________________________\n\n");

    fprintf(fid, "$ Solver Performance   \n");
    fprintf(fid, "--------------------------------\n\n");
    fprintf(fid,'-> Absolute Error Norm : %4.4g\n',eN(1));
    fprintf(fid,'-> Relative Error Norm : %4.4g\n\n',eN(2));
    fprintf(fid, "\n\n\n");

    fprintf(fid, "$ Nodal Unknown Values \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, "  nodes    location     value\n");
    fprintf(fid, "---------------------------------\n");
    fprintf(fid, "%5d %12.4f %12.4g\n", nodal_values');
    fprintf(fid, "\n\n\n");

    fprintf(fid, "$ Nodal Flux Values \n");
    fprintf(fid, "---------------------------\n\n");
    fprintf(fid, "  element  node  location      flux\n");
    fprintf(fid, "---------------------------------------\n");
    nRows = size(elem_fluxes,1);
    elem_old = 0;
    for i=1:nRows
        elem = elem_fluxes(i,1);
        if elem~=elem_old
            fprintf(fid, "\n");
            fprintf(fid, " %5d  %5d %10.4f  %12.4f\n", elem_fluxes(i,:));
        else
            fprintf(fid, "        %5d %10.4f  %12.4f\n", elem_fluxes(i,2:end));
        end
        elem_old=elem;
    end
    fprintf(fid, "\n\n\n");

    y_min = peak_data.nodal_values(1,:);
    y_max = peak_data.nodal_values(2,:);
    t_min = peak_data.elem_fluxes(1,:);
    t_max = peak_data.elem_fluxes(2,:);
    fprintf(fid, "$ Peak values    \n");
    fprintf(fid, "--------------------------------\n\n");
    fprintf(fid, "# Nodal unknowns    \n");
    fprintf(fid,'   -> Minimum value : %8.4g at location: %0.4f \n',y_min(1),y_min(2));
    fprintf(fid,'   -> Maximum value : %8.4g at location: %0.4f \n\n',y_max(1),y_max(2));
    fprintf(fid, "# Element Fluxes    \n");
    fprintf(fid,'   -> Minimum value : %8.4g at location: %0.4f \n',t_min(1),t_min(2));
    fprintf(fid,'   -> Maximum value : %8.4g at location: %0.4f \n',t_max(1),t_max(2));
    fprintf(fid, "\n\n");
    fprintf(fid, "______________________End of the file____________________\n\n");
    fclose(fid);

end