num_rows = 64; 
num_cols = 64; 
num_angles = 180; 

system_matrix = zeros(num_cols * num_angles, num_rows * num_cols);

x_interp = linspace(-num_cols / 2, num_cols / 2 - 1, num_cols);
y_interp = linspace(-num_cols / 2, num_cols / 2 - 1, num_cols);

[X_interp, Y_interp] = meshgrid(x_interp, y_interp);

%%

i = 0;
for angle_index = 0:num_angles - 1 
    theta = deg2rad(angle_index);
    rotation_matrix = [cos(theta), -sin(theta); sin(theta), cos(theta)];

    rotated_coords = rotation_matrix * [X_interp(:)'; Y_interp(:)'];
    X_rotated = reshape(rotated_coords(1, :), size(X_interp));
    Y_rotated = reshape(rotated_coords(2, :), size(Y_interp));

    for row_index = 1:num_cols
        for col_index = 1:num_cols 
            x_rounded = round(X_rotated(row_index, col_index));
            y_rounded = round(Y_rotated(row_index, col_index));
            
            if((x_rounded <= num_rows / 2 - 1) && (x_rounded >= -num_rows / 2) && (y_rounded <= num_cols / 2 - 1) && (y_rounded >= -num_cols / 2))
                system_matrix(i * num_cols + row_index, (y_rounded + num_rows / 2) * num_rows + (x_rounded + num_rows / 2 + 1)) = 1;
            end
        end
    end
    i = i + 1;
end

%%
phantom_image = phantom(num_rows, num_cols);
imagesc(phantom_image);
colormap gray;

imagesc(system_matrix);
title 'System Matrix'
colormap gray;
colorbar;