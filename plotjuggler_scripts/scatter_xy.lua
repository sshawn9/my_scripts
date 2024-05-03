--- https://slides.com/davidefaconti/plotjuggler-reactive-scripts
--- https://github.com/facontidavide/PlotJuggler/blob/main/plotjuggler_base/include/PlotJuggler/reactive_function.h
--- https://github.com/facontidavide/PlotJuggler/blob/main/plotjuggler_base/src/reactive_function.cpp

--- NOTE: ros_version is a global variable that must be set before calling this script
ros_version = 0

function print_series_names()
    local series_names = GetSeriesNames()
    for i, name in ipairs(GetSeriesNames()) do
        print("Series name " .. i .. ": " .. name)
    end
end

--- create series for scatter plot
function create_series(series, x_str, y_str, size_str, prefix)
    if (ros_version ~= 1 and ros_version ~= 2) then
        print("ros_version is not set correctly")
        return
    end

    series:clear()

    local size = nil
    if (size_str ~= nil) then
        if (prefix ~= nil) then
            size_str = string.format("%s/%s", prefix, size_str)
        end
        size = TimeseriesView.find(size_str):atTime(tracker_time)
    end

    local i = 0
    while (true) do
        if (size ~= nil and i >= size) then
            break
        end

        local name_x, name_y
        if (prefix == nil) then
            if (ros_version == 1) then
                name_x = string.format("%s.%d", x_str, i)
                name_y = string.format("%s.%d", y_str, i)
            else
                name_x = string.format("%s[%d]", x_str, i)
                name_y = string.format("%s[%d]", y_str, i)
            end
        else
            if (ros_version == 1) then
                name_x = string.format("%s/%s.%d", prefix, x_str, i)
                name_y = string.format("%s/%s.%d", prefix, y_str, i)
            else
                name_x = string.format("%s/%s[%d]", prefix, x_str, i)
                name_y = string.format("%s/%s[%d]", prefix, y_str, i)
            end
        end

        local series_x = TimeseriesView.find(name_x)
        if (series_x == nil) then
            print("series_x is nil")
            break
        end
        local x = series_x:atTime(tracker_time)
        if (x == nil) then
            print("x is nil")
            break
        end

        local series_y = TimeseriesView.find(name_y)
        if (series_y == nil) then
            print("series_y is nil")
            break
        end
        local y = series_y:atTime(tracker_time)
        if (y == nil) then
            print("y is nil")
            break
        end

        series:push_back(x, y)

        i = i + 1
    end
end

scatters = {}
function add_scatter(name, x_str, y_str, size_str, prefix)
    if (prefix ~= nil) then
        name = string.format("%s/%s", prefix, name)
    end
    name = string.format("Array/%s", name)

    scatters[name] = ScatterXY.new(name)
    create_series(scatters[name], x_str, y_str, size_str, prefix)
end

------------------------------------------------------------
--- My personal usage below
------------------------------------------------------------
function sphere_plot(prefix)
    --- A_calculate
    local N_str = "sphere/A_calculate/N/data"

    local sequence_s_str = "sphere/A_calculate/sequence_s/data"
    local sequence_t_str = "sphere/A_calculate/sequence_t/data"

    local optimal_x_str = "sphere/A_calculate/optimal_x/data"
    local optimal_y_str = "sphere/A_calculate/optimal_y/data"
    local xr_str = "sphere/A_calculate/xr/data"
    local yr_str = "sphere/A_calculate/yr/data"

    local optimal_he_str = "sphere/A_calculate/optimal_he/data"

    --- A_condition
    local hr_str = "sphere/A_condition/hr/data"
    local v2_max_str = "sphere/A_condition/v2_max/data"

    --- A_local_path
    local local_points_size_str = "sphere/A_local_path/points_size/data"

    local local_distances_str = "sphere/A_local_path/distances/data"
    local local_segments_str = "sphere/A_local_path/segments/data"

    local local_x_str = "sphere/A_local_path/x/data"
    local local_y_str = "sphere/A_local_path/y/data"
    local local_curvatures_str = "sphere/A_local_path/curvatures/data"
    local local_h_separations_str = "sphere/A_local_path/h_separations/data"
    local local_headings_str = "sphere/A_local_path/headings/data"
    
    local local_origin_points_size_str = "sphere/A_local_path/origin_points_size/data"

    local local_origin_e_str = "sphere/A_local_path/origin_e/data"
    local local_origin_n_str = "sphere/A_local_path/origin_n/data"
    local local_origin_u_str = "sphere/A_local_path/origin_u/data"
    local local_origin_x_str = "sphere/A_local_path/origin_x/data"
    local local_origin_y_str = "sphere/A_local_path/origin_y/data"

    --- A_record
    local optimal_k_str = "sphere/A_record/optimal_k/data"
    local optimal_h_str = "sphere/A_record/optimal_h/data"
    local optimal_d_str = "sphere/A_record/optimal_d/data"
    local optimal_kv_str = "sphere/A_record/optimal_kv/data"
    local optimal_ka_str = "sphere/A_record/optimal_ka/data"
    local optimal_v2_str = "sphere/A_record/optimal_v2/data"
    local optimal_v_str = "sphere/A_record/optimal_v/data"
    local optimal_a_str = "sphere/A_record/optimal_a/data"
    local optimal_j_str = "sphere/A_record/optimal_j/data"

    --- sphere
    local lp_lat_str = "sphere/LocalPath_points_lat/data"
    local lp_lon_str = "sphere/LocalPath_points_lon/data"
    local lp_alt_str = "sphere/LocalPath_points_alt/data"

    --- path plot
    add_scatter("solver_xy_reference", xr_str, yr_str, N_str, prefix)
    add_scatter("solver_optimal_xy", optimal_x_str, optimal_y_str, N_str, prefix)

    add_scatter("local_xy", local_x_str, local_y_str, local_points_size_str, prefix)
    add_scatter("local_origin_xy", local_origin_x_str, local_origin_y_str, local_origin_points_size_str, prefix)
    
    add_scatter("local_curvatures_distances", local_distances_str, local_curvatures_str, local_points_size_str, prefix)
    add_scatter("local_headings_distances", local_distances_str, local_headings_str, local_points_size_str, prefix)
    add_scatter("local_h_separations_distances", local_distances_str, local_h_separations_str, local_points_size_str, prefix)

    add_scatter("local_origin_en", local_origin_e_str, local_origin_n_str, local_origin_points_size_str, prefix)
    add_scatter("local_origin_xy", local_origin_x_str, local_origin_y_str, local_origin_points_size_str, prefix)

    --- solve plot
    add_scatter("solver_optimal_d_s", sequence_s_str, optimal_d_str, N_str, prefix)
    add_scatter("solver_optimal_he_s", sequence_s_str, optimal_he_str, N_str, prefix)
    add_scatter("solver_optimal_h_s", sequence_s_str, optimal_h_str, N_str, prefix)
    add_scatter("solver_hr_s", sequence_s_str, hr_str, N_str, prefix)

    add_scatter("solver_optimal_k_s", sequence_s_str, optimal_k_str, N_str, prefix)
    add_scatter("solver_optimal_kv_s", sequence_s_str, optimal_kv_str, N_str, prefix)
    add_scatter("solver_optimal_ka_s", sequence_s_str, optimal_ka_str, N_str, prefix)
    add_scatter("solver_optimal_v2_s", sequence_s_str, optimal_v2_str, N_str, prefix)
    add_scatter("solver_optimal_v_s", sequence_s_str, optimal_v_str, N_str, prefix)
    add_scatter("solver_optimal_a_s", sequence_s_str, optimal_a_str, N_str, prefix)
    add_scatter("solver_optimal_j_s", sequence_s_str, optimal_j_str, N_str, prefix)

    add_scatter("condition_v2_max_s", sequence_s_str, v2_max_str, N_str, prefix)

    add_scatter("lp_lat_lon", lp_lat_str, lp_lon_str, local_origin_points_size_str, prefix)
end
