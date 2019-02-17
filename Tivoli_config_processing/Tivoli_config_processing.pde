class Ring
{
  float x, y, size, intensity, hue;

  void respawn(float x1, float y1, float x2, float y2)
  {
    // Start at the newer mouse position
    x = x2;
    y = y2;

    // Intensity is just the distance between mouse points
    intensity = dist(x1, y1, x2, y2) * 1.5;
    // println(intensity);

    // Hue is the angle of mouse movement, scaled from -PI..PI to 0..100
    hue = map(atan2(y2 - y1, x2 - x1), -PI, PI, 0, 100);

    // Default size is based on the screen size
    size = height * 0.025;
  }

  void draw()
  {
    intensity *= 0.825;

    // They grow at a rate based on their intensity
    size += height * 1.75 * intensity * 0.01;  //  0.0085

    if (size > 725) {  
      // size = size - 50;
      size = 725;
      intensity *= 0.98;
    }

    // If the particle is still alive, draw it
    if (intensity >= 1) {
      blendMode(ADD);
      tint(hue, 30, intensity); //25
      image(texture, x - size/2, y - size/2, size, size);
    }
  }
};


import apsync.*;
import processing.serial.*;
AP_Sync streamer;

OPC opc;                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
PImage texture;
Ring rings[];

public String sensorInput;
public String oldSensorInput;

float smooth0X, smooth0Y, smooth1X, smooth1Y, smooth2X, smooth2Y;
float sensorSmooth0X, sensorSmooth1X, sensorSmooth2X, sensorSmooth3X, sensorSmooth4X, sensorSmooth5X, sensorSmooth6X, sensorSmooth7X, sensorSmooth8X, sensorSmooth9X;
float sensorSmooth0Y, sensorSmooth1Y, sensorSmooth2Y, sensorSmooth3Y, sensorSmooth4Y, sensorSmooth5Y, sensorSmooth6Y, sensorSmooth7Y, sensorSmooth8Y, sensorSmooth9Y;

long standbyCounter = 0;
int placeholder;

int endPos0X, endPos1X, endPos2X, endPos3X, endPos4X, endPos5X, endPos6X, endPos7X, endPos8X, endPos9X = 0;
int endPos0Y, endPos1Y, endPos2Y, endPos3Y, endPos4Y, endPos5Y, endPos6Y, endPos7Y, endPos8Y, endPos9Y = 0;

boolean flag0, flag1, flag2, flag3, flag4, flag5, flag6, flag7, flag8, flag9 = false;

int pointX = 167;                                                                          
int pointY = 277;


float prev0X = random(width);
float prev1X = random(width);

float prev0Y = random(height);
float prev1Y = random(height);

int rand0X = int(random(width)); 
int rand1X = int(random(width)); 
int rand2X = int(random(width)); 

float rand0Y = random(height);
float rand1Y = random(height);
float rand2Y = random(height);

float smoothMouseX, smoothMouseY;

float minute, hour;

void setup()
{
  // streamer = new AP_Sync(this, "/dev/ttyUSB0", 9600);

  frameRate(22);

  size(335, 555, P3D);
  colorMode(HSB, 100);
  texture = loadImage("ring.png");

  opc = new OPC(this, "127.0.0.1", 7890);

  // ------------- 1 ------------- // 
  opc.ledStrip(0 * 44, 44, 75, 145, 320 / 42, PI * -0.35, false); // 0.35
  opc.ledStrip(1 * 44, 44, 85, 145, 320 / 42, PI * -0.35, false);
  opc.ledStrip(2 * 44, 44, 95, 145, 320 / 42, PI * -0.35, false);
  //opc.ledStrip(3 * 44, 44, 105, 145, 320 / 42, PI * -0.35, true);

  // ------------- 2 ------------- // 
  opc.ledStrip(4 * 44, 44, 75, 420, 320 / 42, PI * -0.65, true); // 0.65
  opc.ledStrip(5 * 44, 44, 85, 420, 320 / 42, PI * -0.65, true); // 0.65
  opc.ledStrip(6 * 44, 44, 95, 420, 320 / 42, PI * -0.65, true);
  //opc.ledStrip(7 * 44, 44, 105, 420, 320 / 42, PI * -0.65, false);

  // ------------- 3 ------------- // 
  opc.ledStrip(8  * 44, 44, 240, 145, 320 / 42, PI * 0.35, false);
  opc.ledStrip(9  * 44, 44, 250, 145, 320 / 42, PI * 0.35, false);
  opc.ledStrip(10 * 44, 44, 260, 145, 320 / 42, PI * 0.35, false);
  //opc.ledStrip(11 * 44, 44, 270, 145, 320 / 42, PI * 0.35, true);

  // ------------- 4 ------------- // 
  opc.ledStrip(12 * 44, 44, 240, 420, 320 / 42, PI * 0.65, true);
  opc.ledStrip(13 * 44, 44, 250, 420, 320 / 42, PI * 0.65, true);
  opc.ledStrip(14 * 44, 44, 260, 420, 320 / 42, PI * 0.65, true);

  // We can have up to 100 rings. They all start out invisible.
  rings = new Ring[100];
  for (int i = 0; i < rings.length; i++) {
    rings[i] = new Ring();
  }

  // ------- sensor start wave pos -------- //

  // ------- left side -------- //
  // ------- sensor 0 -------- //
  sensorSmooth0X = width - 75;
  sensorSmooth0Y = 0;
  // ------- sensor 1 -------- //
  sensorSmooth1X = width + 100;
  sensorSmooth1Y = 100;
  // ------- sensor 2 -------- //
  sensorSmooth2X = width + 200;
  sensorSmooth2Y = height/2;
  // ------- sensor 3 -------- //
  sensorSmooth3X = width + 100;
  sensorSmooth3Y = height - 200;
  // ------- sensor 4 -------- //
  sensorSmooth4X = width-75;
  sensorSmooth4Y = height;

  // ------- right side -------- //
  // ------- sensor 5 -------- //
  sensorSmooth5X = 100;
  sensorSmooth5Y = height - 100;
  // ------- sensor 6 -------- //
  sensorSmooth6X = - 100;
  sensorSmooth6Y = height - 100;
  // ------- sensor 7 -------- //
  sensorSmooth7X = - 200;
  sensorSmooth7Y = height/2;
  // ------- sensor 8 -------- //
  sensorSmooth8X = -100;
  sensorSmooth8Y = 100;
  // ------- sensor 9 -------- //
  sensorSmooth9X = 0;
  sensorSmooth9Y = 0;
  
}

void draw()
{
  background(0);
  //hour = hour();
  // ------- set timer -------- // 
  //if (hour >= 10 && hour <= 23) {    // what time...............
  // ------- sensor input mode -------- // 

  print("sensorInput: ");
  println(sensorInput);

  if (oldSensorInput != sensorInput && sensorInput != null ) {
    placeholder = int(sensorInput);

    if (placeholder == 0) {
      flag0 = true;
    }   
    if (placeholder == 1) {
      flag1 = true;
    }
    if (placeholder == 2) {
      flag2 = true;
    }
    if (placeholder == 3) {
      flag3 = true;
    }
    if (placeholder == 4) {
      flag4 = true;
    }
    if (placeholder == 5) {
      flag5 = true;
    }
    if (placeholder == 6) {
      flag6 = true;
    }
    if (placeholder == 7) {
      flag7 = true;
    }
    if (placeholder == 8) {
      flag8 = true;
    }
    if (placeholder == 9) {
      flag9 = true;
    }
  }

  float prevSesnor0X = sensorSmooth0X;
  float prevSensor0Y = sensorSmooth0Y;

  float prevSesnor1X = sensorSmooth1X;
  float prevSensor1Y = sensorSmooth1Y;

  float prevSesnor2X = sensorSmooth2X;
  float prevSensor2Y = sensorSmooth2Y;

  float prevSesnor3X = sensorSmooth3X;
  float prevSensor3Y = sensorSmooth3Y;

  float prevSesnor4X = sensorSmooth4X;
  float prevSensor4Y = sensorSmooth4Y;

  float prevSesnor5X = sensorSmooth5X;
  float prevSensor5Y = sensorSmooth5Y;

  float prevSesnor6X = sensorSmooth6X;
  float prevSensor6Y = sensorSmooth6Y;

  float prevSesnor7X = sensorSmooth7X;
  float prevSensor7Y = sensorSmooth7Y;

  float prevSesnor8X = sensorSmooth8X;
  float prevSensor8Y = sensorSmooth8Y;

  float prevSesnor9X = sensorSmooth9X;
  float prevSensor9Y = sensorSmooth9Y;

  if (flag8) {
    endPos8X = pointX + 100;
    endPos8Y = pointY;

    sensorSmooth8X += (endPos8X - sensorSmooth8X) * 0.175;
    sensorSmooth8Y += (endPos8Y - sensorSmooth8Y) * 0.175;

    if ((sensorSmooth8X + .4 > endPos0X) && (sensorSmooth8Y + .4 > endPos8Y)) {

      sensorSmooth8X = - 100;
      sensorSmooth8Y = height + 200;

      prevSesnor8X = sensorSmooth8X;
      prevSensor8Y = sensorSmooth8Y;

      flag8 = false;
      sensorInput = null;
      placeholder = 99;
    }
  }  
  if (flag9) {
    endPos9X = pointX + 100;
    endPos9Y = pointY;

    sensorSmooth9X += (endPos9X - sensorSmooth9X) * 0.175;
    sensorSmooth9Y += (endPos9Y - sensorSmooth9Y) * 0.175;

    if ((sensorSmooth9X + .4 > endPos9X) && (sensorSmooth9Y + .4 > endPos9Y)) {
      
      sensorSmooth9X = - 200;
      sensorSmooth9Y = height - 100;

      prevSesnor9X = sensorSmooth9X;
      prevSensor9Y = sensorSmooth9Y;

      flag9 = false;
      sensorInput = null;
      placeholder = 99;
    }
  } 
  if (flag0) {
    endPos0X = pointX + 100;
    endPos0Y = pointY;

    sensorSmooth0X += (endPos0X - sensorSmooth0X) * 0.175;
    sensorSmooth0Y += (endPos0Y - sensorSmooth0Y) * 0.175;

    if ((sensorSmooth0X - .4 < endPos0X) && (sensorSmooth0Y + .4 > endPos0Y)) {
      
      sensorSmooth0X = - 300;
      sensorSmooth0Y = height/2;

      prevSesnor0X = sensorSmooth0X;
      prevSensor0Y = sensorSmooth0Y;

      flag0 = false;
      sensorInput = null;
      placeholder = 99;
    }
  }  
  if (flag1) {
    endPos1X = pointX + 100;
    endPos1Y = pointY;

    sensorSmooth1X += (endPos1X - sensorSmooth1X) * 0.175;
    sensorSmooth1Y += (endPos1Y - sensorSmooth1Y) * 0.175;

    if ((sensorSmooth1X - .4  < endPos1X) && (sensorSmooth1Y - .4 < endPos1Y)) {

      sensorSmooth1X = 100;
      sensorSmooth1Y = - 200;

      prevSesnor1X = sensorSmooth1X;
      prevSensor1Y = sensorSmooth1Y;

      flag1 = false;
      sensorInput = null;
      placeholder = 99;
    }
  }  

  if (flag2) {
    endPos2X = pointX + 100;
    endPos2Y = pointY;

    sensorSmooth2X += (endPos2X - sensorSmooth2X) * 0.175;
    sensorSmooth2Y += (endPos2Y - sensorSmooth2Y) * 0.175;

    if ((sensorSmooth2X - .4 < endPos2X) && (sensorSmooth2Y - .4 < endPos2Y)) {
      
      sensorSmooth2X = width - 75;
      sensorSmooth2Y = height + 100;

      prevSesnor2X = sensorSmooth2X;
      prevSensor2Y = sensorSmooth2Y;

      flag2 = false;
      sensorInput = null;
      placeholder = 99;
    }
  } 
  if (flag3) {
    endPos3X = pointX - 100;
    endPos3Y = pointY;

    sensorSmooth3X += (endPos3X - sensorSmooth3X) * 0.175;
    sensorSmooth3Y += (endPos3Y - sensorSmooth3Y) * 0.175;

    if ((sensorSmooth3X + .4 > endPos3X) && (sensorSmooth3Y + .4 > endPos3Y)) {

      sensorSmooth3X = width - 100;
      sensorSmooth3Y = - 200;

      prevSesnor3X = sensorSmooth3X;
      prevSensor3Y = sensorSmooth3Y;

      flag3 = false;
      sensorInput = null;
      placeholder = 99;
    }
  } 
  if (flag4) {
    endPos4X = pointX - 100;
    endPos4Y = pointY;

    sensorSmooth4X += (endPos4X - sensorSmooth4X) * 0.175;
    sensorSmooth4Y += (endPos4Y - sensorSmooth4Y) * 0.175;

    if ((sensorSmooth4X + .4 > endPos4X) && (sensorSmooth4Y + .4 > endPos4Y)) {
      
      sensorSmooth4X = width + 200;
      sensorSmooth4Y = 100;

      prevSesnor4X = sensorSmooth4X;
      prevSensor4Y = sensorSmooth4Y;

      flag4 = false;
      sensorInput = null;
      placeholder = 99;
    }
  } 
  if (flag5) {
    endPos5X = pointX - 100;
    endPos5Y = pointY;

    sensorSmooth5X += (endPos5X - sensorSmooth5X) * 0.175;
    sensorSmooth5Y += (endPos5Y - sensorSmooth5Y) * 0.175;

    if ((sensorSmooth5X + .4 > endPos5X) && (sensorSmooth5Y + .4 > endPos5Y)) {

      sensorSmooth5X = width + 250;
      sensorSmooth5Y = height/2;

      prevSesnor5X = sensorSmooth5X;
      prevSensor5Y = sensorSmooth5Y;

      flag5 = false;
      sensorInput = null;
      placeholder = 99;
    }
  }  
  if (flag6) {
    endPos6X = pointX - 100;
    endPos6Y = pointY;

    sensorSmooth6X += (endPos6X - sensorSmooth6X) * 0.175;
    sensorSmooth6Y += (endPos6Y - sensorSmooth6Y) * 0.175;

    if ((sensorSmooth6X + .4 > endPos6X) && (sensorSmooth6Y + .4 > endPos6Y)) {

      sensorSmooth6X = width + 200;
      sensorSmooth6Y = height - 100;

      prevSesnor6X = sensorSmooth6X;
      prevSensor6Y = sensorSmooth6Y;

      flag6 = false;
      sensorInput = null;
      placeholder = 99;
    }
  }  
  if (flag7) {
    endPos7X = pointX - 100;
    endPos7Y = pointY;

    sensorSmooth7X += (endPos7X - sensorSmooth7X) * 0.175;
    sensorSmooth7Y += (endPos7Y - sensorSmooth7Y) * 0.175;

    if ((sensorSmooth7X + .4 > endPos7X) && (sensorSmooth7Y + .4 > endPos7Y)) {

      sensorSmooth7X = - 200;
      sensorSmooth7Y = 100;

      prevSesnor7X = sensorSmooth7X;
      prevSensor7Y = sensorSmooth7Y;

      flag7 = false;
      sensorInput = null;
      placeholder = 99;
    }
  }

  rings[int(random(rings.length))].respawn(prevSesnor0X, prevSensor0Y, sensorSmooth0X, sensorSmooth0Y);
  rings[int(random(rings.length))].respawn(prevSesnor1X, prevSensor1Y, sensorSmooth1X, sensorSmooth1Y);
  rings[int(random(rings.length))].respawn(prevSesnor2X, prevSensor2Y, sensorSmooth2X, sensorSmooth2Y);
  rings[int(random(rings.length))].respawn(prevSesnor3X, prevSensor3Y, sensorSmooth3X, sensorSmooth3Y);
  rings[int(random(rings.length))].respawn(prevSesnor4X, prevSensor4Y, sensorSmooth4X, sensorSmooth4Y);
  rings[int(random(rings.length))].respawn(prevSesnor5X, prevSensor5Y, sensorSmooth5X, sensorSmooth5Y);
  rings[int(random(rings.length))].respawn(prevSesnor6X, prevSensor6Y, sensorSmooth6X, sensorSmooth6Y);
  rings[int(random(rings.length))].respawn(prevSesnor7X, prevSensor7Y, sensorSmooth7X, sensorSmooth7Y);
  rings[int(random(rings.length))].respawn(prevSesnor8X, prevSensor8Y, sensorSmooth8X, sensorSmooth8Y);
  rings[int(random(rings.length))].respawn(prevSesnor9X, prevSensor9Y, sensorSmooth9X, sensorSmooth9Y);

  oldSensorInput = sensorInput;

  if (sensorInput == null) {
    standbyCounter++;
  } else {
    standbyCounter = 0;
  }

  /*
    // ------- remove in production!!! -------- // 
   float prevMouseX = smoothMouseX;
   float prevMouseY = smoothMouseY;
   
   smoothMouseX += (mouseX - smoothMouseX) * 0.185;
   smoothMouseY += (mouseY - smoothMouseY) * 0.185;
   
   rings[int(random(rings.length-1, rings.length))].respawn(prevMouseX, prevMouseY, smoothMouseX, smoothMouseY);    
   */

  // ------- Standby mode -------- //

  if (standbyCounter > 100 && standbyCounter < 45000 ) {    //  Value about 250 / 500
    //println("Standby mode...");

    // ------- make sure that counter doesn't overspill -------- // 
    if (standbyCounter > 500000) {
      standbyCounter = 0;
    }

    prev0X = smooth0X;
    prev0Y = smooth0Y;

    prev1X = smooth1X;
    prev1Y = smooth1Y;

    // float prev2X = smooth2X;
    // float prev2Y = smooth2Y;

    smooth0X += (rand0X - smooth0X) * 0.100;
    smooth0Y += (rand0Y - smooth0Y) * 0.110;

    smooth1X += (rand1X - smooth1X) * 0.100;  //050
    smooth1Y += (rand1Y - smooth1Y) * 0.110;  //070

    //smooth2X += (rand2X - smooth2X) * 0.060;
    //smooth2Y += (rand2Y - smooth2Y) * 0.070;

    if (smooth0X + .5 > rand0X && smooth0Y + .5 > rand0Y) {
      rand0X = int(random(-240, width + 240));
      rand0Y = int(random(-240, height + 240));
    }
    if (smooth1X + .4 > rand1X && smooth1Y + .4 > rand1Y) {
      rand1X = int(random(-240, width + 240));
      rand1Y = int(random(-240, height + 240));
    }
    //if (smooth2X + 1 > rand2X && smooth2Y + 1 > rand2Y) {
    //  rand2X = int(random(-100, width + 100));
    //  rand2Y = int(random(-200, height + 200));
    //}

    rings[int(random(rings.length))].respawn(prev0X + 80, prev0Y, smooth0X, smooth0Y);
    rings[int(random(rings.length))].respawn(prev1X + 80, prev1Y, smooth1X, smooth1Y);
    // rings[int(random(rings.length))].respawn(prev2X, prev2Y, smooth2X, smooth2Y);
  }
  // ------- Update OPC -------- // 
  for (int i = 0; i < rings.length; i++) {
    rings[i].draw();
  }
  //}
}
