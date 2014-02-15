
// Testing place for the ZeroSL
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

MidiIn min;

ZeroSL zero;


zero.open(1);
min.open(1);

zero.clear();

zero.write("Leonardo",1,0);

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
