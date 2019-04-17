% Script to make high vs. low frequency and high vs. low amplitude
% plots of sin waves.  Output plots Used in "Sound.key", presented at
% Littlebrook Elementary School Science Expo Day 2018, Princeton NJ,
% 18-May-2018.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-May-2018, Version 2017b

close all
clear 

% Independent variable.
x = linspace(0, 16*pi, 1e5);

% Amplitude example.
y1 = 1*sin(x);
y2 = 4*sin(x);   % Higher amplitude.

fig1 = figure;
subplot(211)
plot(y1, 'LineWidth', 3);
ylim([-4 4])
axis off

subplot(212)
plot(y2, 'LineWidth', 3);
ylim([-4 4])
axis off

print(fig1, '-dpdf', 'amplitude.pdf');


% Frequency example.
y1 = sin(x);
y2 = sin(3*x);   % Higher frequency.

fig2 = figure;
subplot(211)
plot(y1, 'LineWidth', 3);
ylim([-1 1])
axis off

subplot(212)
plot(y2, 'LineWidth', 3);
ylim([-1 1])
axis off

print(fig1, '-dpdf', 'frequency.pdf');
