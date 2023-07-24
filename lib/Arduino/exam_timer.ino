#include <SPI.h>
#include <DMD.h>
#include <TimerOne.h>
#include "SystemFont5x7.h"
#include "Arial_black_16.h" 

#define ROW_MODULE 2
#define COLUMN_MODULE 1

// Define the number of courses
#define NUM_COURSE 5
int NUM_COURSES = 0;

// Define the course titles and durations
String course_titles[NUM_COURSE];
unsigned long course_durations[NUM_COURSE];

// Initialize the P10 LED display
DMD p10 (ROW_MODULE, COLUMN_MODULE);

// Initialize the countdown variables
unsigned long countdown_start_time[NUM_COURSE] = {0, 0, 0};
unsigned long countdown_duration[NUM_COURSE] = {0, 0, 0};

// Initialize the sounder pin
int sounder_pin = 5;

// Initialize the scrolling variables
unsigned long last_scroll_time = 0;
unsigned long now_scroll_time = 0;
int scroll_position = 0;

void p10scan() {
  p10.scanDisplayBySPI();
}

//Remove a course from the list
void removeCourse(int pos) {
  // Shift elements to fill the gap left by the removed element
  for (int i = pos; i < NUM_COURSES; i++) {
    if (i+1==NUM_COURSES) continue;
      course_titles[i] = course_titles[i + 1];
      course_durations[i] = course_durations[i + 1];
      countdown_start_time[i] = countdown_start_time[i + 1];
  }
  NUM_COURSES--;
}

void setup() {
  // Initialize the serial communication for debugging
  Timer1.initialize(2000);
  Timer1.attachInterrupt(p10scan);
  p10.clearScreen(true);
  Serial.begin(9600);
  
  // Set the sounder pin as an output
  pinMode(sounder_pin, OUTPUT);
}

void loop() {
  p10.selectFont(Arial_Black_16);
  if (millis() < 2000) {
    p10.drawMarquee("Hello!!   ", 50, 9, 0);
    delay(3000);
    p10.clearScreen(true);
  }
  
  if (NUM_COURSES < 1)
    p10.drawMarquee("Ready!! ", 100, 3, 0);
    
  // Check if there is any data available from the Bluetooth module
  if (Serial.available()) {
    p10.clearScreen(true);
    // Read the incoming data
    String data = Serial.readStringUntil('.');
    Serial.println(data);
    NUM_COURSES++;
    
    // Parse the data and set the course titles and durations
    int index = 0;
    int i = NUM_COURSES - 1;
    int commaIndex = data.indexOf(",", index);
    course_titles[i] = data.substring(index, commaIndex);
    index = commaIndex + 1;
    commaIndex = data.indexOf(",", index);
    course_durations[i] = data.substring(index, commaIndex).toInt() * 60000;
    index = commaIndex + 1;

    // Start the countdown for each course
    countdown_start_time[i] = millis();
    countdown_duration[i] = course_durations[i];
  }

  // Update the countdown for each course
  for (int i = 0; i < NUM_COURSES; i++) {
    unsigned long time_elapsed = millis() - countdown_start_time[i];
    unsigned long time_remaining = countdown_duration[i] - time_elapsed;
    if (countdown_duration[i] <= time_elapsed)
      time_remaining = 0;
    
    // Convert the time remaining to minutes and seconds
    unsigned long seconds = time_remaining / 1000;
    unsigned long minutes = seconds / 60;
    unsigned long hours = minutes / 60;
    
    // Calculate the remaining minutes and seconds
    minutes %= 60;
    seconds %= 60;
    
    // Display the course title and remaining time on the LED display
    char times[9];
    snprintf(times, sizeof(times), "%02lu:%02lu:%02lu", hours, minutes, seconds);
    char course[8];
    for (int j=0; j<8; j++) 
      course[j] = course_titles[i][j];

    // Check if the time for the course has run out
    if (time_remaining == 600000) {
      digitalWrite(sounder_pin, HIGH);
      p10.selectFont(SystemFont5x7);
      p10.drawString(8, i * 16, course, 8, GRAPHICS_NORMAL);
      p10.drawString(8, 9 + i * 16 , times, 9, GRAPHICS_NORMAL);
      delay(1000);
      digitalWrite(sounder_pin, LOW);
      delay(5000);
    }

    // Check if the time for the course has run out
    if (time_remaining == 0) {
      digitalWrite(sounder_pin, HIGH);
      p10.selectFont(SystemFont5x7);
      p10.drawString(8, 0, course, 8, GRAPHICS_NORMAL);
      p10.drawString(8, 9 + 0 , times, 9, GRAPHICS_NORMAL);
      delay(1000);
      digitalWrite(sounder_pin, LOW);
      delay(4000);
      removeCourse(i);
      continue;
    }
    
    // Write the course title and countdown to the display
      p10.selectFont(SystemFont5x7);
      p10.drawString(8, scroll_position + i * 16, course, 8, GRAPHICS_NORMAL);
      p10.drawString(8, scroll_position + 9 + i * 16 , times, 9, GRAPHICS_NORMAL);
    
    // Check if it's time to scroll the display
    if (millis() - last_scroll_time >= 50 
        && scroll_position % 16 != 0) {
      scroll_position--;
     // Check if the display has scrolled off the screen
      if (scroll_position <= -16 * (NUM_COURSES - 1) - 1) {
        scroll_position = 15;
      }
      
      last_scroll_time = millis();
    }
    
    if (millis() - now_scroll_time >= 5000 
      && scroll_position % 16 == 0) {
        scroll_position--;
        now_scroll_time = millis();
    }
  }
}
