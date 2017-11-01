(
var parent = (), sound = ();

parent.thisDir = "~/Documents/jacob/pieces/minDrom".standardizePath; // this dir's path
parent.freeables = List.new(0);
parent.thisFile = parent.thisDir++"/sc/workbench/main.scd"; // get the path of this file
sound.path = parent.thisDir++"/sound/stems/verse1.wav"; // path to the sound
sound.synths = parent.thisDir++"/sc/synths.scd"; // path to the synths
sound.origBus = Bus.audio(s,2); // a stereo bus for the orig
sound.outBus = Bus.audio(s,2); // a bus that gets output
sound.fftBuffs = [Buffer.alloc(s, 2048), Buffer.alloc(s, 2048)]; // alloc two buffs for stereo fft (allocate this in the main Routine?)
sound.fftCopies = [Buffer.alloc(s, 2048), Buffer.alloc(s, 2048)]; // copies for more manipulations
sound.recPath = parent.thisDir++"/sound/rec/%/%_%.wav".format(sound.path.basename.splitext[0], sound.path.basename.splitext[0], Date.getDate.stamp); // the recording path (get the name of the file we're using)
parent.freeables.addAll(sound.origBus, sound.outBus, sound.fftBuffs, sound.fftCopies); // add these things to the freeables
parent.compileStringPath = parent.thisDir++"/sc/archives/%/%_%".format(sound.path.basename.splitext[0], sound.path.basename.splitext[0], Date.getDate.stamp);

sound.groups = ();
sound.groups.orig = ParGroup.new;
sound.groups.process = ParGroup.after(sound.groups.orig);
sound.groups.out = ParGroup.after(sound.groups.process);
parent.freeables.addAll(sound.groups);
File.include(sound.synths); // load the synths

CmdPeriod.doOnce({
  parent.freeables.do(_.free); // free the freeables on CmdPeriod
  if(sound.record) {s.stopRecording}; // stop recording (unnecessary??)
});

sound.record = false; // boolean whether or not to record <---------------------------------------------------------------RECORD??
sound.rate = 1; // the rate at which we read the file

Routine.run({
  // sound.buffer = Buffer.read(s, sound.path, action: {|thisBuff| parent.freeables.add(thisBuff)}); // read it as stereo and add it to freeables
  sound.buffer = Array.fill(2, {|i|
    var buff;
    buff = Buffer.readChannel(s, sound.path, channels: [i], action: {|thisBuff| parent.freeables.add(thisBuff)});
    s.sync;
    buff; // return
  });
  s.sync;
  if(sound.record) {
    var dir;
    s.record(sound.recPath); // record us
    // make a copy of these files so we can keep track of things
    dir = parent.thisDir ++ "/sc/archives" +/+ sound.path.basename.splitext[0] +/+ Date.getDate.stamp;
    "mkdir -p %".format(dir).unixCmd(
      {
        File.copy(parent.thisFile, dir+/+"main.scd"); // copy this file over for posterity
        File.copy(sound.synths, dir+/+"synths.scd"); // copy the synths, too
      },
    false); // make a directory and copy stuff over to it
  };
  s.sync;


  // Synth(\player, [outBus: sound.outBus, buff: sound.buffer], target: sound.groups.orig);
  Synth(\stretcher, [outBus: sound.origBus, buff: sound.buffer, rate: sound.rate, trans: 0.01, winSize: 0.1, timeDisp: 0.1],
    target: sound.groups.orig
  );
  Synth(\fft, [inBus: sound.origBus, buffs: sound.fftBuffs, copy: sound.fftCopies], target: sound.groups.process);
  Synth(\ifft, [outBus: sound.outBus, buffs: sound.fftBuffs], target: sound.groups.process, addAction: \addToTail);
  Synth(\mainOut, [inBus: sound.outBus, amp: -3.dbamp], target: sound.groups.out);
});

)
