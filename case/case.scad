// -----------------------------------------------------------------------------
// --------------- Key Parameters, Fine-Tuning Here ---------------------------
// -----------------------------------------------------------------------------

$fn =  100;

// Dimensions & geometry
// -------------------- Parameters --------------------
// top case
fillet_radius = 2.5;
top_case_thickness = 3;
wall_thickness_outer = 5;
wall_thickness_inner = 3;
controller_wall_thickness = 1;
keycaps_gap = 0.5;
keycaps_cutout_height = 7.5;
decoration_cutout_depth = 0.5;
decoration_line_width = 1.0;

// PCB + plate + foam stack
seal_thickness = 6;
kailh_sockets_thickness = 2;
bottom_foam_thickness = 3;
actual_bottom_foam_thickness = bottom_foam_thickness - kailh_sockets_thickness;

fr4_thickness = 1.6;
switchplate_thickness = 3.3;
pcb_and_plate_thickness = bottom_foam_thickness + switchplate_thickness + 2 * fr4_thickness;

// gasket
gasket_thickness = 2;
compression = 0.6;
compressed_gasket_thickness = gasket_thickness * (1 - compression);

// bottom case
immersion_depth = 1;
lid_thickness = 1.5;

// power switch slider
switch_protruction = 1;
slider_total_height = lid_thickness + immersion_depth + kailh_sockets_thickness + actual_bottom_foam_thickness + 0.5;

// USB
w_shell = 8.94;
h_shell = 3.26;
r_corner = 1.2;
pcb_usb_distance = 9;
Z_USB = h_shell / 2 + immersion_depth + kailh_sockets_thickness + actual_bottom_foam_thickness + pcb_usb_distance;
usb_main_offset = [139.9, -76, Z_USB];
usb_tunnel_offset = [139.9, -28, Z_USB];
usb_tunnel_len_mm = 50;

// Screw positions & sizes
screw_positions = [[140, -152], [29.5, -132], [30, -32], [152, -32], [153.5, -90]];
case_screw_diameter = 2.7;
case_screw_depth = 3.1;
lid_screw_diameter = 2.5;

// Clearances
clear_pcb_mm = 0.5;
clear_usb_mm = 0.5;
clear_switch_mm = 0.2;
reset_button_thick = 0.2;

// Derived
Z_LID_BASE = -lid_thickness;
total_height_top_case = keycaps_cutout_height + pcb_and_plate_thickness + actual_bottom_foam_thickness + immersion_depth;
EXPLODE = 10;

// Single DXF file + layer names
DXF = "ferris_sweep_bling_mx.dxf";

L_pcb_outline = "pcb_outline";
L_outer_shape = "outer_shape";
L_outer_shape_decor = "outer_shape_decor";
L_decor_lines = "decor_lines";
L_keycaps_outline = "keycaps_outline";
L_controller_cutout = "controller_cutout";
L_reset = "reset";
L_pwr_lid_cutout = "pwr_lid_cutout";
L_pwr_body = "pwr_body";
L_pwr_knob_cutout = "pwr_knob_cutout";
L_pwr_body_overhang = "pwr_body_overhang";
L_pwr_overhang_cutout = "pwr_overhang_cutout";
L_pwr_on_label = "pwr_on_label";
L_switches = "switches";
L_switchplate_outline = "switchplate_outline";
L_gasket_supports = "gasket_supports";

// Layout of the top case from top to bottom starting at Z=0 going positive:
// -keycaps_cutout height
// -seal
// ---pcb stack end---
// -switchplate (fr4)
// -switchplate foam
// -pcb (fr4)
// ---pcb stack start--- 
// -bottom foam
// -immersion_depth


// Layout of the bottom case from top to bottom starting at Z=0 going negative:
// -immersion_depth
// -lid_thickness


// -----------------------------------------------------------------------------
// ------------------------------- Helpers -------------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: extrude_layer --------------------
module extrude_layer(layer, z = 0, h = 1, delta = 0) { translate([0, 0, z]) linear_extrude(height=h) offset(delta=delta) import(file=DXF, layer=layer); }

// -------------------- Module: drill_holes --------------------
module drill_holes(positions, d, z, h) { for (p = positions) translate([p[0], p[1], z]) cylinder(d=d, h=h); }

// -----------------------------------------------------------------------------
// ------------------------------ Extruded Components --------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: rounded_case --------------------
module outer_case() {
  extrude_layer(L_outer_shape, h=fillet_radius, delta=0);
  minkowski() { sphere(fillet_radius); translate([0, 0, fillet_radius]) extrude_layer(L_outer_shape, h=total_height_top_case - 2 * fillet_radius, delta= - fillet_radius); }
}

// -------------------- Module: pcb_holder --------------------
module pcb_holder() {
    difference() {
        extrude_layer(L_outer_shape, h=total_height_top_case-top_case_thickness, delta=-wall_thickness_outer);
        extrude_layer(L_pcb_outline, h=total_height_top_case-top_case_thickness, delta=wall_thickness_inner);
    }
}

module gasket_supports_cutout() {
    extrude_layer(L_gasket_supports, h=total_height_top_case-keycaps_cutout_height, delta=0.3);
}

// -------------------- Module: upper_gasket_supports --------------------
module upper_gasket_supports() {
    extrude_layer(L_gasket_supports, z=immersion_depth + bottom_foam_thickness + fr4_thickness + switchplate_thickness + compressed_gasket_thickness, h=fr4_thickness + seal_thickness - compressed_gasket_thickness, delta = 0.2);
}

// -------------------- Module: lower_gasket_supports --------------------
module lower_gasket_supports() {
  difference() {
    extrude_layer(L_gasket_supports, h=immersion_depth + bottom_foam_thickness + fr4_thickness - compressed_gasket_thickness);
    extrude_layer(L_pcb_outline, h=immersion_depth + bottom_foam_thickness + fr4_thickness - compressed_gasket_thickness, delta=clear_pcb_mm);
    }
}

// -------------------- Module: pcb_stack --------------------
module pcb_stack() { extrude_layer(L_pcb_outline, h=actual_bottom_foam_thickness + pcb_and_plate_thickness + immersion_depth + seal_thickness, delta=clear_pcb_mm); }

// -------------------- Module: keycaps_cutout --------------------
module keycaps_cutout() { extrude_layer(L_keycaps_outline, h=total_height_top_case, delta=2 * keycaps_gap); }

// -------------------- Module: flat_usb_cutout --------------------
module flat_usb_cutout() { extrude_layer(L_controller_cutout, h=total_height_top_case - controller_wall_thickness, delta=clear_usb_mm); }

// -------------------- Module: lid --------------------
module lid() {
  extrude_layer(L_outer_shape, z=Z_LID_BASE, h=lid_thickness, delta=0);
  extrude_layer(L_pcb_outline, z=Z_LID_BASE + lid_thickness, h=immersion_depth);
}

// -------------------- Module: pwr_switch_slider_cutout --------------------
module pwr_switch_slider_cutout(delta = 0) { extrude_layer(L_pwr_lid_cutout, z=Z_LID_BASE, h=lid_thickness + immersion_depth, delta=delta); }

// -------------------- Module: power_switch_overhang_cutout --------------------
module power_switch_overhang_cutout(delta = 0) { extrude_layer(L_pwr_overhang_cutout, h=slider_total_height, delta=delta); }

// -------------------- Module: power_switch_slider --------------------
module power_switch_slider() {
  difference() {
    extrude_layer(L_pwr_body, z=Z_LID_BASE - switch_protruction, h=slider_total_height + switch_protruction);
    extrude_layer(L_pwr_knob_cutout, z=Z_LID_BASE + immersion_depth + 0.5, h=slider_total_height - immersion_depth);
    translate([0, 0, Z_LID_BASE - switch_protruction]) linear_extrude(height=0.2) import(file=DXF, layer=L_pwr_on_label);
  }
  extrude_layer(L_pwr_body_overhang, h=immersion_depth);
}

// -------------------- Module: reset_cutout --------------------
module reset_cutout(delta = 0) { extrude_layer(L_reset, z=Z_LID_BASE, h=lid_thickness + immersion_depth, delta=delta); }

// -------------------- Module: reset_overhang_cutout --------------------
module reset_overhang_cutout(delta = 0) { extrude_layer(L_reset, h=immersion_depth, delta=delta); }

// -------------------- Module: reset_switch_button --------------------
module reset_switch_button() {
  extrude_layer(L_reset, z=Z_LID_BASE - 0.5, h=lid_thickness + 0.5);
  extrude_layer(L_reset, h=immersion_depth + actual_bottom_foam_thickness + 0.5, delta=reset_button_thick);
}

// -------------------- Module: top_plate_decor_cutout --------------------
module top_plate_decor_cutout() {
    extrude_layer(L_outer_shape_decor, z=total_height_top_case-decoration_cutout_depth, h=decoration_cutout_depth);  
}

// -------------------- Module: top_plate_decor --------------------
module top_plate_decor() {
    difference(){
        extrude_layer(L_outer_shape_decor, z=total_height_top_case-decoration_cutout_depth , h=decoration_cutout_depth, delta=-decoration_line_width); 
        keycaps_cutout();
    }
}

// -------------------- Module: top_plate_decor_lines_cutout --------------------
module top_plate_decor_lines_cutout() {
    extrude_layer(L_decor_lines, z=total_height_top_case-decoration_cutout_depth , h=decoration_cutout_depth);  
}

// -----------------------------------------------------------------------------
// ------------------------------ 3D Components --------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: usb_c_cutout_2d --------------------
module usb_c_cutout_2d(cw = 0.1, ch = 0.1) {
  w = w_shell + 2 * cw;
  h = h_shell + 2 * ch;
  minkowski() { square([w - 2 * r_corner, h - 2 * r_corner], center=true); circle(r=r_corner, $fn=64); }
}

// -------------------- Module: usb_c_cutout_position --------------------
module usb_c_cutout_position() {
  translate(usb_main_offset) rotate([90, 0, 0]) linear_extrude(height=5) usb_c_cutout_2d();
  translate(usb_tunnel_offset) rotate([90, 0, 0]) linear_extrude(height=usb_tunnel_len_mm) usb_c_cutout_2d(1.1, 1.65);
}

// -------------------- Module: case_screw_holes --------------------
module case_screw_holes() { drill_holes(screw_positions, case_screw_diameter, 0, case_screw_depth); }

// -------------------- Module: lid_screw_holes --------------------
module lid_screw_holes() { drill_holes(screw_positions, lid_screw_diameter, Z_LID_BASE, lid_thickness); }


// -----------------------------------------------------------------------------
// ------------------------------ Assemblies -----------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: top_case --------------------
module top_case() {
  difference() {
    outer_case();
    pcb_stack();
    power_switch_overhang_cutout(delta=clear_switch_mm);
    keycaps_cutout();
    case_screw_holes();
    top_plate_decor_cutout();
    top_plate_decor_lines_cutout();
    flat_usb_cutout();
    usb_c_cutout_position();
    pcb_holder();
    gasket_supports_cutout();
  }
  top_plate_decor();
  difference() {
    upper_gasket_supports();
    keycaps_cutout();
  }
}

// -------------------- Module: bottom_case --------------------
module bottom_case() {
  difference() {
    lid();
    reset_cutout(0.2);
    reset_overhang_cutout(reset_button_thick + 0.2);
    lid_screw_holes();
    pwr_switch_slider_cutout(delta=clear_switch_mm);
    power_switch_overhang_cutout(delta=clear_switch_mm);
  }
   lower_gasket_supports();
}

// -------------------- Module: switchplate foam --------------------
module switchplate_foam() {
    extrude_layer(L_gasket_supports, z=immersion_depth + bottom_foam_thickness + fr4_thickness, h=switchplate_thickness);
    difference() {
      extrude_layer(L_switchplate_outline, z=immersion_depth + bottom_foam_thickness + fr4_thickness, h=switchplate_thickness);
      extrude_layer(L_switches, z=immersion_depth + bottom_foam_thickness + fr4_thickness, h=switchplate_thickness, delta=0.3);
    }
}

// -------------------- Module: bottom foam --------------------
module bottom_foam() {
  difference() {
    extrude_layer(L_switchplate_outline, z=immersion_depth, h=bottom_foam_thickness, delta=-0.3);
    extrude_layer(L_switches, z=immersion_depth, h=bottom_foam_thickness, delta=0.3);
    extrude_layer(L_pwr_body, z=immersion_depth, h=bottom_foam_thickness, delta=0.3);
    extrude_layer(L_switches, z=immersion_depth, h=bottom_foam_thickness, delta=0.3);
  }
}

// -----------------------------------------------------------------------------
// --------------------------- Optional Tent Support ---------------------------
// -----------------------------------------------------------------------------
// Render by setting PART = "tent"
// Note: Changing tenting_angle requires adjusting tent_lowering.

// ---- Tenting Parameters ----
tenting_angle = 7;
tent_base_thickness = 0;
tent_support_base_thickness = 0.0001;
tent_support_base_width = 10;
tent_support_wall_thickness = 1.5;
tent_support_wall_height = 3;
tent_clearance = 0.2;
tent_lowering = 3.0;

// Outline (uses main PCB outline layer) expanded by case wall_thickness
module tent_case_outline() { offset(delta=0) import(file=DXF, layer=L_outer_shape); }

module tent_base_plate() {
  linear_extrude(tent_base_thickness)
    projection()
      rotate([0, -tenting_angle, 0])
        linear_extrude(0.0001)
          offset(delta=tent_clearance + tent_support_wall_thickness)
            tent_case_outline();
}

module tent_support_base() {
  linear_extrude(tent_support_base_thickness)
    difference() {
      offset(delta=tent_clearance + tent_support_wall_thickness)
        tent_case_outline();
      offset(delta=-tent_support_base_width)
        tent_case_outline();
    }
}

module tent_support_walls() {
  translate([0, 0, tent_support_base_thickness])
    linear_extrude(tent_support_wall_height)
      difference() {
        offset(delta=tent_clearance + tent_support_wall_thickness)
          tent_case_outline();
        offset(delta=tent_clearance)
          tent_case_outline();
      }
}

module tent_support() {
  translate([0, 0, tent_base_thickness])
    union() {
      translate([0, 0, tent_support_base_thickness - tent_lowering])
        rotate([0, -tenting_angle, 0])
          union() {
            tent_support_base();
            tent_support_walls();
          }

      difference() {
        linear_extrude()
          projection()
            rotate([0, -tenting_angle, 0])
              linear_extrude(0.0001)
                projection()
                  tent_support_base();

        translate([0, 0, tent_support_base_thickness - tent_lowering])
          rotate([0, -tenting_angle, 0])
            linear_extrude()
              offset(delta=100)
                projection()
                  tent_support_base();
      }
    }
}

// Full tent assembly (base + support structure)
module tent() {
  tent_base_plate();
  tent_support();
}

// -----------------------------------------------------------------------------
// ------------------------------ Build Select ---------------------------------
// -----------------------------------------------------------------------------
PART = "exploded";

// -------------------- Module: build --------------------
module build() {
  if (PART == "exploded") {
    translate([0, 0, EXPLODE]) top_case();
    translate([0, 0, -EXPLODE]) switchplate_foam();
    translate([0, 0, -2 * EXPLODE]) power_switch_slider();
    translate([0, 0, -2 * EXPLODE]) reset_switch_button();
    translate([0, 0, -3 * EXPLODE]) bottom_foam();
    translate([0, 0, -4 * EXPLODE]) bottom_case();
  } else if (PART == "top_case")
    top_case();
  else if (PART == "switch_plate_foam")
    switchplate_foam();
  else if (PART == "power_switch_slider")
    power_switch_slider();
  else if (PART == "reset_switch_button")
    reset_switch_button();
  else if (PART == "bottom_foam")
    bottom_foam();
  else if (PART == "bottom_case")
    bottom_case();
  else if (PART == "tent")
    tent();
  else
    echo(str("Unknown PART: ", PART));
}

build();
