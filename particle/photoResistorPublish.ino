int photoresistor = A0;
int photoresistorPower = A5;

char publishString[63];

unsigned long lastTime = 0UL;
unsigned long pollingInterval = 5000UL;


void setup()
{

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
