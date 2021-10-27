# Godot2DFOV
A "simple" Field Of View system for Godot 2D.

## How to install?

Download the Godot project or copy/paste the FieldOfView.gd script file.

## How to use?

Since the script has a custom class name, you can just find it in the '*Create a new Node*' window of Godot. This node/script **absolutely** needs to be a child of a node to work.

## How it works?

External values such as ***groups***, ***vision_angle***, ***vision_radius*** and ***debug_mode*** can help you modify the field of view parameters directly from the engine.

You can use ***get_detected_bodies()*** to get an array of all the 2d nodes detected by the field of view.

1. Check for all groups
2. Check for all nodes in every group
3. Get the global position of the current node
4. Check if the global position is inside a circle and a triangle (using simple math "algorithms")
5. Cast a ray from the field of view position to the node position
6. If nothing is in between the way, add it to the list of nodes inside the field of view.
