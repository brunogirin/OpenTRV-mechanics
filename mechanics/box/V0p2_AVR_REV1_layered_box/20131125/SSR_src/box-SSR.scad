/*
The OpenTRV project licenses this file to you
under the Apache Licence, Version 2.0 (the "Licence");
you may not use this file except in compliance
with the Licence. You may obtain a copy of the Licence at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the Licence is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the Licence for the
specific language governing permissions and limitations
under the Licence.

Author(s) / Copyright (s): Bruno Girin 2013
*/

include <settings-SSR.scad>;
include <box-common.scad>;
include <bitmap.scad>;

module nut_recess(height) {
    cylinder(
        r = nut_recess_radius,
        h = height + 0.1,
        $fn=cylinder_resolution);
}

module nut_recesses(height) {
    union() {
        translate([
            -pcb_width / 2 + mounting_hole_pcb_offset,
            -pcb_length / 2 + mounting_hole_pcb_offset,
            0])
        nut_recess(height);
        translate([
            +pcb_width / 2 - mounting_hole_pcb_offset,
            -pcb_length / 2 + mounting_hole_pcb_offset,
            0])
        nut_recess(height);
        translate([
            +pcb_width / 2 - mounting_hole_pcb_offset,
            +pcb_length / 2 - mounting_hole_pcb_offset,
            0])
        nut_recess(height);
        translate([
            -pcb_width / 2 + mounting_hole_pcb_offset,
            +pcb_length / 2 - mounting_hole_pcb_offset,
            0])
        nut_recess(height);
    }
}

module layer_0_0(thickness=layer_0_0_thickness) {
    difference() {
        box_base(thickness);
        box_mounting_holes(thickness);
        box_wall_mount_screw_holes(thickness);
        translate([0, 0, -0.1])
            nut_recesses(nut_recess_height);
    }
}

module layer_0_1(thickness=layer_0_1_thickness) {
    difference() {
        box_spacer_layer(thickness);
        
    }
}

module layer_0_2(thickness=layer_0_2_thickness) {
    difference() {
        box_base(thickness);
        pcb_hole(thickness, hole_fudge_factor);
        
    }
}

module layer_0() {
    difference() {
        union() {
            layer_0_0(layer_0_0_thickness);
            translate([0, 0, layer_0_0_thickness - 0.1])
                layer_0_1(layer_0_1_thickness + 0.1);
            translate([0, 0, layer_0_0_thickness + layer_0_1_thickness - 0.1])
                layer_0_2(layer_0_2_thickness + 0.1);
        }
        for ( hoffset = [-10 : 5 : 10] ) {
            ventilation_slit(TOP, layer_0_1_thickness, box_wall_width, hoffset, layer_0_0_thickness);
            ventilation_slit(BOTTOM, layer_0_1_thickness, box_wall_width, hoffset, layer_0_0_thickness);
            ventilation_slit(RIGHT, layer_0_1_thickness, box_wall_width, hoffset, layer_0_0_thickness);
        }
        for ( hoffset = [-10 : 5 :  0] ) {
            ventilation_slit(LEFT, layer_0_1_thickness, box_wall_width, hoffset, layer_0_0_thickness);
        }
    }
}

module layer_1_0(thickness=box_layer_thickness) {
    box_spacer_layer(thickness);
}

module layer_1_1(thickness=box_layer_thickness) {
    difference() {
        box_spacer_layer(thickness);
        
        box_outside_hole(
            wire_hole_boiler_side,
            wire_hole_boiler_width,
            box_wall_width + 0.1,
            wire_hole_boiler_offset,
            thickness
        );
        
    }
}

module layer_1() {
    union() {
        layer_1_0(layer_1_0_thickness);
        translate([0, 0, layer_1_0_thickness - 0.1])
            layer_1_1(layer_1_1_thickness + 0.1);
    }
}

module layer_2() {
    box_spacer_layer(layer_2_thickness);
}

module spacer() {
    cylinder(
        r = 2nd_board_spacer_radius,
        h = 2nd_board_spacer_height + 0.1,
        $fn=cylinder_resolution);
}

module spacers() {
    translate([
            -2nd_board_spacer_distance_x / 2,
             2nd_board_spacer_distance_y / 2,
             0])
        spacer();
    translate([
             2nd_board_spacer_distance_x / 2,
             2nd_board_spacer_distance_y / 2,
             0])
        spacer();
    translate([
            -2nd_board_spacer_distance_x / 2,
            -2nd_board_spacer_distance_y / 2,
             0])
        spacer();
    translate([
             2nd_board_spacer_distance_x / 2,
            -2nd_board_spacer_distance_y / 2,
             0])
        spacer();
}

module spacer_hole() {
    translate([0, 0, -0.1])
        cylinder(
            r = pcb_mounting_hole_radius * 2nd_board_spacer_hole_ratio,
            h = 2nd_board_spacer_hole_height + 0.1,
            $fn=cylinder_resolution);
}

module spacer_holes() {
    translate([
            -2nd_board_spacer_distance_x / 2,
             2nd_board_spacer_distance_y / 2,
             0])
        spacer_hole();
    translate([
             2nd_board_spacer_distance_x / 2,
             2nd_board_spacer_distance_y / 2,
             0])
        spacer_hole();
    translate([
            -2nd_board_spacer_distance_x / 2,
            -2nd_board_spacer_distance_y / 2,
             0])
        spacer_hole();
    translate([
             2nd_board_spacer_distance_x / 2,
            -2nd_board_spacer_distance_y / 2,
             0])
        spacer_hole();
}

module layer_3() {
    corner_offset = 2nd_board_spacer_radius * sqrt(2) / 2;
    difference() {
        union() {
            difference() {
                box_base(layer_3_thickness);
                box_mounting_holes(layer_3_thickness);
                
                /* SSR label */
                translate([
                    -2nd_board_spacer_distance_x / 8,
                    2nd_board_spacer_distance_y / 1.5,
                    layer_3_thickness - label_recess_depth + 0.1
                    ])
                rotate(a = -90, v = [0, 0, 1])
                    8bit_str(label_s_chars, label_s_char_count, label_block_size, label_recess_depth + 0.1);
                /* OpenTRV label */
                translate([
                    -label_opentrv_char_count * 3.5 * label_block_size,
                    -pcb_length / 4,
                    layer_3_thickness - label_recess_depth + 0.1
                    ])
                rotate(a = -90, v = [0, 0, 1])
                    8bit_str(label_opentrv_chars, label_opentrv_char_count, label_block_size, label_recess_depth + 0.1);
                /* Recesses */
                translate([0, 0, layer_3_thickness - bolt_head_recess_height])
                    nut_recesses(bolt_head_recess_height);
            }
            
        }
        
    }
}

layer_0();

translate([0, 0, 2 * layer_0_thickness])
    layer_1();

translate([0, 0, 2 * layer_0_thickness + 2 * layer_1_thickness])
    layer_2();

translate([0, 0, 2 * layer_0_thickness + 2 * layer_1_thickness + 2 * layer_2_thickness])
    layer_3();

