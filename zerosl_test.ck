
// Testing place for the ZeroSL
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

class ZeroToVenom extends ZeroSLTopHandler
{
  Venom venom;
  fun void open(int device)
  {
    venom.open(device);
  }
  fun void handle(string name, float raw_value, int value)
  {
    <<< name , value >>>;
    if(name=="Osc1Wave")
    {
      venom.setOsc1Wave(value);
    }
    if(name=="Osc1Oct")
    {
      venom.setOsc1Coarse((value/12)*12);
    }
    if(name=="Osc1Fine")
    {
      venom.setOsc1Fine(value);
    }
    if(name=="Osc1Lvl")
    {
      venom.setOsc1Level(value);
    }
    if(name=="Osc2Lvl")
    {
      venom.setOsc2Level(value);
    }
    if(name=="Osc3Lvl")
    {
      venom.setOsc3Level(value);
    }
  }
}


ZeroSLTop zero;

ZeroToVenom zeroToVenom;

zero.open(2);
zeroToVenom.open(3);

zero.addEncoderNumeric("Osc1Wave", ZeroSLEnum.Encoders+0, ZeroSLEnum.LeftLCD, 1, 0.2);
zero.addEncoderNumeric("Osc1Oct",  ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2, 1.0);
zero.addEncoderNumeric("Osc1Fine", ZeroSLEnum.Encoders+2, ZeroSLEnum.LeftLCD, 3, 0.5);
zero.addKnobNumeric("Osc1Lvl",ZeroSLEnum.Sliders+0,ZeroSLEnum.RightLCD,1);
zero.addKnobNumeric("Osc2Lvl",ZeroSLEnum.Sliders+1,ZeroSLEnum.RightLCD,2);
zero.addKnobNumeric("Osc3Lvl",ZeroSLEnum.Sliders+2,ZeroSLEnum.RightLCD,3);

//zero.addToggleLed("Two",ZeroSLEnum.LeftUpButton+1);
//zero.addToggleLed("Three",ZeroSLEnum.LeftUpButton+2);
//
//zero.addToggleNumeric("Five",ZeroSLEnum.LeftUpButton+4,ZeroSLEnum.LeftLCD,5);
//
//zero.addEncoderNumeric("Six",ZeroSLEnum.Encoders,ZeroSLEnum.LeftLCD,1,0.5);
//zero.addKnobNumeric("Seven",ZeroSLEnum.Knobs,ZeroSLEnum.LeftLCD,1);
//
//zero.addEncoderItems("Items", ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2,1.0,[ "Sine" ,"Saw", "Pulse", "Triang"]);

zero.setControlHandler(zeroToVenom);


for(0 => int i; i<20; 1+=>i)
{
  RawMidiSender.sendNoteOn(40,100,zeroToVenom.venom.mout);
  0.2::second => now;
  RawMidiSender.sendNoteOff(40,100,zeroToVenom.venom.mout);
  RawMidiSender.sendNoteOn(40+12,100,zeroToVenom.venom.mout);
  0.2::second => now;
  RawMidiSender.sendNoteOff(40+12,100,zeroToVenom.venom.mout);
  RawMidiSender.sendNoteOn(40+24,100,zeroToVenom.venom.mout);
  0.2::second => now;
  RawMidiSender.sendNoteOff(40+24,100,zeroToVenom.venom.mout);
}

zero.close();
