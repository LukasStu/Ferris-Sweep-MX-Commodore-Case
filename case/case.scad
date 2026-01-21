// -----------------------------------------------------------------------------
// --------------- Key Parameters, Fine-Tuning Here ---------------------------
// -----------------------------------------------------------------------------

$fn =  100;

// Dimensions & geometry
// -------------------- Parameters --------------------
// top case
fillet_radius = 2.5;
top_case_thickness = 3;
case_wall_thickness = 4;
controller_cover_thickness = 1;
keycaps_gap = 0.5;
keycaps_cutout_height = 8.5;
decoration_cutout_depth = 0.5;
decoration_line_width = 1.0;

// bottom case
bottom_thickness = 1.5;
bottom_gap = 1.5;

// PCB + plate + foam stack
kailh_sockets_thickness = 2;

fr4_thickness = 1.6;
switchplate_thickness = 3.3;
pcb_and_plate_thickness =  kailh_sockets_thickness + switchplate_thickness + 2 * fr4_thickness;

// gasket
gasket_thickness = 2;
compression = 0.5;
compressed_gasket_thickness = gasket_thickness * (1 - compression);
gasket_rim = 1.5;

// power switch slider
switch_protruction = 1;
slider_immersion_depth = 0.5;
slider_total_height = switch_protruction + bottom_thickness + bottom_gap + kailh_sockets_thickness + fr4_thickness - 0.5;

// USB
w_shell = 8.94;
h_shell = 3.26;
r_corner = 1.2;
pcb_usb_distance = 9;
Z_USB = h_shell / 2 + bottom_gap + kailh_sockets_thickness + fr4_thickness+ pcb_usb_distance;
usb_main_offset = [139.9, -76, Z_USB];
usb_tunnel_offset = [139.9, -28, Z_USB];
usb_tunnel_len_mm = 50;

// Screw positions & sizes
heat_sink_insert_diameter = 2.7;
heat_sink_insert_depth = 3.1;
screw_diameter = 2.5;
thread_length = 4;
head_diameter = 4.5;
thread_intrusion = 2;
screw_support_diameter = 6;
screw_marker_diameter = 1;


//rim
rim = 1;
rim_height = 1;
rim_clear = 0.2;

// Clearances
clear_pcb_mm = 1.0;
clear_gasket_mm = 0.5;
clear_usb_mm = 0.5;
clear_switch_mm = 0.2;
reset_button_thick = 0.2;
screw_support_clearance = 0.2;

// Derived
Z_LID_BASE = 0;
total_height_top_case = keycaps_cutout_height;
total_height_bottom_case= bottom_thickness + bottom_gap + pcb_and_plate_thickness;
Z_TOP_CASE = total_height_bottom_case+total_height_top_case;
total_gap=Z_TOP_CASE-bottom_thickness-top_case_thickness;
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
L_pwr_body_support = "pwr_body_support";
L_pwr_knob_cutout = "pwr_knob_cutout";
L_pwr_body_overhang = "pwr_body_overhang";
L_pwr_overhang_cutout = "pwr_overhang_cutout";
L_pwr_on_label = "pwr_on_label";
L_switches = "switches";
L_switchplate_outline = "switchplate_outline";
L_gasket_supports = "gasket_supports";
L_gasket_supports_rim = "gasket_supports_rim";
L_screw_markers = "screw_markers";

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
// -bottom_thickness


// -----------------------------------------------------------------------------
// ------------------------------- Helpers -------------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: extrude_layer --------------------
module extrude_layer(layer, z = 0, h = 1, delta = 0) { translate([0, 0, z]) linear_extrude(height=h) offset(delta=delta) import(file=DXF, layer=layer); }

// -------------------- Module: screw_hole_layer --------------------
module screw_hole_layer(z = 0, h = 1, target_diameter = screw_marker_diameter) {
  marker_delta = (target_diameter - screw_marker_diameter) / 2;
  extrude_layer(L_screw_markers, z=z, h=h, delta=marker_delta);
}

// -------------------- Module: top_insert_support --------------------
module top_insert_support() {
  screw_support_diameter_delta = (screw_support_diameter - screw_marker_diameter) / 2;
  heat_sink_insert_diameter_delta = (heat_sink_insert_diameter - screw_marker_diameter) / 2;
  difference() {
    extrude_layer(L_screw_markers, z=Z_TOP_CASE-top_case_thickness-heat_sink_insert_depth, h=heat_sink_insert_depth, delta=screw_support_diameter_delta);
    extrude_layer(L_screw_markers, z=Z_TOP_CASE-top_case_thickness-heat_sink_insert_depth, h=heat_sink_insert_depth, delta=heat_sink_insert_diameter_delta);
    }
}

// -------------------- Module: botton_screw_support --------------------
module bottom_screw_support() {
  screw_support_diameter_delta = (screw_support_diameter - screw_marker_diameter) / 2;
  head_diameter_delta = (head_diameter - screw_marker_diameter) / 2;
  screw_diameter_delta = (screw_diameter - screw_marker_diameter) / 2;
  difference() {
    extrude_layer(L_screw_markers, z=bottom_thickness, h=total_gap-heat_sink_insert_depth-screw_support_clearance, delta=screw_support_diameter_delta);
    extrude_layer(L_screw_markers, z=bottom_thickness, h=total_gap-(thread_length-thread_intrusion)-heat_sink_insert_depth, delta=head_diameter_delta);
    extrude_layer(L_screw_markers, z=bottom_thickness, h=total_gap-heat_sink_insert_depth, delta=screw_diameter_delta);
    }
}

// -----------------------------------------------------------------------------
// ------------------------------ Extruded Components --------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: outer_shape_top --------------------
module outer_shape_top() {
  difference() {
  union() {
    extrude_layer(L_outer_shape,  z=total_height_bottom_case, h=fillet_radius);
    minkowski() { sphere(fillet_radius); translate([0, 0, total_height_bottom_case+fillet_radius]) extrude_layer(L_outer_shape, h=total_height_top_case - 2 * fillet_radius, delta= - fillet_radius); }
  }
  extrude_layer(L_outer_shape, total_height_bottom_case, h=total_height_top_case-top_case_thickness, delta=-case_wall_thickness);
  }
}

// -------------------- Module: outer_shape_bottom --------------------
module outer_shape_bottom() {
  difference() {
    union() {
      extrude_layer(L_outer_shape,  z=fillet_radius, h=total_height_bottom_case-fillet_radius);
      minkowski() { sphere(fillet_radius); translate([0, 0, fillet_radius]) extrude_layer(L_outer_shape, h=total_height_bottom_case - 2 * fillet_radius, delta= - fillet_radius); }
    }
    extrude_layer(L_outer_shape, z= bottom_thickness, h=total_height_bottom_case-bottom_thickness, delta=-case_wall_thickness);
  }
}

// -------------------- Module: case_rim --------------------
module case_rim(delta = 0) {
  difference() {
    extrude_layer(L_outer_shape, z=total_height_bottom_case, h=rim_height+delta, delta=-case_wall_thickness/2+rim/2+delta/2);
    extrude_layer(L_outer_shape, z=total_height_bottom_case, h=rim_height+delta, delta=-case_wall_thickness/2-rim/2-delta/2);
    }
}


// -------------------- Module: upper_gasket_supports --------------------
module upper_gasket_supports() {
  difference() {
    extrude_layer(L_gasket_supports, z= bottom_thickness + kailh_sockets_thickness + bottom_gap + fr4_thickness + switchplate_thickness + compressed_gasket_thickness, h=fr4_thickness + keycaps_cutout_height- decoration_cutout_depth - compressed_gasket_thickness, delta = 0.2);
    extrude_layer(L_pcb_outline, z= bottom_thickness + kailh_sockets_thickness + bottom_gap + fr4_thickness + switchplate_thickness + compressed_gasket_thickness, h=fr4_thickness + keycaps_cutout_height- decoration_cutout_depth - compressed_gasket_thickness, delta = 0.2);
  }
}

// -------------------- Module: lower_gasket_supports --------------------
module lower_gasket_supports() {
  difference() {
    extrude_layer(L_gasket_supports, z=bottom_thickness, h=bottom_gap + kailh_sockets_thickness + fr4_thickness - compressed_gasket_thickness);
    extrude_layer(L_pcb_outline, z=bottom_thickness, h=bottom_gap + kailh_sockets_thickness + fr4_thickness - compressed_gasket_thickness, delta=clear_gasket_mm);
    }
}

// -------------------- Module: lower_gasket_supports_rim --------------------
module lower_gasket_supports_rim() {
    difference() {
    extrude_layer(L_gasket_supports_rim, z=bottom_thickness, h=bottom_gap + kailh_sockets_thickness + fr4_thickness + compressed_gasket_thickness + gasket_rim);
    extrude_layer(L_pcb_outline, z=bottom_thickness, h=bottom_gap + kailh_sockets_thickness + fr4_thickness + compressed_gasket_thickness + gasket_rim, delta=clear_gasket_mm);
    }
 
}

// -------------------- Module: pcb_stack --------------------
module pcb_stack() { extrude_layer(L_pcb_outline, z=bottom_thickness, h= bottom_gap + pcb_and_plate_thickness, delta=clear_pcb_mm); }

// -------------------- Module: keycaps_cutout --------------------
module keycaps_cutout() { extrude_layer(L_keycaps_outline, h=Z_TOP_CASE, delta=2 * keycaps_gap); }

// -------------------- Module: controller_cutout --------------------
module controller_cutout() { extrude_layer(L_controller_cutout, h=Z_TOP_CASE - controller_cover_thickness, delta=clear_usb_mm); }



// -------------------- Module: case_screw_holes --------------------
module case_screw_holes() { screw_hole_layer(h=heat_sink_insert_depth, target_diameter=heat_sink_insert_diameter); }

// -------------------- Module: lid_screw_holes --------------------
module lid_screw_holes() { screw_hole_layer(h=bottom_thickness, target_diameter=head_diameter); }


// -----------------------------------------------------------------------------
// ------------------------------ Buttons, Switches, USB------------------------
// -----------------------------------------------------------------------------


// -------------------- Module: pwr_switch_slider_cutout --------------------
module pwr_switch_slider_cutout(delta = 0) { extrude_layer(L_pwr_lid_cutout, h=bottom_thickness, delta=delta); }

// -------------------- Module: power_switch_overhang_cutout --------------------
module power_switch_overhang_cutout(delta = 0) { extrude_layer(L_pwr_overhang_cutout, z=bottom_thickness-slider_immersion_depth , h=slider_total_height, delta=delta); }

// -------------------- Module: power_switch_slider --------------------
module power_switch_slider() {
  difference() {
    extrude_layer(L_pwr_body, z=-switch_protruction, h=slider_total_height);
    extrude_layer(L_pwr_knob_cutout, z= bottom_thickness, h=slider_total_height - bottom_thickness);
    translate([0, 0, -switch_protruction]) linear_extrude(height=0.2) import(file=DXF, layer=L_pwr_on_label);
  }
  extrude_layer(L_pwr_body_overhang, z= bottom_thickness-slider_immersion_depth, h=bottom_gap/2);
}

// -------------------------Module: power body support----------------------------------
module power_body_support() {
  extrude_layer(L_pwr_body_support, z= bottom_thickness, h=slider_total_height);
}

// -------------------- Module: reset_cutout --------------------
module reset_cutout(delta = 0) { extrude_layer(L_reset, h=bottom_thickness, delta=delta); }

// -------------------- Module: reset_switch_button --------------------
module reset_switch_button() {
  extrude_layer(L_reset, z= -switch_protruction, h=bottom_thickness+switch_protruction);
  extrude_layer(L_reset, z=bottom_thickness, h=bottom_gap, delta=1);
}

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

// -----------------------------------------------------------------------------
// ------------------------------ Decorations ----------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: top_plate_decor_cutout --------------------
module top_plate_decor_cutout() {
    extrude_layer(L_outer_shape_decor, z=Z_TOP_CASE-decoration_cutout_depth, h=decoration_cutout_depth);  
}

// -------------------- Module: top_plate_decor --------------------
module top_plate_decor() {
    difference(){
        extrude_layer(L_outer_shape_decor, z=Z_TOP_CASE-decoration_cutout_depth , h=decoration_cutout_depth, delta=-decoration_line_width); 
        keycaps_cutout();
    }
}

// -------------------- Module: top_plate_decor_lines_cutout --------------------
module top_plate_decor_lines_cutout() {
    extrude_layer(L_decor_lines, z=Z_TOP_CASE-decoration_cutout_depth , h=decoration_cutout_depth);  
}


// -----------------------------------------------------------------------------
// ------------------------------ Assemblies -----------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: top_case --------------------
module top_case() {
  difference() {
  union() {
    outer_shape_top();
    top_insert_support();
    upper_gasket_supports();
  }
    power_switch_overhang_cutout(delta=clear_switch_mm);
    keycaps_cutout();
    case_screw_holes();
    top_plate_decor_cutout();
    top_plate_decor_lines_cutout();
    controller_cutout();
    usb_c_cutout_position();
    case_rim(rim_clear);  
  }
    top_plate_decor();
}

// -------------------- Module: bottom_case --------------------
module bottom_case() {
  difference() {
  union() {
    outer_shape_bottom();
    lower_gasket_supports();
    lower_gasket_supports_rim();
    power_body_support();
    case_rim();
    bottom_screw_support();
  }
    reset_cutout(0.2);
    lid_screw_holes();
    pwr_switch_slider_cutout(delta=clear_switch_mm);
    power_switch_overhang_cutout(delta=clear_switch_mm);
    usb_c_cutout_position();
  }
}

// -------------------- Module: switchplate foam --------------------
module switchplate_foam() {
  difference() {
    union() {
      extrude_layer(L_gasket_supports, z=bottom_thickness + kailh_sockets_thickness + bottom_gap + fr4_thickness, h=switchplate_thickness);
      difference() {
        extrude_layer(L_switchplate_outline, z=bottom_thickness + kailh_sockets_thickness + bottom_gap + fr4_thickness, h=switchplate_thickness);
        extrude_layer(L_switches, z=bottom_thickness + kailh_sockets_thickness + bottom_gap + fr4_thickness, h=switchplate_thickness, delta=0.3);
      }
    }
  extrude_layer(L_gasket_supports_rim, z=bottom_thickness + kailh_sockets_thickness + bottom_gap + fr4_thickness, h=switchplate_thickness, delta= 0.5);
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
    translate([0, 0, -3 * EXPLODE]) bottom_case();
  } else if (PART == "top_case")
    top_case();
  else if (PART == "switch_plate_foam")
    switchplate_foam();
  else if (PART == "power_switch_slider")
    power_switch_slider();
  else if (PART == "reset_switch_button")
    reset_switch_button();
  else if (PART == "bottom_case")
    bottom_case();
  else if (PART == "tent")
    tent();
  else
    echo(str("Unknown PART: ", PART));
}

build();
