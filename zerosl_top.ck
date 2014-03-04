// Chuck library for controlling the novation ZeroSL MKII
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

// Base class for value visualizers
class Visualizer
{
  0      => int visible;
  "None" => string label;
  0.0    => float value;

  ZeroSL @ controller;

  fun void update(float v,int i){
    <<< "Empty visualizer" >>>;
  }
}

// Base class for controls
class Control
{
  1   => int enabled;    // If can recieve messages
  0   => int int_value;  // MIDI value 0-127
  0.0 => float raw_value;// Value from 0.0-1.0
  "default" => string name;
  0 => int cc_value;

  Visualizer visualizers[];

  fun int handle(int control, int value)
  {
    <<< "Empty handler for control :", name >>>;
    return 0;
  }

  fun void show()
  {
    if(visualizers!=null)
    {
      visualizers.size() => int n;
      for(0 => int i; i<n; 1+=>i)
        visualizers[i].update(raw_value,int_value);
    }
  }
}

/* -------- VISUALIZERS --------  */

// Led visualizer, used to turn on/off a button in the controller
class Led extends Visualizer
{
  0 => int cc_value;
  fun void update(float v,int i){
      controller.setLedButton(cc_value,i);
  }
}

class Numeric extends Visualizer
{
  0      => int column;
  0      => int lcd;
  0.0    => float min;
  1.0    => float max;
  fun void update(float v,int i){
    (max-min)*v+min => float val;
    controller.writeLabel(label,lcd,ZeroSLEnum.Row1,column);
    controller.writeLabel(Std.ftoa(val,3),lcd,ZeroSLEnum.Row2,column);
  }
}

class NumericInt extends Visualizer
{
  0      => int column;
  0      => int lcd;
  fun void update(float v,int i){
    controller.writeLabel(label,lcd,ZeroSLEnum.Row1,column);
    controller.writeLabel(Std.itoa(i),lcd,ZeroSLEnum.Row2,column);
  }
}

class LedRing extends Visualizer
{
  0      => int column;
  fun void update(float v,int i){
    (v * 12.0) $ int => int ring_value;
    controller.setLedRing(column,ring_value);
  }
}

class Items extends Visualizer
{
  0  => int column;
  0  => int lcd;
  string items[];
  fun void update(float v, int index){
    if(items!=null){
      if(index >= items.size())
        items.size()-1 => index;
      if(index < 0)
        0 => index;
      controller.writeLabel(label,lcd,ZeroSLEnum.Row1,column);
      controller.writeLabel(items[index],lcd,ZeroSLEnum.Row2,column);
    }
  }
}


/* -------- CONTROLS --------  */

class ToggleButton extends Control
{
  fun int handle(int control,int v)
  {
    if(control == cc_value)
    {
       if(v!=0)
       {
          if(int_value!=0)
          {
            0   => int_value;
            0.0 => raw_value;
          }
          else
          {
            127 => int_value;
            1.0 => raw_value;
          }
          show();
          return 1;
       }
    }
    return 0;
  }
}

class PushButton extends Control
{
  fun int handle(int control,int v)
  {
    if(control == cc_value)
    {
      if(v==0)
      {
        0   => int_value;
        0.0 => raw_value;
      }
      else
      {
        127 => int_value;
        1.0 => raw_value;
      }
      show();
      return 1;
    }
    return 0;
  }
}

class CountButton extends Control
{
  0   => int min;
  127 => int max;
  fun int handle(int control,int v)
  {
    if(control == cc_value)
    {
       if(v!=0)
       {
          int_value + 1 => int_value;
          if(int_value>max)
            min => int_value;
          if(int_value<min)
            max => int_value;
          max-min $float       => float range;
          int_value-min $float => float delta;
          delta/range          => raw_value;
          show();
          return 1;
       }
    }
    return 0;
  }
}

class Knob extends Control
{
  0   => int min;
  127 => int max;
  fun int handle(int control,int v)
  {
    if(control == cc_value)
    {
      v => int_value;
      max-min $float       => float range;
      int_value-min $float => float delta;
      delta/range          => raw_value;
      show();
      return 1;
    }
    return 0;
  }
}

class KnobInt extends Control
{
  0   => int min;
  127 => int max;
  fun int handle(int control,int v)
  {
    if(control == cc_value)
    {
      (v $float) / 127.0 => float raw_value;
      max-min $float       => float range;
      ((raw_value * range) + min) $ int => int_value;
      show();
      return 1;
    }
    return 0;
  }
}

class Encoder extends Control
{
  1.0 => float speed;
  0   => int min;
  127 => int max;
  fun int handle(int control,int v)
  {
    1.0 => float direction;
    if(control == cc_value)
    {
      v => float fixed_v;
      if(fixed_v>64)
      {
        -1.0 => direction;
        64  -=> fixed_v;
      }
      direction*speed*fixed_v/127.0 +=> raw_value;
      if(raw_value>1.0)
        1.0 => raw_value;
      if(raw_value<0.0)
        0.0 => raw_value;
      (((max - min) * raw_value) + min) $int => int_value;
      if(int_value>max)
        max => int_value;
      if(int_value<min)
        min => int_value;
      show();
      return 1;
    }
    return 0;
  }
}


/* -------- Main class --------  */

public class ZeroSLTop extends ZeroSLHandler
{
  ZeroSL controller;
  Control controls[];
  ZeroSLTopHandler controlHandler;

  fun void open(string device)
  {
    controller.open(device);
    controller.setControlHandler(this);
    controller.clear();
  }

  fun void close()
  {
    controller.close();
  }

  /* Adds a new controll to the array */
  fun void addControl(Control c)
  {
    //<<<"Adding ", c.name >>>;
    if(controls==null)
      [c] @=> controls;
    else
      controls << c;
    c.show();
  }
  /* Process the incoming midi input fromthe controller */
  fun void handle(int control,int value)
  {
    //<<< "control ",control," value ",value >>>;
    if(controls!=null)
    {
      controls.size() => int size;
      for(0=>int i;i<size;1+=>i)
      {
        if(controls[i].enabled!=0)
          if(controls[i].handle(control,value)!=0){
            controlHandler.handle(controls[i].name,controls[i].raw_value,controls[i].int_value);
          }
      }
    }
  }

  fun void setControlValue(string name, float raw_value, int int_value)
  {
    if(controls!=null)
    {
      controls.size() => int size;
      for(0=>int i;i<size;1+=>i)
      {
        if(controls[i].name==name){
          raw_value => controls[i].raw_value;
          int_value => controls[i].int_value;
          controls[i].show();
        }
      }
    }
  }

  fun void setControlEnable(string name, int on_off)
  {
    if(controls!=null)
    {
      controls.size() => int size;
      for(0=>int i;i<size;1+=>i)
      {
        if(controls[i].name==name){
          on_off => controls[i].enabled;
          if(on_off!=0) controls[i].show();
        }
      }
    }
  }

  fun void setControlHandler(ZeroSLTopHandler newHandler)
  {
    newHandler @=> controlHandler;
  }

  /* Adds a push button with a Led visualizer */
  fun void addPushLed(string name, int position)
  {
    PushButton push;
    Led led;
    position    => led.cc_value;
    controller @=> led.controller;
    name        => push.name;
    position    => push.cc_value;
    [led $ Visualizer]      @=> push.visualizers;
    addControl(push);
  }

  /* Adds a toggle button with a Led visualizer */
  fun void addToggleLed(string name, int position)
  {
    ToggleButton toggle;
    Led led;
    position    => led.cc_value;
    controller @=> led.controller;
    name        => toggle.name;
    position    => toggle.cc_value;
    [led $ Visualizer]      @=> toggle.visualizers;
    addControl(toggle);
  }
  /* Adds a toggle button with a numeric visualizer */
  fun void addToggleNumeric(string name,int position, int lcd, int column)
  {
    ToggleButton toggle;
    Numeric num;
    Led led;
    position    => led.cc_value;
    controller @=> led.controller;
    lcd        => num.lcd;
    column     => num.column;
    name       => num.label;
    controller @=> num.controller;
    name        => toggle.name;
    position    => toggle.cc_value;
    [num $ Visualizer, led $ Visualizer]  @=> toggle.visualizers;
    addControl(toggle);
  }

  /* Adds an encoder with a numeric visualizer */
  fun void addEncoderNumeric(string name, int position, int lcd, int column, float speed,float min, float max)
  {
    Encoder encoder;
    Numeric num;
    LedRing ring;
    position-ZeroSLEnum.Encoders => ring.column;
    controller @=> ring.controller;
    lcd        => num.lcd;
    column     => num.column;
    name       => num.label;
    min        => num.min;
    max        => num.max;
    controller @=> num.controller;
    name        => encoder.name;
    position    => encoder.cc_value;
    speed       => encoder.speed;
    [num $ Visualizer, ring $ Visualizer]      @=> encoder.visualizers;
    addControl(encoder);
  }

  /* Adds a knob with a numeric visualizer */
  fun void addKnobNumeric(string name, int position, int lcd, int column, float min, float max)
  {
    Knob knob;
    Numeric num;
    lcd        => num.lcd;
    column     => num.column;
    name       => num.label;
    min        => num.min;
    max        => num.max;
    controller @=> num.controller;
    name        => knob.name;
    position    => knob.cc_value;
    [num $ Visualizer]      @=> knob.visualizers;
    addControl(knob);
  }
  /* Adds a knob with a numeric visualizer */
  fun void addKnobNumericInt(string name, int position, int lcd, int column, int min, int max)
  {
    KnobInt knob;
    NumericInt num;
    lcd        => num.lcd;
    column     => num.column;
    name       => num.label;
    min        => knob.min;
    max        => knob.max;
    controller @=> num.controller;
    name        => knob.name;
    position    => knob.cc_value;
    [num $ Visualizer]      @=> knob.visualizers;
    addControl(knob);
  }
  /* Adds a list of items */
  fun void addEncoderItems(string name, int position, int lcd, int column,float speed, string items[])
  {
    Encoder encoder;
    Items i;
    LedRing ring;
    position-ZeroSLEnum.Encoders => ring.column;
    controller @=> ring.controller;
    lcd         => i.lcd;
    column      => i.column;
    name        => i.label;
    items      @=> i.items;
    controller @=> i.controller;
    name        => encoder.name;
    0           => encoder.min;
    items.size()-1 => encoder.max;
    speed       => encoder.speed;
    position    => encoder.cc_value;
    [i $ Visualizer, ring $ Visualizer] @=> encoder.visualizers;
    addControl(encoder);
  }
  /* Adds a list of items controlled by a button */
  fun void addCounterItems(string name, int position, int lcd, int column, string items[])
  {
    CountButton counter;
    Items i;
    Led led;
    position    => led.cc_value;
    controller @=> led.controller;
    lcd         => i.lcd;
    column      => i.column;
    name        => i.label;
    items      @=> i.items;
    controller @=> i.controller;
    name        => counter.name;
    0           => counter.min;
    items.size()-1 => counter.max;
    position    => counter.cc_value;
    [i $ Visualizer, led $ Visualizer] @=> counter.visualizers;
    addControl(counter);
  }

}