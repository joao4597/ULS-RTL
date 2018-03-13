fs = 48 * 10^3;
f  = 6000;
fc = 15 * 10^3;

t = 0:1/fs:(1/fs)*(fs/4-1);

unCodedSignal = cos(2*pi*fc*t);
signal = zeros(1, length(unCodedSignal));

kasamiSequence = comm.KasamiSequence('Polynomial', [12 6 4 1 0], 'InitialConditions',[0 0 0 0 0 0 0 0 0 0 1 1],'SamplesPerFrame', f*(length(t)/fs));
PRBS = kasamiSequence.step();
extendedPRBS = [];


z = 0;
for x = 1:fs/f:length(unCodedSignal)
    z = z + 1;
    
    if PRBS(z) == 0
        PRBS(z) = -1;
    end
    
    for y = x:1:x + (fs/f) - 1
        signal(y) = unCodedSignal(y) * PRBS(z);
        extendedPRBS = [extendedPRBS PRBS(z)];
    end
end

%signal = conv(signal, bandpass, 'same');

%{
figure(1)
plot(abs(fft(signal)));

signalFiltered = conv(signal, filter300, 'same');


figure(2)
plot(abs(fft(signalFiltered)));

figure(3)
plot(xcorr(signal, signal));

figure(4)
plot(xcorr(signalFiltered, signalFiltered));

%figure(5)
%plot(xcorr(signal, signalFiltered));

sound(signal, 48000)

figure(6)
plot(xcorr(unCodedSignal, unCodedSignal))

figure(7)
plot(xcorr(extendedPRBS, extendedPRBS))

figure(8)
plot(xcorr(unCodedSignal, unCodedSignal).*xcorr(extendedPRBS, extendedPRBS))
%}

sound(signal, 48000)


%guardTimeSignal = [signal signal];

%sound(guardTimeSignal, 48000)

%plot(xcorr(guardTimeSignal, guardTimeSignal));
