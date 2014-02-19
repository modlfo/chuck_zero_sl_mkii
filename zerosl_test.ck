
// Testing place for the ZeroSL
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

MidiIn min;

ZeroSL zero;


zero.open(1);
min.open(1);

zero.clear();

zero.writeLabel("LeftUp",0,1,2);
zero.writeFloatLabel(1.564335632,0,2,2);
zero.writeLabel("LeftDown",0,2,4);
zero.writeLabel("RigthUp",1,1,6);
zero.writeLabel("RigthDown",1,2,8);

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
