--- create series from array data
function CreateSeriesWithoutSuffix(new_series, prefix_X, prefix_Y, timestamp)
    new_series:clear()
    local index = 0
    while true do
        local series_x = TimeseriesView.find(string.format("%s.%d", prefix_X, index))
        if series_x == nil then break end
        local x = series_x:atTime(timestamp)
        local series_y = TimeseriesView.find(string.format("%s.%d", prefix_Y, index))
        if series_y == nil then break end
        local y = series_y:atTime(timestamp)
        new_series:push_back(x,y)
        index = index + 1
    end
end

function CreateSeriesWithSize(new_series, prefix_X, prefix_Y, timestamp, size_string)
    new_series:clear()
    local index = 0
    local size = TimeseriesView.find(string.format("%s", size_string)):atTime(timestamp)
    while index < size do
        local series_x = TimeseriesView.find(string.format("%s.%d", prefix_X, index))
        if series_x == nil then break end
        local x = series_x:atTime(timestamp)
        local series_y = TimeseriesView.find(string.format("%s.%d", prefix_Y, index))
        if series_y == nil then break end
        local y = series_y:atTime(timestamp)
        new_series:push_back(x,y)
        index = index + 1
    end
end

a_ctrl_ca_hr_s = ScatterXY.new("a_ctrl_ca_hr_s")
CreateSeriesWithSize(a_ctrl_ca_hr_s, "a_ctrl_ca_optimal_s/data", "a_ctrl_ca_hr/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_vr_s = ScatterXY.new("a_ctrl_ca_vr_s")
CreateSeriesWithSize(a_ctrl_ca_vr_s, "a_ctrl_ca_optimal_s/data", "a_ctrl_ca_vr/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_k_s = ScatterXY.new("a_ctrl_ca_k_s")
CreateSeriesWithSize(a_ctrl_ca_k_s, "a_ctrl_ca_optimal_s/data", "a_ctrl_ca_optimal_k/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_h_s = ScatterXY.new("a_ctrl_ca_h_s")
CreateSeriesWithSize(a_ctrl_ca_h_s, "a_ctrl_ca_optimal_s/data", "a_ctrl_ca_optimal_h/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_d_s = ScatterXY.new("a_ctrl_ca_d_s")
CreateSeriesWithSize(a_ctrl_ca_d_s, "a_ctrl_ca_optimal_s/data", "a_ctrl_ca_optimal_d/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_a_s = ScatterXY.new("a_ctrl_ca_a_s")
CreateSeriesWithSize(a_ctrl_ca_a_s, "a_ctrl_ca_optimal_s/data", "a_ctrl_ca_optimal_a/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_v_s = ScatterXY.new("a_ctrl_ca_v_s")
CreateSeriesWithSize(a_ctrl_ca_v_s, "a_ctrl_ca_optimal_s/data", "a_ctrl_ca_optimal_v/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_render_xy = ScatterXY.new("a_ctrl_ca_render_xy")
CreateSeriesWithSize(a_ctrl_ca_render_xy, "a_ctrl_ca_render_x/data", "a_ctrl_ca_render_y/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_ca_render_en = ScatterXY.new("a_ctrl_ca_render_en")
CreateSeriesWithSize(a_ctrl_ca_render_en, "a_ctrl_ca_render_e_base_origin/data", "a_ctrl_ca_render_n_base_origin/data", tracker_time, "a_ctrl_ca_N/data")

a_ctrl_lp_path_xy = ScatterXY.new("a_ctrl_lp_path_xy")
CreateSeriesWithSize(a_ctrl_lp_path_xy, "a_ctrl_lp_path_x/data", "a_ctrl_lp_path_y/data", tracker_time, "a_ctrl_lp_path_size/data")

a_ctrl_lp_path_en = ScatterXY.new("a_ctrl_lp_path_en")
CreateSeriesWithSize(a_ctrl_lp_path_en, "a_ctrl_lp_path_e_base_origin/data", "a_ctrl_lp_path_n_base_origin/data", tracker_time, "a_ctrl_lp_path_size/data")

a_ctrl_lp_path_ll = ScatterXY.new("a_ctrl_lp_path_ll")
CreateSeriesWithSize(a_ctrl_lp_path_ll, "a_ctrl_lp_path_lat/data", "a_ctrl_lp_path_lon/data", tracker_time, "a_ctrl_lp_path_size/data")
