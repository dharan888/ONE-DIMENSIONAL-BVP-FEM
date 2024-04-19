function peak_data = find_peak_values(nodal_values, elem_fluxes)
        peak_data.nodal_values = compute_peaks(nodal_values);
        peak_data.elem_fluxes = compute_peaks(elem_fluxes);
end

function peak_vals = compute_peaks(vals)
    [min_val, min_loc] = min(vals(:,2));
    min_loc = vals(min_loc,1);
    [max_val, max_loc] = max(vals(:,2));
    max_loc = vals(max_loc,1);
    peak_vals = [min_val min_loc;max_val max_loc];
end