import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.io.*; 
import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Progress_console extends PApplet {


// Import the net libraries



Client cc;
String input;
int data[];

ControlP5 cp5;
Textarea myTextarea;

int c = 0;

Println console;

public void setup() 
{
  size(450, 255);

  frame.setTitle("Tinder Bot: analysed information console client"); 

  // Connect to the server's IP address and port
  cc = new Client(this, "127.0.0.1", 3000); // Replace with your server's IP and port

  cp5 = new ControlP5(this);
  cp5.enableShortcuts();

  myTextarea = cp5.addTextarea("txt")
    .setPosition(0, 0)
      .setSize(450, 255)
        .setFont(createFont("OCRAStd", 10))
          .setLineHeight(14)
            .setColor(color(200))
              .setColorBackground(color(0, 100))
                .setColorForeground(color(255, 100));
  ;

  console = cp5.addConsole(myTextarea);//
  println("-----------------------------------------------------------");
  println("Client staretd to get console data from server analysis app");
  println("-----------------------------------------------------------");
  //println("", "\n\n\n");
}

public void draw() 
{
  background(20, 18, 19);
  // Receive data from server
  if (cc.available() > 0) {
    input = cc.readString();
    println(input);
  }
}

public void keyPressed() {
  switch(key) {
    case('1'):
    console.pause();
    break;
    case('2'):
    console.play();
    break;
    case('3'):
    console.clear();
    break;
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Progress_console" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
