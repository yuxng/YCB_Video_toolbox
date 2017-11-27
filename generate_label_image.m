function I = generate_label_image(label)

opt = globals();

width = size(label, 2);
height = size(label, 1);
R = uint8(zeros(height, width));
G = uint8(zeros(height, width));
B = uint8(zeros(height, width));

for i = 0:opt.num_classes
    index = find(label == i);
    if isempty(index) == 0
        R(index) = opt.class_colors(i+1, 1);
        G(index) = opt.class_colors(i+1, 2);
        B(index) = opt.class_colors(i+1, 3);
    end
end

I = uint8(zeros(height, width, 3));
I(:, :, 1) = R;
I(:, :, 2) = G;
I(:, :, 3) = B;