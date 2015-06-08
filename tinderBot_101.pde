// Import the net libraries
import java.io.*;

import processing.net.*;

import controlP5.*;
import processing.video.*;
import http.requests.*;
import rekognition.faces.*;

import com.temboo.core.*;
import com.temboo.Library.Tumblr.Post.*;

//
// Create a session using your Temboo account application details
TembooSession session = new TembooSession("dattasaurabh82", "myFirstApp", "913f5105-8360-4642-8");

// Declare a server
Server s;
Client c;



Capture cam;
Rekognition rekog;

ControlP5 cp5;
Textlabel textlabelGR;
Textlabel preference;

PImage img;
RFace[] faces;

int event = 2;

//--------------
PFont cmnFont;

//---------------
boolean stPreference = true;
boolean generaResultant = false;

int Golden_Ratio = 36;
int bufferToRatio = 5;
boolean GR_resultant = true;

int Preferred_Age = 20;
int bufferAgeAddition = 4;
boolean age_resultant = true;

boolean Smile_Check = false;
boolean smile_resultant = true;

boolean Eye_Glass_Check = false;
boolean glass_resultant = true;

String[] encodedFileData = null;
String sringbase64 = "";

///////
import processing.serial.*;

Serial myPort ;
String port;
///////


void setup() {
  size(1280, 720);

  /////
  String[] SerialPort = Serial.list();
  println(SerialPort);
  myPort = new Serial(this, SerialPort[5], 9600);
  myPort.bufferUntil('\n');
  /////

  //frame.setIconImage(titlebaricon.getImage());

  frame.setTitle("Tinder Bot: image analyser server"); 

  // Create the Server on port 5204
  s = new Server(this, 3000); // Start a simple server on a port

  //------------
  cmnFont = loadFont("OCRAStd-10.vlw");
  textFont(cmnFont, 10);
  //------------

  cp5 = new ControlP5(this);

  PFont p = createFont("OCRAStd", 10); 
  cp5.setControlFont(p, 8);
  cp5.setColorLabel(color(255, 255, 255));

  //grouping panel
  Group g1 = cp5.addGroup("control elements")
    .setPosition(985, 68)
      .setBackgroundColor(color(0, 64))
        .setBackgroundHeight(230)
          .setHeight(12)
            .setWidth(240)
              ;

  preference = cp5.addTextlabel("labelOne")
    .setText("1ST PREFERENCE:")
      .setPosition(24, 4)
        .moveTo(g1)
          ;

  textlabelGR = cp5.addTextlabel("labelTwo")
    .setText("GR")
      .setPosition(27, 18)
        .moveTo(g1)
          ;

  Toggle a = cp5.addToggle("stPreference")
    .setPosition(50, 17)
      .setSize(60, 15)
        .setColorBackground(color(0, 0, 0, 100))
          .setColorActive(color(25, 25, 25))
            .setLabel("AGE")
              .setMode(ControlP5.SWITCH)
                .moveTo(g1)
                  ;
  controlP5.Label pl = a.captionLabel();
  pl.style().marginTop = -17; //move upwards (relative to button size)
  pl.style().marginLeft = 66; //move to the right
  //l2.getStyle().setPadding(2, 2, 2, 2);
  //l2.setColorBackground(color(10, 20, 30, 140));



  //golden ratio parameter selector
  cp5.addSlider("Golden_Ratio")
    .setPosition(10, 40)
      .setSize(100, 15)
        .setRange(10, 60)
          .setColorBackground(color(0, 0, 0, 100))
            .setColorForeground(color(25, 25, 25))
              .setColorActive(color(200, 15, 15)) 
                .moveTo(g1)
                  ;
  //golden ratio buffer parameter selector
  cp5.addSlider("bufferToRatio")
    .setLabel("Limit_to_ratio")
      .setPosition(10, 60)
        .setSize(100, 15)
          .setRange(4, 10)
            .setColorBackground(color(0, 0, 0, 100))
              .setColorForeground(color(25, 25, 25))
                .setColorActive(color(200, 15, 15)) 
                  .moveTo(g1)
                    ;

  //Age perefernce selector
  cp5.addSlider("Preferred_Age")
    .setPosition(10, 91)
      .setSize(100, 15)
        .setRange(15, 40)
          .setColorBackground(color(0, 0, 0, 100))
            .setColorForeground(color(25, 25, 25))
              .setColorActive(color(200, 15, 15)) 
                .moveTo(g1)
                  ;

  // Old age limit selection panel              ;
  cp5.addSlider("bufferAgeAddition")
    .setPosition(10, 111)
      .setSize(100, 15)
        .setRange(0, 20)
          .setColorBackground(color(0, 0, 0, 100))
            .setColorForeground(color(25, 25, 25))
              .setColorActive(color(200, 15, 15)) 
                .setLabel("Buffer_Age_Limit")
                  .moveTo(g1)
                    ;

  //Smiling check 
  //Would use some subtraction later
  Toggle t = cp5.addToggle("Smile_Check")
    .setPosition(10, 131)
      .setSize(25, 25)
        .setColorBackground(color(0, 0, 0, 100))
          .setColorForeground(color(200, 15, 15))
            .setColorActive(color(25, 25, 25))
              .setLabel("Smile_Check")
                .moveTo(g1)
                  ;
  controlP5.Label l1 = t.captionLabel();
  l1.style().marginTop = -24; //move upwards (relative to button size)
  l1.style().marginLeft = 30; //move to the right
  //l1.getStyle().setPadding(2, 2, 2, 2);
  //l1.setColorBackground(color(10, 20, 30, 140));


  //eye glasses check
  Toggle e = cp5.addToggle("Eye_Glass_Check")
    .setPosition(10, 160)
      .setSize(25, 25)
        .setColorBackground(color(0, 0, 0, 100))
          .setColorForeground(color(200, 15, 15))
            .setColorActive(color(25, 25, 25))
              .setLabel("Eye_Glass_Check")
                .moveTo(g1)
                  ;
  controlP5.Label l2 = e.captionLabel();
  l2.style().marginTop = -24; //move upwards (relative to button size)
  l2.style().marginLeft = 30; //move to the right
  //l2.getStyle().setPadding(2, 2, 2, 2);
  //l2.setColorBackground(color(10, 20, 30, 140));


  //saving setting and default setting

  cp5.addButton("b1", 0, 10, 210, 100, 14)
    .setCaptionLabel("load the default")
      .setColorBackground(color(0, 0, 0, 80))
        .setColorForeground(color(200, 15, 15))
          .setColorActive(color(25, 25, 25))
            .moveTo(g1);

  cp5.getProperties().addSet("current set");
  //cp5.getProperties().move(cp5.getController("Golden_Ratio"), "default", "current set");
  //-----------------------------------------------------------------
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 1280, 720);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    //println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      //println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  //----------------------------------------------------------------
  // load image for drawing
  //String filename = "data/" + "img.jpg";
  img = loadImage("data/" + "img.jpg");
  String api_key = "jHpLOKChgqfvxmmj";
  String api_secret = "fvpUD22kUhKBjEgs";
  rekog = new Rekognition(this, api_key, api_secret);

  //faces = rekog.detectFacesPath("data/"+filename);
}

void b1(float v) {
  cp5.loadProperties(("default.ser"));
}

void draw() {
  //background(200, 0, 10, 100);

  if (cam.available() == true) {
    cam.read();
  }
  //image(cam, 0, 0);

  if (event == 1) {
    // stop cam
    cam.stop();
    // save frame
    saveFrame("data/" + "img.jpg");
    // load frame
    // analyse
    // overlay information
    analysedImage();
    // save a frame from the current window
    // and store it not in the data folder
    // but outside with a different name
    //to load it next time
    saveFrame("infoImage.jpg");
    //println("loaded saved data and analyzed");
    s.write("loaded saved data and analyzed" + "\n");
    // helps avoiding looping but holds the frame in current window
    // in the next if statement
    event = 0;
  } else if (event == 0) {
    //load frame from previous. 
    img = loadImage("infoImage.jpg"); 
    image(img, 0, 0);
    //println("Just the previous frame loaded");
    s.write("Just the previous frame loaded" + "\n");
    s.write("--------DONE ONE SESSION-------" + "\n");

    //Convert the image to base64
    base64Encoding();

    //s.write(" " + "\n\n\n");
    event = 4;
  } else if (event == 2) {
    //start cam
    cam.start();
    image(cam, 0, 0);

    //println("Normal form");
  }

  /*fill(0, 80);
   noStroke();
   rect(970, 9, 300, 100);
   */

  fill(255);
  text("Press 's' to analyse", 985, 25);
  text("Press 'b' to get live cam", 985, 40);
}

void keyPressed() {
  if (key == 's') {
    event = 1;
  } else if (key == 'b' ) {
    event = 2;
  } else {
    //event = 4;
  }
}

float ex1, ey1, ex2, ey2, lx1, ly1, lx2, ly2, ex3, ey3, lx3, ly3, ep2, eb2, eh2, ep, eb, eh, lp, lp2, lb, lb2, lh, lh2;

void analysedImage() {
  img = loadImage("data/" + "img.jpg");
  faces = rekog.detectFacesPath("data/" + "img.jpg");
  // The face objects have lots of information stored
  for (int i = 0; i < faces.length; i++) {


    stroke(255);
    strokeWeight(1);
    noFill();
    rectMode(CENTER);
    rect(faces[i].center.x, faces[i].center.y, faces[i].w, faces[i].h);  // Face center, with, and height
    rect(faces[i].eye_right.x, faces[i].eye_right.y, 4, 4);              // Right eye
    rect(faces[i].eye_left.x, faces[i].eye_left.y, 4, 4);                // Left eye
    rect(faces[i].mouth_left.x, faces[i].mouth_left.y, 4, 4);            // Mouth Left
    rect(faces[i].mouth_right.x, faces[i].mouth_right.y, 4, 4);          // Mouth right
    rect(faces[i].nose.x, faces[i].nose.y, 6, 6);                        // Nose
    fill(255);
    String display = "Age: " + int(faces[i].age) + "\n\n";                        // Age
    display += "Gender: " + faces[i].gender + "\n";                               // Gender
    display += "Gender rating: " + nf(faces[i].gender_rating, 1, 2) + "\n\n";     // Gender from 0 to 1, 1 male, 0 female
    display += "Smiling: " + faces[i].smiling + "\n";     // Smiling
    display += "Smile rating: " + nf(faces[i].smile_rating, 1, 2) + "\n\n";       // Smiling from 0 to 1
    display += "Glasses: " + faces[i].glasses + "\n";                             // Glasses
    display += "Glasses rating: " + nf(faces[i].glasses_rating, 1, 2) + "\n\n";   // Glasses from 0 to 1
    display += "Eyes closed: " + faces[i].eyes_closed + "\n";                               // Eyes closed
    display += "Eyes closed rating: " + nf(faces[i].eyes_closed_rating, 1, 2) + "\n\n";     // Eyes closed from 0 to 1
    //println(display);

    /************************************************************************************************/
    //Golden Ration measurement
    //figurative quantification of beauty
    //simplest method which is far from being accurate
    //Written on the basis of information read from internet.. 
    //http://www.intmath.com/blog/mathematics/is-she-beautiful-the-new-golden-ratio-4149
    //http://www.intmath.com/blog/mathematics/is-she-beautiful-the-new-golden-ratio-4149

    ///////////////////*WARNING*//////////////////////
    ////////////////*LOT OF MATH AHEAD*///////////////
    // eye variables
    ex1 = faces[i].eye_left.x;
    ey1 = faces[i].eye_left.y;
    ex2 = faces[i].eye_right.x;
    ey2 = faces[i].eye_right.y;
    // lip/mouth variables
    lx1 = faces[i].mouth_left.x;
    ly1 = faces[i].mouth_left.y;
    lx2 = faces[i].mouth_right.x;
    ly2 = faces[i].mouth_right.y;

    //compensation for tilted face and not angularly oriented face..

    //[1]check if eyes are at same level
    if (ey1 == ey2) {
      // If eyes are at same level, the distance between the eyes would be
      //[2] thus mid point would be 
      ex3 = ex1 + ((ex2-ex1)/2);
      ey3 = ey2; //or ey1;
    } else if (ey1 > ey2) { // if they are not at the same level 
      //[3] If the head is inclined left
      // we need to find the midpoint i.e (x3,y3) of the inclined line between eyes.. 
      ep = ey1-ey2; // perpendicular
      eb = ex2-ex1; // base
      eh = sqrt((sq(ep))+(sq(eb))); // hypotenuse --pythagerous theorem 
      eh2 = eh/2; // midpoint of the hypotenuse // hoptenuse of the smaller traingle from mid-point

      float etheta = asin(ep/eh); // the common theta is sin inverse (perpendicular/ hypotenuse) and it is radians

      ep2 = eh2*sin(etheta); // perpendicular of the smaller triabgle.
      eb2 = eh2*cos(etheta); // base of the smaller triangle. 

      ex3 = eb2 + ex1;
      ey3= ey1-ep2;
    } else if (ey1 < ey2) { // if they are not at the same level 
      //[3] If the head is inclined right
      // we need to find the midpoint i.e (x3,y3) of the inclined line between eyes.. 
      ep = ey2-ey1; // perpendicular
      eb = ex2-ex1; // base
      eh = sqrt((sq(ep))+(sq(eb))); // hypotenuse --pythagerous theorem 
      eh2 = eh/2; // midpoint of the hypotenuse // hoptenuse of the smaller traingle from mid-point

      float etheta = asin(ep/eh); // the common theta is sin inverse (perpendicular/ hypotenuse) and it is radians

      ep2 = eh2*sin(etheta); // perpendicular of the smaller triabgle.
      eb2 = eh2*cos(etheta); // base of the smaller triangle. 

      ex3 = eb2 + ex1;
      ey3= ey2-ep2;
    }



    //[1]check if lips are at same level just like before
    if (ly1 == ly2) {
      // If eyes are at same level, the distance between the eyes would be
      //[2] thus mid point would be 
      lx3 = lx1 + ((lx2-lx1)/2);
      ly3 = ly2; //or ey1;
    } else if (ly1 > ly2) { // if they are not at the same level 
      //[3] If the head is inclined left
      // we need to find the midpoint i.e (x3,y3) of the inclined line between eyes.. 
      lp = ly1-ly2; // perpendicular
      lb = lx2-lx1; // base
      lh = sqrt((sq(lp))+(sq(lb))); // hypotenuse --pythagerous theorem 
      lh2 = lh/2; // midpoint of the hypotenuse // hoptenuse of the smaller traingle from mid-point

      float ltheta = asin(lp/lh); // the common theta is sin inverse (perpendicular/ hypotenuse) and it is radians

      lp2 = lh2*sin(ltheta); // perpendicular of the smaller triabgle.
      lb2 = lh2*cos(ltheta); // base of the smaller triangle. 

      lx3 = lx1 + lb2;
      ly3= ly1-lp2;
    } else if (ly1 < ly2) { // if they are not at the same level 
      //[3] If the head is inclined right
      // we need to find the midpoint i.e (x3,y3) of the inclined line between eyes.. 
      lp = ly1-ly2; // perpendicular
      lb = lx2-lx1; // base
      lh = sqrt((sq(lp))+(sq(lb))); // hypotenuse --pythagerous theorem 
      lh2 = lh/2; // midpoint of the hypotenuse // hoptenuse of the smaller traingle from mid-point

      float ltheta = asin(lp/lh); // the common theta is sin inverse (perpendicular/ hypotenuse) and it is radians

      lp2 = lh2*sin(ltheta); // perpendicular of the smaller triabgle.
      lb2 = lh2*cos(ltheta); // base of the smaller triangle. 

      lx3 = lx1 + lb2;
      ly3= ly2-lp2;
    } else {
      ///
    }

    //println("ex1: " + ex1 + ",  " + "ey1: " + ey1 + ",  " + "ex2: " + ex2 + ",  " + "ey2: " + ey2);
    //println("ex3: " + ex3 + ",  " + "ey3: " + ey3 + "lx3: " + lx3 + ",  " + "ly3: " + ly3);

    strokeWeight(0.25);
    line(ex1, ey1, ex2, ey2);
    line(lx1, ly1, lx2, ly2);
    line(ex3, ey3, lx3, ly3);

    /*************GOLDEN RATIO CALCULATION***********************/
    float distEyeMouth = ly3 - ey3;
    //println("Eye mouth distance: " + distEyeMouth);
    s.write("Eye mouth distance: " + distEyeMouth + "\n");
    //println("Height of face: " + faces[i].h);
    s.write("Height of face: " + faces[i].h + "\n");
    float measuredGoldenRatio = (distEyeMouth/faces[i].h)*100;
    //println("your golden ratio: " + measuredGoldenRatio);
    s.write("your golden ratio: " + measuredGoldenRatio + "\n");


    /************************************************************************************************/
    //CHOICE MAKING CONDITIONS SETUPS

    // eye glass conditionals
    if (Eye_Glass_Check == true && faces[i].glasses == true) {
      glass_resultant = true;
      //println(" g_resultant true");
      s.write(" g_resultant true" + "\n");
    } else if (Eye_Glass_Check == true && faces[i].glasses == false) {
      glass_resultant = false;
      //println(" g_resultant false");
      s.write(" g_resultant false" + "\n");
    } else if (Eye_Glass_Check == false && faces[i].glasses == true) {
      glass_resultant = false;
      //println(" g_resultant false");
      s.write(" g_resultant false" + "\n");
    } else {
      glass_resultant = true;
      //println(" g_resultant true");
      s.write(" g_resultant true" + "\n");
    }

    // smile conditionals
    if (Smile_Check == true && faces[i].smiling == true) {
      smile_resultant = true;
      //println(" s_resultant true");
      s.write(" s_resultant true" + "\n");
    } else if (Smile_Check == true && faces[i].smiling == false) {
      smile_resultant = false;
      //println(" s_resultant false");
      s.write(" s_resultant false" + "\n");
    } else if (Smile_Check == false && faces[i].smiling == true) {
      smile_resultant = false;
      //println(" s_resultant false");
      s.write(" s_resultant false" + "\n");
    } else {
      smile_resultant = true;
      //println(" s_resultant true");
      s.write(" s_resultant true" + "\n");
    }

    // age conditions
    //kinky about older people
    int additiveAgeBuffer = Preferred_Age + bufferAgeAddition;
    int subtractiveAgeBuffer = Preferred_Age - bufferAgeAddition;

    if (faces[i].age > Preferred_Age) {
      if (faces[i].age > additiveAgeBuffer) {
        age_resultant = false;
        // println(" a_resultant false");
        s.write(" a_resultant false" + "\n");
      } else if (faces[i].age <= additiveAgeBuffer) {
        age_resultant = true;
        //println(" a_resultant true");
        s.write(" a_resultant true" + "\n");
      } else if (faces[i].age == additiveAgeBuffer) {
        age_resultant = true;
        //println(" a_resultant true");
        s.write(" a_resultant true" + "\n");
      }
    } else if (faces[i].age < Preferred_Age) {
      if (faces[i].age < subtractiveAgeBuffer) {
        age_resultant = false;
        //println(" a_resultant false");
        s.write(" a_resultant false" + "\n");
      } else if (faces[i].age >= subtractiveAgeBuffer) {
        age_resultant = true;
        //println(" a_resultant true");
        s.write(" a_resultant true" + "\n");
      } else if (faces[i].age == subtractiveAgeBuffer) {
        age_resultant = true;
        //println(" a_resultant true");
        s.write(" a_resultant true" + "\n");
      }
    } else {
      age_resultant = true;
      //println(" a_resultant true");
      s.write(" a_resultant true" + "\n");
    }

    //golden ratio conditions  ..bufferToRatio
    int addtiveGRratioBuffer = Golden_Ratio + bufferToRatio;
    int subtractiveGRRatioBuffer = Golden_Ratio - bufferToRatio;

    if (measuredGoldenRatio > Golden_Ratio) {
      if (measuredGoldenRatio > addtiveGRratioBuffer) {
        GR_resultant = false;
        //println(" GR_resultant false");
        s.write(" GR_resultant false" + "\n");
      } else if (measuredGoldenRatio == addtiveGRratioBuffer) {
        GR_resultant = true;
        //println(" GR_resultant true");
        s.write(" GR_resultant true" + "\n");
      } else if (measuredGoldenRatio <= addtiveGRratioBuffer) {
        GR_resultant = true;
        //println(" GR_resultant true");
        s.write(" GR_resultant true" + "\n");
      }
    } else if (measuredGoldenRatio < Golden_Ratio) {
      if (measuredGoldenRatio < subtractiveGRRatioBuffer) {
        GR_resultant = false;
        // println(" GR_resultant false");
        s.write(" GR_resultant false" + "\n");
      } else if (measuredGoldenRatio == subtractiveGRRatioBuffer) {
        GR_resultant = true;
        //println(" GR_resultant true");
        s.write(" GR_resultant true" + "\n");
      } else if (measuredGoldenRatio >= subtractiveGRRatioBuffer) {
        GR_resultant = true;
        //println(" GR_resultant true");
        s.write(" GR_resultant true" + "\n");
      }
    } else {
      GR_resultant = true;
      //println(" GR_resultant true");
      s.write(" GR_resultant true" + "\n");
    }


    display += "Eye glass choice resultant: " + glass_resultant + "\n";
    display += "Smile choice resultant: " + smile_resultant + "\n";
    display += "Age glass choice resultant: " + age_resultant + "\n";
    display += "Golden ratio choice resultant: " + GR_resultant + "\n";

    fill(255);
    text(display, 10, 20);                         // Draw all text below face rectangle
    ///////////////////

    //Now I have four parameters: 
    //GR_resultant
    //a_resultant
    //g_resultant
    //s_resultant
  }

  /**************************** :: choice making algorithm :: *******************************/

  /****************** :: LOT OF CONDITIONALS AHEAD. TRAVERSE CAREFULLY :: *****************/

  //select age as first preference or golden ratio
  //if GR 1st preference:: check GR after AGE
  //if AGE 1st preference:: check age after GR

  if (stPreference == true) {// i.e GR is given the first priority of selsction

    // println("Golden Ratio is given the first priority of selsction");
    // println("------------------------------------------------------");
    s.write("-----------------------------------------------------" + "\n");
    s.write("Golden Ratio is given the first priority of selsction" + "\n");
    s.write("-----------------------------------------------------" + "\n");

    fill(255);
    text("Golden Ratio is given the first priority of selsction", 10, height/2);

    //check the GR criteria if it matches i.e it is true
    if (GR_resultant == true) {
      //println("Golden Ratio criterion matches");
      s.write("Golden Ratio criterion matches" + "\n");
      fill(255);
      text("Golden Ratio criterion matches", 10, (height/2) + 10 );
      //check if age criterion matches
      if (age_resultant == true) {
        //println("Age criterion is also matched after this");
        //println("Accept Her");
        s.write("Age criterion is also matched after this" + "\n");
        s.write("Accept Her" + "\n");
        fill(255);
        text("Age criterion is also matched after this", 10, (height/2)+20 );
        text("Accept Her", 10, (height/2)+30 );
        //
        myPort.write('3');
        //
        //generalResultant = true;
      } else if (age_resultant == false) {// if it doesn't then give machine a random choice to make a selection
        //println("But age criterion didn't match under this 1st preference");
        //println("So machine is going to choose on it's will");
        s.write("But age criterion didn't match under this 1st preference" + "\n");
        s.write("So machine is going to choose on it's will" + "\n");

        fill(255);
        text("But age criterion didn't match under this 1st preference", 10, (height/2)+20 );
        text("So machine is going to choose on it's will", 10, (height/2)+30 );

        int v = int(random(0, 2));


        //println("Random  variable is: " + v);
        s.write("Random  variable is: " + v + "\n");
        if (v == 1) {
          //println("Since random criterio matched, Accept her");
          //println("Accept her");
          s.write("Since random criterio matched, Accept her" + "\n");
          s.write("Accept her" + "\n");
          fill(255);
          text("Accept her", 10, (height/2)+40 );
          //
          myPort.write('3');
          //
          v = 0;
          //generalResultant = true;
        } else {
          //println("As random criterion didn't match");
          //println("Reject her");
          s.write("As random criterion didn't match" + "\n");
          s.write("Reject her" + "\n");
          fill(255);
          text("Reject her", 10, (height/2)+40 );
          //
          myPort.write('2');
          //
          //generalResultant = false;
        }
      }
    } else if (GR_resultant == false) {//check if GR criterion doesn't matches. 
      //println("Golden Ratio criterion doesn't match at the first place");
      //println("Reject her");
      s.write("Golden Ratio criterion doesn't match at the first place" + "\n");
      s.write("Reject her" + "\n");
      fill(255);
      text("Golden Ratio criterion doesn't match at the first place", 10, (height/2)+10 );
      text("Reject her", 10, (height/2)+20 );
      //
      myPort.write('2');
      //

      //generalResultant = false;
    }
  } else { // if Age is given the first Priority of selection
    //println("Age is given the first Priority of selection");
    //println("--------------------------------------------");
    s.write("--------------------------------------------" + "\n");
    s.write("Age is given the first Priority of selection" + "\n");
    s.write("--------------------------------------------" + "\n");

    fill(255);
    text("Age is given the first Priority of selection", 10, height/2);

    //check the AGE criterion if it matches.. 
    if (age_resultant == true) { // i.e if it's true
      //println("Age criterion matches");
      s.write("Age criterion matches" + "\n");
      fill(255);
      text("Age criterion matches", 10, (height/2) + 10 );
      //Then check if GR criterion matches
      if (GR_resultant == true) { // if it's true accept her
        //println("And Golden Ratio criterion under this also matches");
        //println("Accept her");
        s.write("And Golden Ratio criterion under this also matches" + "\n");
        s.write("Accept her" + "\n");
        fill(255);
        text("And Golden Ratio criterion under this also matches", 10, (height/2)+20 );
        text("Accept her", 10, (height/2)+30 );
        //
        myPort.write('3');
        //
        //generalResultant = true;
      } else if (GR_resultant == false) { // if under age criterion, GR criterion doesn't match
        //give machine a random selection to do
        //println("But Golden Ratio criterion doesn't match");
        //println("So machine will choose on it's will");
        s.write("But Golden Ratio criterion doesn't match" + "\n");
        s.write("So machine will choose on it's will" + "\n");

        fill(255);
        text("But Golden Ratio criterion doesn't match under this 1st prefrence", 10, (height/2)+20 );
        text("So machine is going to choose on it's will", 10, (height/2)+30 );

        int w = int(random(0, 2));
        //println("The random variable is: " + w);
        s.write("The random variable is: " + w + "\n");

        if (w == 1) {
          //println("Since random criterion matched, accept her");
          //println("Accept her");
          s.write("Since random criterion matched, accept her" + "\n");
          s.write("Accept her" + "\n");
          fill(255);
          text("Accept her", 10, (height/2)+40 );
          //
          myPort.write('3');
          //
          //generalResultant = true;
          w = 0;
        } else {
          //println("The random criterion didn't match");
          //println("Reject her");
          s.write("The random criterion didn't match" + "\n");
          s.write("Reject her" + "\n");
          fill(255);
          text("Reject her", 10, (height/2)+40 );
          //
          myPort.write('2');
          //
          //generalResultant = false;
        }
      }
    } else if (age_resultant == false) { // if age criterion is not match at the first place, reject
      //println("AGe criterion doesn't matches");
      //println("Reject her");
      s.write("Age criterion doesn't matches at the first place" + "\n");
      s.write("Reject her" + "\n");
      fill(255);
      text("Age criterion doesn't matches at the first place", 10, (height/2)+10 );
      text("Reject her", 10, (height/2)+20 );
      //
      myPort.write('2');
      //
      //generalResultant = false;
    }
  }

  //eye glass check and match priority
  /**********PSEUDO_CODE*************/
  /*
  if (eyeGlass criterion true){
   if (previous resultant true){
   send ‘yes’
   }else{
   MAKE A RANDOM CHOICE. 
   }
   }else{
   MAKE CHOICE BASED ON PREVIOUS RESULTANT. 
   }
   */

  /*
  if (Eye_Glass_Check == true) {
   if (generalResultant == true) {
   //send yes.
   } else {
   //send random
   int p = int(random(0, 3));
   if (p == 1) {
   //send yes
   } else {
   //send no
   }
   }
   } else {
   if (generalResultant == true) {
   //send random
   int u = int(random(0, 3));
   if(u == 1){
   //send yes
   }else{
   //send no
   }
   } else {
   //send no
   }
   }
   */


  ////////////////////
}

void base64Encoding() {
  try {
    Process p = Runtime.getRuntime().exec("openssl base64 -in /Users/saurabh.datta/Documents/Processing/sketches/tinderBot_101/application.macosx64/infoImage.jpg -out /Users/saurabh.datta/Documents/Processing/sketches/tinderBot_101/application.macosx64/encodedB64.txt");
    // println("connveretd picture in base 64");
    //s.write("connveretd picture in base 64");
    delay(2000);
    // println("Loading base64 encoded file in process");
    //s.write("connveretd picture in base 64");
    encodedFileData = loadStrings("/Users/saurabh.datta/Documents/Processing/sketches/tinderBot_101/application.macosx64/encodedB64.txt"); 
    sringbase64 = join(encodedFileData, "");
    // println(sringbase64);
    //println(encodedFileData);
    runCreatePhotoPostWithImageFileChoreo();
  } 
  catch (Exception err) {
    err.printStackTrace();
  }
}

///////////////////////////////////////////////

void delay(int delay)
{
  int time = millis();
  while (millis () - time <= delay);
}

//////////////////////////////////////////////

void runCreatePhotoPostWithImageFileChoreo() {
  // Create the Choreo object using your Temboo session
  CreatePhotoPostWithImageFile createPhotoPostWithImageFileChoreo = new CreatePhotoPostWithImageFile(session);

  // Set inputs
  //createPhotoPostWithImageFileChoreo.setData("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AAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIEDAAAAyBM4AAAAgDyBAwAAAMgTOAAAAIA8gQMAAADIEzgAAACAPIE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A8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAgT+AAAAAA8gQOAAAAIE/gAAAAAPIEDgAAACBP4AAAAADyBA4AAAAg738EYO/eedpY1zAMb7xshLBRmlAhRdSkpooU0aQhDT9o/S4306ShpopEmigiZYjIYvA4sWOzvWEfsh2TRTj48eG6itHMJ8AzL67QzeeVP//80xQAAAAAAAAAAIL8hwoAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAAAAAAACBNwAAAAAAAAAACECTgAAAAAAAAAAMIEHAAAAAAAAAAAYQIOAAAAAAAAAIAwAQcAAAAAAAAAQJiAAwAAAAAAAAAgTMABAAAAAAAAABAm4AAAAAA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AAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhAk4AAAAAAAAAADCBBwAAAAAAAAAAGECDgAAAAAAAACAMAEHAAAAAAAAAECYgAMAAAAAAAAAIEzAAQAAAAAAAAAQJuAAAAAAAAAAAAgTcAAAAAAAAAAAhP0HqwnQ4Wnar0MAAAAASUVORK5CYII=");
  createPhotoPostWithImageFileChoreo.setData(sringbase64);
  createPhotoPostWithImageFileChoreo.setTags("Software_posting_Bot, Processing, analyzer, machine _ecision");
  //createPhotoPostWithImageFileChoreo.setCaption("");
  createPhotoPostWithImageFileChoreo.setAPIKey("AuAXf9OTiPRUUyUBrA0FYX854yE1FBQQOrrdfMdm1bJMZQkCzm");
  createPhotoPostWithImageFileChoreo.setAccessToken("DiDmxXimbK3ig1Pgtuj2laEgb4f73W5eFstELMTKNxp0g0L95P");
  createPhotoPostWithImageFileChoreo.setAccessTokenSecret("N8AXXy5ECDxPZ9Yq93ngZ7lR878C50pyCvEPNmdZb108hKnrow");
  createPhotoPostWithImageFileChoreo.setSecretKey("VtdeoL9vhPShNAdrmwkrergTZ4LPOrCmRbUenwKK4ixF73vtfp");
  createPhotoPostWithImageFileChoreo.setSlug("Made By Processing");
  createPhotoPostWithImageFileChoreo.setBaseHostname("forscripts.tumblr.com");

  // Run the Choreo and store the results
  CreatePhotoPostWithImageFileResultSet createPhotoPostWithImageFileResults = createPhotoPostWithImageFileChoreo.run();

  // Print results
  println(createPhotoPostWithImageFileResults.getResponse());
}

