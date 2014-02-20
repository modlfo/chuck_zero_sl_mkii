
// Testing place for the ZeroSL
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com


class ControlHandler extends ZeroSLHandler
{
  fun void handle(int control,int value)
  {
  	<<< "control ",control," value ",value >>>;
  }
}

ZeroSL zero;
ControlHandler controlHandler;
zero.setControlHandler(controlHandler);

zero.open(2);

zero.clear();

zero.writeFloatLabel(1.56433560876532, zero.LeftLCD, zero.Row2, 2);
zero.writeLabel("LeftUp",    zero.LeftLCD, zero.Row1, 2);
zero.writeLabel("LeftDown",  zero.LeftLCD, zero.Row2, 4);
zero.writeLabel("RigthUp",   zero.RigthLCD,zero.Row1, 6);
zero.writeLabel("RigthDown", zero.RigthLCD,zero.Row2, 8);

0 => int i;
0 => int j;

for(j;j<8;1+=>j){
  <<< "Moving ring " ,j>>>;
  for(0=>i;i<13;1+=>i) {
    zero.setLedRing(j,i%12);
    0.1::second => now;
  }
}

zero.close();
