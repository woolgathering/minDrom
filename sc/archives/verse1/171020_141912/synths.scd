SynthDef(\player, {|outBus, buff, amp = 1|
  var sig;
  sig = PlayBuf.ar(2, buff, rate: BufRateScale.kr(buff), doneAction: 2); // play it back
  Out.ar(outBus, sig*amp); // output it
}).send(s);

SynthDef(\stretcher, {|outBus, buff = #[0,0], rate = 1, trans = 1, winSize = 0.2, timeDisp = 0.2, amp = 0.2|
  var sig;
  sig = TimeStretchStereo.ar(buff[0], buff[1], rate, trans, winSize, timeDisp); // play it back
  sig = HPF.ar(sig, 500);
  Out.ar(outBus, sig*amp); // output it
}).send(s);

SynthDef(\mainOut, {|inBus, amp = 0.5|
  var sig;
  sig = In.ar(inBus, 2);
  // sig = Greyhole.ar(sig,
  //   delayTime: 2, damp: 0, size: 1, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2);
  // // compressor???
  Out.ar(0, sig*amp);
}).send(s);

SynthDef(\fft, {|inBus, buffs = #[0,0], copy = #[0,0]|
  var sig;
  sig = In.ar(inBus, 2);
  FFT(buffs, sig); // works?

  // buffsCopy = ;
  PV_Copy(buffs, copy);
  PV_BinScramble(copy, MouseX.kr , 0.1, MouseY.kr > 0.5 );
  PV_MagAbove(copy, 10);

  // PV_Invert(copy);
  PV_MagBelow(buffs, 3);
  PV_CommonMul(buffs, copy, MouseX.kr(0, 50), 0);
  // PV_MagMinus(buffs, copy);
  // PV_MagAbove(buffs, 9);
  // PV_RandComb(buffs, MouseY.kr);
  // PV_BinScramble(buffs, MouseX.kr , 0.1, MouseY.kr > 0.5 );
  // PV_MagBelow(buffs, 5);
  // PV_PartialSynthP(buffs, MouseY.kr(0,pi * 2), numFrames: 100);



  // PV_MagMinus(buffs, buffsCopy);

  PV_MagSmooth(buffs, 0.99);
}).send(s);

SynthDef(\ifft, {|outBus, buffs = #[0,0]|
  var sig;
  sig = IFFT(buffs);
  Out.ar(outBus, sig);
}).send(s);





SynthDef(\writeSynth, {|inBus = 0, writeBuff, level = 1|
  var sig;
  sig = In.ar(inBus, 4) * level;
  RecordBuf.ar(sig, writeBuff);
}).send(s);
