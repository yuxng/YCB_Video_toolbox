% seq_id: 0 ~ 91
% The *-meta.mat file in the YCB-Video data contains the following fields:
% center: 2D location of the projection of the 3D model origin in the image
% cls_indexes: class labels of the objects
% factor_depth: divde the depth image by this factor to get the actual depth vaule
% intrinsic_matrix: camera intrinsics
% rotation_translation_matrix: RT of the camera motion in 3D
% vertmap: coordinates in the 3D model space of each pixel in the image
function show_pose_annotations(seq_id)

opt = globals();
if seq_id >= 60
    depth2color = opt.depth2color_cmu;
    intrinsic_matrix_color = opt.intrinsic_matrix_color_cmu;
else
    depth2color = opt.depth2color;
    intrinsic_matrix_color = opt.intrinsic_matrix_color;
end
num_frames = opt.nums(seq_id + 1);

% read class names
fid = fopen('classes.txt', 'r');
C = textscan(fid, '%s');
object_names = C{1};
fclose(fid);
num_objects = numel(object_names);

% load CAD models
disp('loading 3D models...');
models = cell(num_objects, 1);
for i = 1:num_objects
    filename = sprintf('models/%s.mat', object_names{i});
    if exist(filename, 'file')
        object = load(filename);
        obj = object.obj;
    else
        file_obj = fullfile(opt.root, 'models', object_names{i}, 'textured.obj');
        obj = load_obj_file(file_obj);
        save(filename, 'obj');
    end
    disp(filename);
    models{i} = obj;
end

close all;
figure(1);

% for each frame
for k = 1:num_frames
    fprintf('%04d: %06d\n', seq_id, k);

    % read image
    filename = fullfile(opt.root, 'data', sprintf('%04d/%06d-color.png', seq_id, k));
    I = imread(filename);
    subplot(3, 3, 1);
    imshow(I);
    title('color image');
    
    % read depth
    filename = fullfile(opt.root, 'data', sprintf('%04d/%06d-depth.png', seq_id, k));
    depth = imread(filename);
    subplot(3, 3, 2);
    imagesc(depth);
    title('depth image');
    axis equal;
    
    % read labels
    filename = fullfile(opt.root, 'data', sprintf('%04d/%06d-label.png', seq_id, k));
    label = imread(filename);
    label_image = generate_label_image(label);
    subplot(3, 3, 3);
    imshow(label_image);
    title('label image');
    
    % load meta-data
    filename = fullfile(opt.root, 'data', sprintf('%04d/%06d-meta.mat', seq_id, k));
    object = load(filename);
    targets = generate_vertex_targets(label, object.cls_indexes, object.center, object.poses, opt.num_classes);
    
    subplot(3, 3, 4);
    imagesc(targets(:, :, 1));
    title('center direction X');
    axis equal;
    axis off;
    
    subplot(3, 3, 5);
    imagesc(targets(:, :, 2));
    title('center direction Y');
    axis equal;
    axis off;
    
    subplot(3, 3, 6);
    imagesc(targets(:, :, 3));
    title('center distance');
    axis equal;
    axis off;
    
    % show pose overlap
    subplot(3, 3, 7);
    imshow(I);
    title('6D pose annotation');
    
    subplot(3, 3, 8);
    imshow(I);
    title('bounding box');
    
    % sort objects according to distances
    num = numel(object.cls_indexes);
    distances = zeros(num, 1);
    poses = object.poses;
    for j = 1:num
        distances(j) = poses(3, 4, j);
    end
    [~, index] = sort(distances, 'descend');
        
    % for each object
    for j = 1:num
        ind = index(j);
        
        % load RT_o2c
        RT_o2c = poses(:,:,ind);
        
        % projection
        x3d = models{object.cls_indexes(ind)}.v';
        x2d = project(x3d, intrinsic_matrix_color, RT_o2c);
        
        % bounding boxes
        vmin = min(x2d, [], 1);
        vmax = max(x2d, [], 1);
        x1 = max(vmin(1), 0);
        y1 = max(vmin(2), 0);
        x2 = min(vmax(1), size(I,2));
        y2 = min(vmax(2), size(I,1));     
        
        % draw
        subplot(3, 3, 7);
        hold on;
        patch('vertices', x2d, 'faces', models{object.cls_indexes(ind)}.f3', ...
                'FaceColor', opt.class_colors(object.cls_indexes(ind)+1,:), 'FaceAlpha', 0.4, 'EdgeColor', 'none');
        scatter(object.center(ind, 1), object.center(ind, 2), 1500, '.', ...
            'MarkerEdgeColor', 'y', 'MarkerFaceColor', 'y', 'LineWidth', 1.5);
        hold off;
        
        subplot(3, 3, 8);
        hold on;
        rectangle('Position', [x1, y1, x2-x1, y2-y1], ...
            'EdgeColor', opt.class_colors(object.cls_indexes(ind)+1,:), 'LineWidth', 8);
        scatter(object.center(ind, 1), object.center(ind, 2), 1500, '.', ...
            'MarkerEdgeColor', 'y', 'MarkerFaceColor', 'y', 'LineWidth', 1.5);        
        hold off;
    end
    
    pause;
end

function vertex_targets = generate_vertex_targets(im_label, cls_indexes, center, poses, num_classes)

% sort objects according to distances
num_objects = numel(cls_indexes);
distances = zeros(num_objects, 1);
for j = 1:num_objects
    distances(j) = poses(3, 4, j);
end

width = size(im_label, 2);
height = size(im_label, 1);
vx = -1.5 * ones(height, width);
vy = -1.5 * ones(height, width);
vz = -max(distances) * ones(height, width) - 0.1;

c = zeros(1, 2);
for i = 1:num_classes
    [y, x] = find(im_label == i);
    if ~isempty(x)
        ind = find(cls_indexes == i);
        c(1) = center(ind, 1);
        c(2) = center(ind, 2);
        z = poses(3, 4, ind);
        R = repmat(c, length(x), 1) - [x, y];
        % compute the norm
        N = sqrt(sum(R .^ 2, 2)) + 1e-10;
        % normalization
        R = R ./ [N N];
        % assignment
        indp = sub2ind(size(im_label), y, x);
        vx(indp) = R(:, 1);
        vy(indp) = R(:, 2);
        vz(indp) = -z;
    end
end

vertex_targets = zeros(height, width, 3);
vertex_targets(:, :, 1) = rescale_image(vx);
vertex_targets(:, :, 2) = rescale_image(vy);
vertex_targets(:, :, 3) = vz;

function im = rescale_image(im)

vmax = max(max(im));
vmin = min(min(im));

a = 1.0 / (vmax - vmin);
b = -1.0 * vmin / (vmax - vmin);

im = a * im + b;