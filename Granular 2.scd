Server.local.waitForBoot{
	Buffer.readChannel(s,"/Users/hugh/samples/auto harp up.wav" , 0, -1, 0, bufnum:0);

	s.sync;
	(
		SynthDef.new
		(\granular,
			{ arg out = 0, bufNum = 0, posLo = 0.0, posHi = 1.0,
				posRateE = 0, posRateM = 1, posDev = 0.01, trigRate = 100, trigRateDev = 0,
				trigRateOsc = 1, grainDur = 0.1, granDurDev = 0, rate = 1.0, rateDev = 0,
				panMax = 1, amp = 0.1, interp = 4;

				var trig, pan, pos, bufDur, bufDurSection, posDif, posRate;

				posDif = posHi - posLo;
				bufDur = BufDur.kr(bufNum);
				bufDurSection = bufDur * posDif;
				trig = Impulse.kr(LFDNoise3.kr(trigRateOsc, trigRate * trigRateDev, trigRate));
				posRate = 10 ** posRateE * posRateM;
				pos = posLo * bufDur +
				(Phasor.ar(0, BufRateScale.kr(bufNum) * posRate / SampleRate.ir, posLo * bufDur, posHi * bufDur) +
					(TRand.kr(-0.5, 0.5, trig) * posDev * bufDur)).mod(bufDurSection);
				pan = Demand.kr(trig, 0, Dseq([panMax, panMax.neg],inf) * 0.999);
				Out.ar(out, TGrains.ar(2, trig, bufNum, rate * (TRand.kr(-1, 1.0, trig) * rateDev + 1), pos,
					grainDur * (TRand.kr(-1, 1.0, trig) * granDurDev + 1), pan, amp, interp));
		}).add
	);

	s.sync;

	s.sendMsg(\s_new, "granular", 2000,1, 1, \bufNum,0);

	s.sync;


	MIDIClient.init;
	MIDIIn.connectAll;


	~posLoCC = 1;
	~posHiCC = 2;
	~posRateECC = 3;
	~posRateMCC = 4;
	~trigRateCC = 5;
	~trigRateOscCC = 6;
	~grainDurCC = 10;
	~rateCC = 8;
	~ampCC = 9;

	s.sync;
	(
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \posLo, val.linlin(0,127,0.01, 0.99))},~posLoCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \posHi, val.linlin(0,127,0.01, 0.99))},~posHiCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \posRateE, val.linlin(0,127,-3, 4))},~posRateECC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \posRateM, val.linlin(0,127,0.1, 10))},~posRateMCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \trigRate, val.linlin(0,127,1, 100))},~trigRateCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \trigRateOsc, val.linlin(0,127,0.1, 2))},~trigRateOscCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \grainDur, val.linlin(0,127,0.01, 5))},~grainDurCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \rate, val.linlin(0,127,0.1, 4))},~rateCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 2000, \amp, val.linlin(0,127,0.0,0.5))},~ampCC);
	);
}

