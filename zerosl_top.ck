// Chuck library for controlling the novation ZeroSL MKII
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

// Base class for value visualizers
class Visualizer
{
  0      => int visible;
  "None" => string label;
  0.0    => float value;

  ZeroSL controller;

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

  fun void handle(int control, int value)
  {
    <<< "Empty handler for control :", name >>>;
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
  fun void update(float v,int i){
    controller.writeLabel(label,lcd,ZeroSLEnum.Row1,column);
    controller.writeLabel(Std.ftoa(v,3),lcd,ZeroSLEnum.Row2,column);
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
  0  => int fix_range;
  string items[];
  fun void update(float v, int i){
      0 => int index;
    if(items!=null){
      if(fix_range!=0)
      {
        (((items.size()) $ float) * v) $ int => index;
      }
      else
      {
        i => index;
      }
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
  fun void handle(int control,int v)
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
       }
    }
  }
}

class PushButton extends Control
{
  fun void handle(int control,int v)
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
    }
  }
}

class CountButton extends Control
{
  0   => int min;
  127 => int max;
  fun void handle(int control,int v)
  {
    if(control == cc_value)
    {
       if(v!=0)
       {
          (int_value + 1)%128  => int_value;
          max-min $float       => float range;
          int_value-min $float => float delta;
          delta/range          => raw_value;
          show();
       }
    }
  }
}

class Knob extends Control
{
  0   => int min;
  127 => int max;
  fun void handle(int control,int v)
  {
    if(control == cc_value)
    {
      v => int_value;
      max-min $float       => float range;
      int_value-min $float => float delta;
      delta/range          => raw_value;
      show();
    }
  }
}

class Encoder extends Control
{
  1.0 => float speed;
  fun void handle(int control,int v)
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
      (127.0 * raw_value) $int => int_value;
      show();
    }
  }
}


/* -------- Main class --------  */

public class ZeroSLTop extends ZeroSLHandler
{
  ZeroSL controller;
  Control controls[];

  fun void open(int device)
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
          controls[i].handle(control,value);
        }
      }
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
  fun void addEncoderNumeric(string name, int position, int lcd, int column, float speed)
  {
    Encoder encoder;
    Numeric num;
    LedRing ring;
    position-ZeroSLEnum.Encoders => ring.column;
    controller @=> ring.controller;
    lcd        => num.lcd;
    column     => num.column;
    name       => num.label;
    controller @=> num.controller;
    name        => encoder.name;
    position    => encoder.cc_value;
    speed       => encoder.speed;
    [num $ Visualizer, ring $ Visualizer]      @=> encoder.visualizers;
    addControl(encoder);
  }

  /* Adds a knob with a numeric visualizer */
  fun void addKnobNumeric(string name, int position, int lcd, int column)
  {
    Knob knob;
    Numeric num;
    lcd        => num.lcd;
    column     => num.column;
    name       => num.label;
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
    1           => i.fix_range;
    controller @=> i.controller;
    name        => encoder.name;
    speed       => encoder.speed;
    position    => encoder.cc_value;
    [i $ Visualizer, ring $ Visualizer] @=> encoder.visualizers;
    addControl(encoder);
  }

}