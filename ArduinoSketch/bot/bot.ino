#include <Servo.h>

Servo servoLeft;
Servo servoRight;

const int leftButton = 4;
const int rightButton = 10;

int leftBtnState = 0;
int rightBtnState = 0;

void setup() {
  pinMode(leftButton, INPUT);
  pinMode(rightButton, INPUT);

  servoLeft.attach(6);
  servoRight.attach(9);

  midPoint();

  Serial.begin(9600);
}

void loop() {
  
  while (Serial.available() == 0);
  
  int val = Serial.read() - '0';
  //Serial.println(val);
  if (val == 2) {
    leftServo();
  } 
  else if (val == 3) {
    rightServo();
  } 
  else {
    midPoint();
  }

}

void leftServo() {
  servoLeft.attach(6);

  servoLeft.write(90);
  delay(150);
  servoLeft.write(40);
  //buttonState();
  delay(150);
  servoLeft.write(90);
  delay(1000);
  /*********************/
  Serial.println("Done");
  /*********************/
  servoLeft.detach();
}


void rightServo() {
  servoRight.attach(9);

  servoRight.write(75);
  delay(150);
  servoRight.write(122);
 // buttonState();
  delay(150);
  servoRight.write(75);
  delay(1000);
  /**********************/
  Serial.println("Done");
  /**********************/
  servoRight.detach();
}

void midPoint() {
  servoLeft.attach(6);
  servoRight.attach(9);

  servoLeft.write(90);
  servoRight.write(90);

  delay(100);

  servoLeft.detach();
  servoRight.detach();
}

void buttonState(){
  //button states
  leftBtnState = digitalRead(leftButton);
  rightBtnState = digitalRead(rightButton);

  if ((leftBtnState == HIGH) || (rightBtnState == HIGH)) {
    Serial.println("LIMIT PRESSED");
  } 
}




