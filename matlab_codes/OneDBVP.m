clc, clear all

inpfile_name = input ('Enter input file name: ', 's');
outfile_name = input('Enter output file name: ', 's');

%% Check the availability of the input and output file

% Open the input file
[fileI, msg] = fopen(inpfile_name, 'r');
if fileI < 0
    fprintf ('failed to open %s because %s\n', inpfile_name, msg);
    return;
end
fprintf("The file path for the input is valid\n")

% open output file
[fileO, msg] = fopen(outfile_name,'w');
if fileO < 0
    fprintf ('failed to open %s because %s\n', outfile_name, msg);
    return;
end
fclose (fileO);
fprintf("The file path for the output is valid\n")

fprintf("Reading the input file...\n")

% open error file
[inpPath,inpNm,inpExt] = fileparts(inpfile_name);
errorfile_name = strcat(inpPath,"/error_file_of_",inpNm,inpExt);
[fileE, ~] = fopen(errorfile_name,'w');
fprintf(fileE, "%s \n",errorfile_name);
fprintf(fileE, "***********************************************************\n\n");
fprintf(fileE, "# Individual Errors           \n");
fprintf(fileE, "------------------------------\n\n");

%% Reading input file
problem_head = "Not provided";
line_num   = 0;
nA      = uint16(0); 
nB      = uint16(0);
nF      = uint16(0); 
nFx     = uint16(0); 
nN      = uint16(0);
nE      = uint16(0);
nLBC    = uint16(0);
nRBC    = uint16(0);
total_errors = uint16(0);
block_checks = uint16(zeros(10,1));

alpha       = zeros(20,1);
alpha_id    = uint16(zeros(20,1));
beta        = zeros(20,1);
beta_id     = uint16(zeros(20,1));
force       = zeros(20,1);
force_id    = uint16(zeros(20,1));
nodal_flux  = zeros(20,1);
flux_node   = uint16(zeros(20,1));
nodal_coord = ones(513,1)*-1;
node_num    = uint16(zeros(513,1));
element     = uint16(zeros(256,7));
element_id  = uint16(zeros(256,1));


while ~feof(fileI)

    line_num = line_num + 1;
    line_text = strtrim(fgetl (fileI));

    %% Ignore the comment line and count the number of comment lines
    if (strcmp(line_text(1:2), '**'))
        continue
    elseif strcmp(line_text(1), '*')
        block_name = line_text(2:end);
        if strcmp(block_name,'end')
          block_checks(10) = 1;
        end
        continue
    end

    %% reading block data
    switch block_name
        case 'feat1D'
        case 'heading'
            problem_head = line_text;
        case 'alpha'
            [id, val, num_error] = process_properties_blocks(fileE,line_text, line_num);
            total_errors = total_errors + num_error;
            if ~isempty(val)
                if ismember(id,alpha_id)
                    msg = strcat("duplicate alpha id found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                elseif isnan(val)
                    msg = strcat("Nan value found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                else
                    nA = nA + 1;
                    alpha(nA) = val;
                    alpha_id(nA) = id;
                end
            end
            block_checks(2) = 1;
        case 'beta'
            [id, val, num_error] = process_properties_blocks(fileE,line_text, line_num);
            total_errors = total_errors + num_error;
            if ~isempty(val)
                if ismember(id,beta_id)
                    msg = strcat("duplicate beta id found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                else
                    nB = nB + 1;
                    beta(nB) = val;
                    beta_id(nB) = id;
                end
            end
            block_checks(3) = 1;
        case 'force'
            [id, val, num_error] = process_properties_blocks(fileE,line_text, line_num);
            total_errors = total_errors + num_error;
            if ~isempty(val)
                if ismember(id,force_id)
                    msg = strcat("duplicate force id found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                elseif isnan(val)
                    msg = strcat("Nan value found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                else
                    nF = nF + 1;
                    force(nF) = val;
                    force_id(nF) = id;
                end
            end
            block_checks(4) = 1;
        case 'nodal coordinate'  
            [id, val, num_error] = process_properties_blocks(fileE,line_text, line_num);
            total_errors = total_errors + num_error;
            if ~isempty(val)
                if ismember(id,node_num)
                    msg = strcat("duplicate node number found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                elseif ismember(val,nodal_coord)
                    msg = strcat("duplicate nodal coord found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                elseif isnan(val)
                    msg = strcat("Nan value found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                else
                    nN = nN + 1;
                    nodal_coord(nN) = val;
                    node_num(nN) = id;
                end
            end
            block_checks(5) = 1;
        case 'nodal flux'
            [id, val, num_error] = process_properties_blocks(fileE,line_text, line_num);
            total_errors = total_errors + num_error;
            if ~isempty(val)
                if ismember(id,flux_node)
                    msg = strcat("duplicate flux_node found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                elseif isnan(val)
                    msg = strcat("Nan value found");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                else
                    nFx = nFx + 1;
                    nodal_flux(nFx) = val;
                    flux_node(nFx) = id;
                end
            end
            block_checks(6) = 1;
        case 'element data'
            line_text = convertCharsToStrings(line_text);
            vals  = strsplit(line_text, ',');
            nVals = length(vals);
            if ismember(nVals,[7,8])
                el_type = strtrim(vals(5));
                if el_type == "1DC0L" && nVals==7
                    vals(5) = "1";
                elseif el_type == "1DC0Q" && nVals==8
                    vals(5) = "2";
                else
                    msg = strcat("invalid element type");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                    continue
                end
                try
                    data = int16(str2double(vals));
                    nE = nE + 1;
                    id = uint16(data(1));
                    if ismember(id,element_id)
                        msg = strcat("duplicate element id found");
                        error = raise_error(fileE, msg, line_num);
                        total_errors = total_errors + error;
                    elseif sum(isnan(data))
                        msg = strcat("Nan value found");
                        error = raise_error(fileE, msg, line_num);
                        total_errors = total_errors + error;
                    else
                        element_id(nE) = id;
                        if nVals==7
                            element(nE,[1:5,7]) = data(2:end);
                        else
                            element(nE,:) = data(2:end);
                        end
                    end
                catch
                    msg = strcat("invalid data type");
                    error = raise_error(fileE, msg, line_num);
                    total_errors = total_errors + error;
                    continue
                end
            else
                msg = strcat("incomplete or invalid data");
                error = raise_error(fileE, msg, line_num);
                total_errors = total_errors + error;
            end
            block_checks(7) = 1;
        case "left end BC"  
            [bound_vals,error] = process_BC_blocks(fileE, line_text, line_num);
            total_errors = total_errors + error;
            if ~isempty(bound_vals)
                nLBC = nLBC + 1;
                if nLBC > 1
                   msg = strcat("too many left boundary conditions");
                   error = raise_error(fileE, msg, line_num);
                   total_errors = total_errors + error;
                end
                left_BC = bound_vals;
            end
            block_checks(8) = 1;
        case "right end BC"  
            [bound_vals,error] = process_BC_blocks(fileE, line_text, line_num);
            total_errors = total_errors + error;
            if ~isempty(bound_vals)
                nRBC = nRBC + 1;
                if nRBC > 1
                   msg = strcat("too many right boundary conditions");
                   error = raise_error(fileE, msg, line_num);
                   total_errors = total_errors + error;
                end
                right_BC = bound_vals;
            end
            block_checks(9) = 1;
        otherwise
            msg = 'unrecognized block name';
            error = raise_error(fileE, msg, line_num);   
    end
end

block_names = ['heading', 'alpha', 'beta', 'force', 'nodal coordinate',...
                'nodal flux', 'element data','left end BC', 'right end BC', 'end'];
fprintf(fileE, "\n\n");
fprintf(fileE, "# Missing Block errors:         \n");
fprintf(fileE, "------------------------------\n\n");

for i = [2:5,7:9]
   
    if block_checks(i)==0
       msg = strcat("No information available for ", block_names(i), " block");
       error = raise_error(fileE, msg, 0);
       total_errors = total_errors + error;
    end
end

if block_checks(10)==0
    msg = strcat("'*end' statement misssing ");
    error = raise_error(fileE, msg, 0);
    total_errors = total_errors + error;
end

%% Ill posed problem check
fprintf(fileE, "\n\n");
fprintf(fileE, "# Boundary conditions check:       \n");
fprintf(fileE, "------------------------------\n\n");

if left_BC(1) == 1
   if left_BC(3) ~= 0
       msg = "Left BC: for EBC, value 2 must be zero";
       error = raise_error(fileE, msg, 0);
       total_errors = total_errors + 1;  
   end
elseif left_BC(1)==2
   if left_BC(2) ~=0
       msg = "Left BC: for NBC value 1 must be zero";
       error = raise_error(fileE, msg, 0);
       total_errors = total_errors + 1; 
   end
end

if right_BC(1) == 1
   if right_BC(3) ~= 0
       msg = "Right BC: for EBC, value 2 must be zero";
       error = raise_error(fileE, msg, 0);
       total_errors = total_errors + 1; 
   end
elseif right_BC(1) == 2
   if right_BC(2) ~= 0
       msg = "Right BC: for NBC, value 1 must be zero";
       error = raise_error(fileE, msg, 0);
       total_errors = total_errors + 1;  
   end
end

if (left_BC(1)==2 && right_BC(2)==2)
    msg = "The problem is ill_posed"; 
    fprintf("%s\n", msg)
    error = raise_error(fileE, msg, 0);
    total_errors = total_errors + 1;
end

fprintf(fileE, "\n\n");
fprintf(fileE, "# Error summary \n");
fprintf(fileE, "------------------------------\n\n");
msg = strcat(num2str(total_errors)," total_errors in the input file");
[~] = raise_error(fileE, msg, 0);

if total_errors > 0
   fprintf("%s\n",msg);
   msg = strcat("Details of the error is written in file name: ",errorfile_name);
   fprintf("%s\n",msg);
   fprintf("program has been terminated\n")
   return
end

%% Resizing the arrays
if nA < 20 
    alpha(nA+1:end)=[];
    alpha_id(nA+1:end)=[];
end
if nB < 20
    beta(nB+1:end) = [];
    beta_id(nB+1:end) = [];
end
if nF < 20
    force(nF+1:end) = [];     
    force_id(nF+1:end) = [];  
end
if nFx < 20
    nodal_flux(nFx+1:end) = [];
    flux_node(nFx+1:end)  = [];
end
if nN < 513
    nodal_coord(nN+1:end) = [];
    node_num(nN+1:end) = [];
end
if nE < 256
    element(nE+1:end,:) = [];
    element_id(nE+1:end,:)  = [];
end
fprintf("The input file has been read successfully\n")
fprintf("Checking for the input validity...\n")

%% Renumbering the input data

% Renumbering alpha id
seq_id=[];
seq = is_sequential(alpha_id);
if ~seq
    seq_id(:,1) = uint16(1:nA);
    element(:,1) = map_arrays(element(:,1),alpha_id,seq_id);
end

seq_id=[];
seq = is_sequential(beta_id);
if ~seq
    seq_id(:,1) = uint16(1:nB);
    element(:,2) = map_arrays(element(:,2),beta_id,seq_id);
end

seq_id=[];
seq = is_sequential(force_id);
if ~seq
    seq_id(:,1) = uint16(1:nF);
    element(:,3) = map_arrays(element(:,3),force_id,seq_id);
end

seq_id=[];
[nodal_coord, ind] = sort(nodal_coord,'ascend');
node_num = node_num(ind);
seq = is_sequential(node_num);
seq_flux_node = flux_node;
if ~seq
    seq_id(:,1) = uint16(1:nN)';
    element(:,5:end) = map_arrays(element(:,5:end),node_num,seq_id);
    seq_flux_node = map_arrays(flux_node,node_num,seq_id);
end

%% Input validity checks


% check the flux nodes available
fprintf(fileE, "\n\n");
fprintf(fileE, "# check the flux nodes available\n");
fprintf(fileE, "------------------------------\n\n");
total_errors = 0;
if ~prod(ismember(flux_node,node_num))
    msg = strcat("specified flux nodes not available");
    error = raise_error(fileE, msg, 0);
    total_errors = total_errors + error;
end

% check incosistent sequential node connectivity
fprintf(fileE, "\n\n");
fprintf(fileE, "# check incosistent sequential node connectivity\n");
fprintf(fileE, "------------------------------\n\n");
[~, ind] = sort(element(:,5),'ascend');
element_id = element_id(ind);
element = element(ind,:);

for i = 1:nE
  diff = (element(i,7)-element(i,5))/element(i,4);
  id = num2str(element_id(i));
  if diff ~= 1  
    msg = strcat("Incosistent node connectivity in element: ",id);
    error = raise_error(fileE, msg, 0);
    total_errors = total_errors + error;
  end
  if element(i,4) == 2
    diff = element(i,7)-element(i,6);
    id = num2str(element_id(i));
    if diff ~= 1  
        msg = strcat("Incosistent node connectivity in element: ",id);
        error = raise_error(fileE, msg, 0);
        total_errors = total_errors + error;
    end
  end
  if i>1
      end_node = element(i-1,end);
      start_node = element(i,5);
      diff = end_node-start_node;
      if diff ~= 0  
          msg = strcat("Elements are not connected at node ", num2str(end_node));
            error = raise_error(fileE, msg, 0);
            total_errors = total_errors + error;
      end
  end
  
  a_id = element(i,1);
  if a_id==0 
      msg = strcat("No referred alpha available for element no: ",num2str(element_id(i)));
      error = raise_error(fileE, msg, 0);
      total_errors = total_errors + error;
  end

  b_id = element(i,2);
  if b_id==0 
      msg = strcat("No referred beta available for element no: ", num2str(element_id(i)));
      error = raise_error(fileE, msg, 0);
      total_errors = total_errors + error;
  end

  f_id = element(i,3);
  if f_id==0 
      msg = strcat("No referred force available for element no: ", num2str(element_id(i)));
      error = raise_error(fileE, msg, 0);
      total_errors = total_errors + error;
  end

  for j = 5:7
      if (j==6 && element(i,4)==1)
         continue
      end
      nd_id = element(i,j);
      if nd_id==0
            msg = strcat("No referred node available for element no: ", num2str(element_id(i)));
            error = raise_error(fileE, msg, 0);
            total_errors = total_errors + error;
      end
  end
end


fprintf(fileE, "\n\n");
fprintf(fileE, "# Error summary \n");
fprintf(fileE, "------------------------------\n\n");
msg = strcat(num2str(total_errors)," total_errors in the input file");
[~] = raise_error(fileE, msg, 0);

if total_errors > 0
   fprintf("%s\n",msg);
   msg = strcat("Details of the error is written in file name: ",errorfile_name);
   fprintf("%s\n",msg);
   fprintf("program has been terminated\n")
   return
end
fclose (fileE);% close error file
fclose (fileI); % close input file
fprintf("The input file has been read successfully verified for the input validity\n")
fprintf("Checking for the input validity...\n")

%% analysing the problem

% removing the middle column if no quadrilateral element exists
if sum(element(:,6)) == 0
   element(:,6) = [];
end

fprintf("assembling the halfband system stiffness matrix...\n")

[K,F] = system_assembly(alpha,beta,force,seq_flux_node,nodal_flux,nodal_coord,element);

fprintf("system stiffness matrix has been assembled\n")

fprintf("applying boundary conditions...\n")

[K,F] = apply_bound_condns(K,F,left_BC,right_BC);

fprintf("boundary conditions are applied/n")

fprintf("solving the system using cholesky decomposition for halfband stiffness matrix...\n")

D = system_solver(K,F);
if isempty(K), return; end

fprintf("Primary unknowns are found\n")

% computing error norms
eN = compute_error_norms(K,F,D); 

fprintf("calculating element fluxes...\n")

[nodal_values, elem_fluxes] = find_nodal_values(D,alpha,node_num,nodal_coord,...
                                                  element_id,element,left_BC,right_BC);

fprintf("element fluxes are calculated\n")

% finding maximum and minimum nodal and flux values
peak_data = find_peak_values(nodal_values(:,2:3), elem_fluxes(:,3:4)); % computing e

fprintf("writing the output...\n")

write_output_file(outfile_name, alpha, beta, force,flux_node,nodal_flux, ...
                  node_num,nodal_coord,element_id, element, left_BC,right_BC,...
                  eN, nodal_values, elem_fluxes, peak_data);

msg = strcat("Outputs are successfully written in the file: ",outfile_name);
fprintf("%s\n",msg);
fprintf("program has ended\n");


%% funcitonal blocks
function [grp_id,prop_val,num_error] = process_properties_blocks(fID, line_text, line_num)
     num_error = 0;
     prop_val = [];
     grp_id = [];
     try
        data = str2num(line_text);
        if length(data) ~= 2
            msg = strcat("incomplete or invalid data");
            error = raise_error(fID, msg, line_num);
            num_error = num_error + error;
        else
            grp_id = data(1);
            prop_val = data(2);
        end
     catch
        msg = strcat("invalid data");
        error = raise_error(fID,msg, line_num);
        num_error = num_error + error;
     end
end

%% funcitonal block
function [bound_vals,error] = process_BC_blocks(fID,line_text, line_num)
    error = 0;
    bound_vals = [];
    line_text = convertCharsToStrings(line_text);
    vals  = strsplit(line_text, ',');
    nVals = length(vals);
    bc_type = strtrim(vals(1));
    if nVals == 3 
        if bc_type == "EBC"
            vals(1) = "1";
        elseif bc_type == "NBC"
            vals(1) = "2";
        elseif bc_type == "MBC"
            vals(1) = "3";
        else
            msg = strcat("invalid boundary condition type");
            error = raise_error(fID, msg, line_num);
        end
        try
            bound_vals = str2double(vals);
            if sum(isnan(bound_vals))
               msg = strcat("Nan value found");
               error = raise_error(fID, msg, line_num);
            end
        catch
            msg = strcat("invalid data type");
            error = raise_error(fID, msg, line_num);
        end
    else
        msg = strcat("incomplete or invalid data");
        error = raise_error(fID, msg, line_num);
    end
end

%% functional
function error = raise_error(fID,message, linenumber)
    if (linenumber > 0)
        fprintf (fID," -> %s at line number : %d\n", message, linenumber);
    else
        fprintf (fID," -> %s\n", message);
    end
    error = 1;
end

function sequential = is_sequential(vector)
    if size(vector,2)==1
        vector = vector';
    end
    seq_id = uint16(1:length(vector));
    diff = sum(abs(vector-seq_id));
    if diff==0, sequential=1; else, sequential=0; end
end

function out_array = map_arrays(in_array,old_vals,new_vals)
    N = length(old_vals);
    out_array = zeros(size(in_array));
    for i = 1:N
        oval = old_vals(i);
        nval = new_vals(i);
        out_array(in_array==oval)=nval;
    end
end
