// Persistence of Vision Ray Tracer Scene Description File
// File: wa.pov
// Vers: 3.6
// Desc: Worms Armageddon logo
// Auth: CyberShadow
// +w1024 +h1024 +a0.001 -J0 +R5 +am2 +ua

#version 3.6;
#include "colors.inc"

// ----------------------------------------
// Configuration

#declare COLOR_OUTER      = Black ;
#declare COLOR_INNER      = Yellow;

#declare SPOKES           = 3;

// ----------------------------------------
// Global settings

global_settings {
  assumed_gamma 1.0
}

camera {
  orthographic
  location <0,0,5>     // position & direction of view
  look_at  <0,0,0>
  right 2*x            // horizontal size of view
  up 2*y               // vertical size of view
}

#default {
  texture {
    finish {
      ambient 1.0
      diffuse 0.0
    }
  }
}
  
background { color rgb <1,1,1,0> }

// ----------------------------------------
// Geometry

disc {
  <0,0,0.0>,<0,0,1>,1.0
  pigment { rgb COLOR_OUTER }
}

disc {
  <0,0,0.1>,<0,0,1>,1-(1/8)
  pigment { rgb COLOR_INNER }
}

disc {
  <0,0,0.2>,<0,0,1>,3/16
  pigment { rgb COLOR_OUTER }
}

intersection {
  difference {
    cylinder { <0,0,0.3>,<0,0,1>,1-(2/8) }
    cylinder { <0,0,0  >,<0,0,2>,5/16 }
  }
  union {
    #declare Spoke=0;
    #while (Spoke < SPOKES)
      difference {
        box { <-1,-1,0>,<1,0,1>}
        box { <-1,-1,0>,<1,0,1> rotate <0,0,(360/SPOKES/2)>}
        rotate <0,0,(360/SPOKES)*Spoke - (90+(360/SPOKES/4))> 
      }
      #declare Spoke=Spoke+1;
    #end
  }
  pigment { rgb COLOR_OUTER }
}
