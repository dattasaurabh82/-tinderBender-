import controlP5.*;
import processing.net.*;

Client cc;
String input;
int data[];

ControlP5 cp5;
Textarea myTextarea;

int c = 0;

Println console;

void setup() 
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

void draw() 
{
  background(20, 18, 19);
  // Receive data from server
  if (cc.available() > 0) {
    input = cc.readString();
    println(input);
  }
}

void keyPressed() {
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

