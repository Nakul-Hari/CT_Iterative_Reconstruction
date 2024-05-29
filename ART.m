
num_rows = 64; 
num_cols = 64;
detectors = 128;
num_angles = 180; 

system_matrix = zeros(detectors * num_angles, num_rows * num_cols);

x_interp = linspace(-detectors / 2, detectors / 2 - 1, detectors);
y_interp = linspace(-detectors / 2, detectors / 2 - 1, detectors);

[X_interp, Y_interp] = meshgrid(x_interp, y_interp);

%%

i = 0;
for angle_index = 0 : num_angles - 1 
    theta = deg2rad(angle_index);
    rotation_matrix = [cos(theta), -sin(theta); sin(theta), cos(theta)];

    rotated_coords = rotation_matrix * [X_interp(:)'; Y_interp(:)'];
    X_rotated = reshape(rotated_coords(1, :), size(X_interp));
    Y_rotated = reshape(rotated_coords(2, :), size(Y_interp));

    for row_index = 1:detectors
        for col_index = 1:detectors
            x_rounded = round(X_rotated(row_index, col_index));
            y_rounded = round(Y_rotated(row_index, col_index));
            
            if((x_rounded <= num_rows / 2 - 1) && (x_rounded >= -num_rows / 2) && (y_rounded <= num_cols / 2 - 1) && (y_rounded >= -num_cols / 2))
                system_matrix(i * detectors + row_index, (y_rounded + num_rows / 2) * num_rows + (x_rounded + num_rows / 2 + 1)) = 1;
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
colormap gray;
colorbar;

R = system_matrix*phantom_image(:);
Radon = R/max(R(:)); % maybe problematic
imagesc(reshape(Radon,detectors,num_angles));
colormap gray;
colorbar;


%%

initial_guess_x = zeros(num_rows*num_cols,1);
previous_image = zeros(num_rows*num_cols,1);

previous_radon = system_matrix*initial_guess_x;
current_radon = previous_radon;
%%
k = 1;
reconstruction_error = inf;
while reconstruction_error > 0.1
    for angles = 0 : num_angles - 1
        for ray = 1 : detectors
            index = angles * detectors + ray;
            calculated_radon = system_matrix(index, :) * previous_image;
            error = Radon(index) - calculated_radon;
            length = sum(system_matrix(index,:));
            if (length == 0)
                normalised_error = error;
            else
                normalised_error = error / length;
            end

            previous_image = previous_image + transpose(system_matrix(index, :)) * normalised_error;
        end
    end

    display_image = reshape(previous_image, num_cols, num_rows);
    figure;
    imagesc(display_image);
    colormap('gray');
    title(['Iteration Number : ', num2str(k), ' completed']);
    colorbar;

    reconstruction_error = norm(Radon - system_matrix * previous_image);
    disp(['Iteration ', num2str(k), ' error: ', num2str(reconstruction_error)]);
    k = k + 1;
end

%%
figure;
display_image = reshape(previous_image, num_cols, num_rows);
imagesc(display_image);
colormap('gray');
title('The reconstructed Image');
colorbar;