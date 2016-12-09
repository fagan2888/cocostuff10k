classdef CocoStuffDatasetSimplified
    % CocoStuffDataset
    %
    % Semantic segmentation dataset for stuff classes in COCO
    %
    % Copyright by Holger Caesar, 2016
    
    % Properties that are normally in the Dataset class
    properties
        % General settings
        name
        path
        
        % Image settings
        imageCount = [];
        imageExt = '.jpg';
        imageFolder = 'Images';
    end
    
    methods
        function[obj] = CocoStuffDatasetSimplified()
            % Define dataset
            obj.name = 'CocoStuff';
            obj.imageExt = '.jpg';
        end
        
        function[image] = getImage(obj, imageName, ~)
            % [image] = getImage(obj, imageName, ~)
            
            % Create path
            imageFolderFull = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'data', 'input', 'images');
            imagePath = fullfile(imageFolderFull, [imageName, obj.imageExt]);
            
            % Read in image and convert to double
            image = im2double(imread(imagePath));
            
            % Convert grayscale to rgb
            if size(image, 3) == 1
                image = cat(3, image, image, image);
            end
        end
        
        function[labelNames, labelCount] = getLabelNames(obj)
            % [labelNames, labelCount] = getLabelNames(obj)
            %
            % Get a cell of strings that specify the names of each label.
            
            % Retrieve labels from hierarchy to make sure they match
            [~, categories, heights] = obj.getClassHierarchy();
            
            % Select only leaf nodes
            sel = heights == max(heights);
            categories = categories(sel);
            
            % Get stuff and thing labels
            labelNames = categories;
            labelCount = numel(labelNames);
        end
        
        function[nodes, categories, heights] = getClassHierarchy(~)
            % Returns a hierarchy of classes to be plotted with treeplot(nodes)
            
            parents = { ...
                'stuff', 'stuff'
                'indoor', 'stuff'; ...
                'outdoor', 'stuff'; ...
                ... % End of level 2
                'raw-material', 'indoor'; ...
                'wall', 'indoor'; ...
                'ceiling', 'indoor'; ...
                'floor', 'indoor'; ...
                'window', 'indoor'; ...
                'furniture', 'indoor'; ...
                'textile', 'indoor'; ...
                'food', 'indoor'; ...
                'building', 'outdoor'; ...
                'structural', 'outdoor'; ...
                'plant', 'outdoor'; ...
                'sky', 'outdoor'; ...
                'solid', 'outdoor'; ...
                'ground', 'outdoor'; ...
                'water', 'outdoor'; ...
                ... % End of level 3
                'cardboard', 'raw-material'; ...
                'paper', 'raw-material'; ...
                'plastic', 'raw-material'; ...
                'metal', 'raw-material'; ...
                'wall-tile', 'wall'; ...
                'wall-panel', 'wall'; ...
                'wall-wood', 'wall'; ...
                'wall-brick', 'wall'; ...
                'wall-stone', 'wall'; ...
                'wall-concrete', 'wall'; ...
                'wall-other', 'wall'; ...
                'ceiling-tile', 'ceiling'; ...
                'ceiling-other', 'ceiling'; ...
                'carpet', 'floor'; ...
                'floor-tile', 'floor'; ...
                'floor-wood', 'floor'; ...
                'floor-marble', 'floor'; ...
                'floor-stone', 'floor'; ...
                'floor-other', 'floor'; ...
                'window-blind', 'window'; ...
                'window-other', 'window'; ...
                'door', 'furniture'; ...
                'desk', 'furniture'; ...
                'table', 'furniture'; ...
                'shelf', 'furniture'; ...
                'cabinet', 'furniture'; ...
                'cupboard', 'furniture'; ...
                'mirror', 'furniture'; ...
                'counter', 'furniture'; ...
                'light', 'furniture'; ...
                'stairs', 'furniture'; ...
                'furniture-other', 'furniture'; ...
                'rug', 'textile'; ...
                'mat', 'textile'; ...
                'towel', 'textile'; ...
                'napkin', 'textile'; ...
                'clothes', 'textile'; ...
                'cloth', 'textile'; ...
                'curtain', 'textile'; ...
                'blanket', 'textile'; ...
                'pillow', 'textile'; ...
                'banner', 'textile'; ...
                'textile-other', 'textile'; ...
                'fruit', 'food'; ...
                'salad', 'food'; ...
                'vegetable', 'food'; ...
                'drink', 'food'; ...
                'food-other', 'food'; ...
                ... % End of level 4 left
                'house', 'building'; ...
                'skyscraper', 'building'; ...
                'bridge', 'building'; ...
                'pool', 'building'; ...
                'tent', 'building'; ...
                'roof', 'building'; ...
                'building-other', 'building'; ...
                'fence', 'structural'; ...
                'cage', 'structural'; ...
                'net', 'structural'; ...
                'railing', 'structural'; ...
                'structural-other', 'structural'; ...
                'grass', 'plant'; ...
                'tree', 'plant'; ...
                'logs', 'plant'; ...
                'bush', 'plant'; ...
                'leaves', 'plant'; ...
                'flower', 'plant'; ...
                'branch', 'plant'; ...
                'moss', 'plant'; ...
                'pollen', 'plant'; ...
                'straw', 'plant'; ...
                'corals', 'plant'; ...
                'seaweed', 'plant'; ...
                'plant-other', 'plant'; ...
                'clouds', 'sky'; ...
                'sky-other', 'sky'; ...
                'wood', 'solid'; ...
                'rock', 'solid'; ...
                'stone', 'solid'; ...
                'mountain', 'solid'; ...
                'hill', 'solid'; ...
                'solid-other', 'solid'; ...
                'sand', 'ground'; ...
                'ice', 'ground'; ...
                'snow', 'ground'; ...
                'dirt', 'ground'; ...
                'mud', 'ground'; ...
                'gravel', 'ground'; ...
                'road', 'ground'; ...
                'pavement', 'ground'; ...
                'railroad', 'ground'; ...
                'platform', 'ground'; ...
                'playingfield', 'ground'; ...
                'ground-other', 'ground'; ...
                'fog', 'water'; ...
                'river', 'water'; ...
                'sea', 'water'; ...
                'underwater', 'water'; ...
                'waterdrops', 'water'; ...
                'water-other', 'water'; ...
                };
            categories = parents(:, 1);
            assert(numel(categories) == numel(unique(categories)));
            
            % Create pointers to parent nodes
            categoryCount = size(categories, 1);
            nodes = nan(categoryCount, 1);
            heights = nan(categoryCount, 1);
            nodes(1) = 0;
            heights(1) = 0;
            for i = 2 : categoryCount
                childNode = find(strcmp(parents(:, 1), categories{i}));
                if isempty(childNode)
                    error('Error: No parent node found for %s!', categories{i});
                end
                parentNode = find(strcmp(categories, parents(childNode, 2)));
                assert(numel(parentNode) == 1);
                nodes(i) = parentNode;
                heights(i) = heights(parentNode) + 1;
            end
        end
    end
end