function show_pose_results

opt = globals();
res_dir = 'results_PoseCNN';

% read class names
fid = fopen('classes.txt', 'r');
C = textscan(fid, '%s');
object_names = C{1};
fclose(fid);

% load CAD models
num_objects = numel(object_names);
models = cell(num_objects, 1);
for i = 1:num_objects
    filename = sprintf('models/%s.mat', object_names{i});
    if exist(filename, 'file')
        object = load(filename);
        obj = object.obj;
    else
        file_obj = fullfile(opt.model_path, object_names{i}, 'textured.obj');
        obj = load_obj_file(file_obj);
        save(filename, 'obj');
    end
    disp(filename);
    models{i} = obj;
end

%hf = figure('units','normalized','outerposition',[0 0 1 1]);
hf = figure;

% load test indexes
[seq_ids, frame_ids] = load_dataset_indexes('keyframe.txt');
num = numel(frame_ids);
index = randperm(num);
% index = 1:num;
% for each image
for i = index
    % load the pose results
    filename = fullfile(res_dir, sprintf('%04d.mat', i-1));
    result = load(filename);
    n = size(result.rois, 1);
    
    % read image
    filename = fullfile(opt.root, 'data', sprintf('%04d/%06d-color.png', seq_ids(i), frame_ids(i)));
    I = imread(filename);
    disp(filename);
    
    % show image
    subplot(2, 2, 1);
    imshow(I);
    title('input image');
    
    % show labels
    subplot(2, 2, 2);
    im_label = generate_label_image(result.labels);
    imshow(im_label);
    title('predicted labels');
    
    % show center and bounding box
    subplot(2, 2, 3);
    imshow(I);
    hold on;
    for j = 1:n
        objID = result.rois(j, 2);          
        rectangle('Position', [result.rois(j, 3), result.rois(j, 4), result.rois(j, 5) - result.rois(j, 3), ...
            result.rois(j, 6) - result.rois(j, 4)], 'EdgeColor', opt.class_colors(objID+1,:), ...
            'LineWidth', 6);        
        
        cx = (result.rois(j, 3) + result.rois(j, 5)) / 2;
        cy = (result.rois(j, 4) + result.rois(j, 6)) / 2;
        %plot(cx, cy, 'yo', 'LineWidth', 6);
        scatter(cx,cy,200,'MarkerEdgeColor',[0 .0 .0],...
              'MarkerFaceColor','y',...
              'LineWidth',4);
    end
    hold off;
    title('predicted bounding box and center');
    
    subplot(2, 2, 4);
    imshow(I);
    hold on;
    for j = 1:n
        RT = zeros(3, 4);
        RT(1:3, 1:3) = quat2rotm(result.poses_icp(j, 1:4));
        RT(:, 4) = result.poses_icp(j, 5:7);
        
        % projection
        objID = result.rois(j, 2);
        x3d = models{objID}.v';
        x2d = project(x3d, opt.intrinsic_matrix_color, RT);
        
        % draw
        patch('vertices', x2d, 'faces', models{objID}.f3', ...
                'FaceColor', opt.class_colors(objID+1,:), 'FaceAlpha', 0.4, 'EdgeColor', 'none');
    end
    hold off;
    title('6D pose after ICP');
    
%     filename = sprintf('results/%04d.png', i-1);
%     hgexport(hf, filename, hgexport('factorystyle'), 'Format', 'png');
    pause;
end