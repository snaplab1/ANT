function draw_arrow(center_coords, arrow_rotation, arrow_color, dimension_array, window)
% DRAW_ARROW Draws an arrow using PsychToolbox commands
%
% draw_arrow(w, center_coords, arrow_rotation, arrow_color, dimension_array)

%%%%%%%%%%%%%% added so this can be run as standalone function
% if length(varargin)~=1
% 	varargin
% 	Screen('Preference', 'SkipSyncTests', 1);
% 	window = Screen('OpenWindow',1);	% Open window
% 	black=BlackIndex(window);
% 	grey = [128,128,128];
% 	Screen('FillRect',window,grey);
% 	Screen('Flip',window);
% end;
%%%%%%%%%%%%%%
	% disp('got here')
    horz_center = center_coords(1);
    vert_center = center_coords(2);
    
    head_width = dimension_array(1);
    head_height = dimension_array(2);
    body_width = dimension_array(3);
    body_height = dimension_array(4);
    
   % head_width = dimension_array(1)*3;
   % head_height = dimension_array(2)*3;
   % body_width = dimension_array(3)*.8;
   % body_height = dimension_array(4)*1.5;

    head_slope = head_height / head_width;
    arrow_width = head_width + body_width;
    arrow_height = max(head_height, body_height);
    arrow_left = -(arrow_width/2);
    arrow_neck = arrow_left + head_width;
    arrow_right = (arrow_width/2);
    
    % draw a leftward facing arrow, translate and rotate later
    
    % draw arrow head first
    for x = 0:head_width
        line_half_height = x * head_slope / 2;
        dim_array = [arrow_left+x -line_half_height arrow_left+x +line_half_height];
        drawn_array = draw_rotated_line(dim_array);
    end
	% disp('got here')
    
    % now draw arrow body
    for x = arrow_neck:1:arrow_right
        dim_array = [x (-body_height/2) x (body_height/2)];
        drawn_array = draw_rotated_line(dim_array);
    end
    % Screen('Flip',w);
	        
    function [cart_coords] = screen2cart(screen_coords, horizontal_center, vertical_center)
        cart_coords = screen_coords - [horizontal_center vertical_center horizontal_center vertical_center];
    end

    function [screen_coords] = cart2screen(cart_coords, horizontal_center, vertical_center)
        screen_coords = cart_coords + [horizontal_center vertical_center horizontal_center vertical_center];
    end
    
    function [rotated_array] = rotate_dim_array(dim_array, rotation_angle_in_degrees)
        rotate_radians = rotation_angle_in_degrees / 180 * pi;
        % rotate first point in dim array
        [original_angle, radius, ] = cart2pol(dim_array(1), dim_array(2));
        new_angle = original_angle + rotate_radians;
        [rotated_array(1) rotated_array(2)] = pol2cart(new_angle, radius);
        
        % rotate second point in dim array
        [original_angle, radius, ] = cart2pol(dim_array(3), dim_array(4));
        new_angle = original_angle + rotate_radians;
        [rotated_array(3) rotated_array(4)] = pol2cart(new_angle, radius);
    end
	% disp('got here')
    
    function [rotated_screen_array] = draw_rotated_line(cart_array)
        rotated_array = rotate_dim_array(cart_array, arrow_rotation);
        rotated_screen_array = cart2screen(rotated_array, horz_center, vert_center);
        Screen('DrawLine', window, arrow_color, rotated_screen_array(1), rotated_screen_array(2), rotated_screen_array(3), rotated_screen_array(4));
    end
end