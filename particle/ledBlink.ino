int led1 = D0;
int photoresistor = A0;
int photoresistorPower = A5;

int photoresistorValue;
char publishString[63];

unsigned long lastTime = 0UL;
unsigned long pollingInterval = 5000UL;


void setup()
{

   pinMode(led1, OUTPUT);
   Spark.function("led",ledToggle);
   pinMode(photoresistorPower, OUTPUT);

   digitalWrite(photoresistorPower, HIGH);

}

void loop()
{
  unsigned long now = millis();
  if (now-lastTime>pollingInterval) {
      lastTime = now;
      sprintf(publishString,"%d",analogRead(photoresistor));
      Spark.publish("Light_Sensor", publishString, 60, PRIVATE);
  }
}

int ledToggle(String command) {

    if (command=="on") {
        digitalWrite(led1,HIGH);
        return 1;
    }
    else if (command=="off") {
        digitalWrite(led1,LOW);
        return 0;
    }
    else {
        return -1;
    }
}
