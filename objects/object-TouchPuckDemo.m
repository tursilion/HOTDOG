/*

 HOT DOG Linux

 Copyright (c) 2020 Arthur Choung. All rights reserved.

 Email: arthur -at- hotdoglinux.com

 This file is part of HOT DOG Linux.

 HOT DOG Linux is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.

 */

#import "HOTDOG.h"

#include <fcntl.h>
#include <linux/input.h>

@implementation Definitions(fjweriofmksdlfmklsdmfkljeifjiowe)
+ (id)TouchPuckDemo:(id)path
{
    id obj = [@"TouchPuckDemo" asInstance];
    if (![obj openTrackpad:path]) {
NSLog(@"Unable to open trackpad device '%@'\n", path);
        exit(1);
    }
    return obj;
}
@end

#define MAX_SLOTS 10

@interface TouchPuckDemo : IvarObject
{
    double _puckX;
    double _puckY;
    BOOL _trackpadIsOpen;
    int _trackpadFD;
    int _minX;
    int _minY;
    int _maxX;
    int _maxY;
    int _x[MAX_SLOTS];
    int _startX[MAX_SLOTS];
    __u64 _xTime[MAX_SLOTS];
    int _y[MAX_SLOTS];
    int _startY[MAX_SLOTS];
    __u64 _yTime[MAX_SLOTS];
    int _deltaX[MAX_SLOTS];
    int _deltaY[MAX_SLOTS];
    int _highestDeltaX[MAX_SLOTS];
    int _highestDeltaY[MAX_SLOTS];
    int _momentumX[MAX_SLOTS];
    int _momentumY[MAX_SLOTS];
    int _trackingID[MAX_SLOTS];
    int _pressure[MAX_SLOTS];
    int _code[MAX_SLOTS];
}
@end
@implementation TouchPuckDemo

- (int)openTrackpad:(id)path
{
    _trackpadFD = open([path UTF8String], O_RDONLY|O_NONBLOCK);
    if (_trackpadFD < 0) {
NSLog(@"unable to open %@", path);
        return 0;
    }
    _trackpadIsOpen = 1;
    return 1;
}

- (void)closeTrackpad
{
    if (_trackpadIsOpen) {
        close(_trackpadFD);
        _trackpadIsOpen = 0;
    }
}

- (int)readTrackpadEvent
{
    static const __u64 ms = 1000;
    static int slot;
    static __u64 lastEventTime = 0;

    struct input_event ev;
    int n = read(_trackpadFD, &ev, sizeof(struct input_event));
    if (n < 0) {
        return 0;
    }
    __u64 evtime = ev.time.tv_usec / ms + ev.time.tv_sec * ms;
    if (ev.type == EV_ABS && ev.code == ABS_MT_SLOT) {
        slot = ev.value;
        if (slot >= MAX_SLOTS) {
            slot = 0;
        }
    }
    if (evtime - _xTime[slot] >= 20) {
        _highestDeltaX[slot] = 0;
        _highestDeltaY[slot] = 0;
    }
    char *code = NULL;
    if (ev.code == ABS_X) {
        code = "ABS_X";
    } else if (ev.code == ABS_Y) {
        code = "ABS_Y";
    } else if (ev.code == ABS_PRESSURE) {
        code = "ABS_PRESSURE";
    } else if (ev.code == ABS_MT_SLOT) {
        code = "ABS_MT_SLOT";
    } else if (ev.code == ABS_MT_POSITION_X) {
        fprintf(stderr, "x time %llu slot %02d type %01d code %04x value %d\n", evtime - lastEventTime, slot, ev.type, ev.code, ev.value);
        code = "ABS_MT_POSITION_X";
        if (_x[slot]) {
            _deltaX[slot] = ev.value - _x[slot];
            if (_deltaX[slot] > 0) {
                if (_deltaX[slot] > _highestDeltaX[slot]) {
                    _highestDeltaX[slot] = _deltaX[slot];
                }
            }
            if (_deltaX[slot] < 0) {
                if (_deltaX[slot] < _highestDeltaX[slot]) {
                    _highestDeltaX[slot] = _deltaX[slot];
                }
            }
        } else {
            _deltaX[slot] = 0;
            _highestDeltaX[slot] = 0;
        }
        if (!_startX[slot]) {
            _startX[slot] = ev.value;
        }
        _x[slot] = ev.value;
        _xTime[slot] = evtime;
        if (!_minX || (ev.value < _minX)) {
            _minX = ev.value;
        }
        if (ev.value > _maxX) {
            _maxX = ev.value;
        }
        _code[slot] = ev.code;
    } else if (ev.code == ABS_MT_POSITION_Y) {
        fprintf(stderr, "y time %llu slot %02d type %01d code %04x value %d\n", evtime - lastEventTime, slot, ev.type, ev.code, ev.value);
        code = "ABS_MT_POSITION_Y";
        if (_y[slot]) {
            _deltaY[slot] = ev.value - _y[slot];
            if (_deltaY[slot] > 0) {
                if (_deltaY[slot] > _highestDeltaY[slot]) {
                    _highestDeltaY[slot] = _deltaY[slot];
                }
            }
            if (_deltaY[slot] < 0) {
                if (_deltaY[slot] < _highestDeltaY[slot]) {
                    _highestDeltaY[slot] = _deltaY[slot];
                }
            }
        } else {
            _deltaY[slot] = 0;
            _highestDeltaY[slot] = 0;
        }
        if (!_startY[slot]) {
            _startY[slot] = ev.value;
        }
        _y[slot] = ev.value;
        _yTime[slot] = evtime;
        if (!_minY || (ev.value < _minY)) {
            _minY = ev.value;
        }
        if (ev.value > _maxY) {
            _maxY = ev.value;
        }
        _code[slot] = ev.code;
    } else if (ev.code == ABS_MT_TRACKING_ID) {
        fprintf(stderr, "trackingID time %llu slot %02d type %01d code %04x value %d\n", evtime - lastEventTime, slot, ev.type, ev.code, ev.value);
        code = "ABS_MT_TRACKING_ID";
        _trackingID[slot] = ev.value;
        if (ev.value == -1) {
            _momentumX[slot] = _highestDeltaX[slot];
            _momentumY[slot] = _highestDeltaY[slot];
            _highestDeltaX[slot] = 0;
            _highestDeltaY[slot] = 0;
        } else {
            _deltaX[slot] = 0;
            _deltaY[slot] = 0;
            _x[slot] = 0;
            _y[slot] = 0;
            _startX[slot] = 0;
            _startY[slot] = 0;
        }
        _code[slot] = ev.code;
    } else if (ev.code == ABS_MT_PRESSURE) {
        fprintf(stderr, "pressure time %llu slot %02d type %01d code %04x value %d\n", evtime - lastEventTime, slot, ev.type, ev.code, ev.value);
        code = "ABS_MT_PRESSURE";
        _code[slot] = ev.code;
    } else {
        fprintf(stderr, "unknown time %llu slot %02d type %01d code %04x %s value %d\n", evtime - lastEventTime, slot, ev.type, ev.code, code, ev.value);
    }
    lastEventTime = evtime;

    return 1;
}

- (int)fileDescriptor
{
    if (_trackpadIsOpen) {
        return _trackpadFD;
    }
    return -1;
}

- (void)handleFileDescriptor
{
    while([self readTrackpadEvent]);
}

- (BOOL)shouldAnimate
{
    return YES;
}

- (void)beginIteration:(id)event rect:(Int4)r
{
    if (_minX && _maxX && (_maxX - _minX)) {
        int diffMinMaxX = _maxX - _minX;
        int diffMinMaxY = _maxY - _minY;
        if (diffMinMaxX < 2500) {
            diffMinMaxX = 2500;
        }
        if (diffMinMaxY < 2500) {
            diffMinMaxY = 2500;
        }
//NSLog(@"minX %d maxX %d minY %d maxY %d", _minX, _maxX, _minY, _maxY);
        if (_trackingID[0] != -1) {
            _puckX += (double)(_deltaX[0]) / (double)(diffMinMaxX);
            _puckY += (double)(_deltaY[0]) / (double)(diffMinMaxY);
            _deltaX[0] = 0;
            _deltaY[0] = 0;
        } else {
            _puckX += (double)(_momentumX[0]) / (double)(diffMinMaxX);
            _puckY += (double)(_momentumY[0]) / (double)(diffMinMaxY);
            _momentumX[0] = (int)((double)_momentumX[0] * 0.9);
            _momentumY[0] = (int)((double)_momentumY[0] * 0.9);
        }
        if (_puckX < -1.0) {
            _puckX = -1.0;
            _momentumX[0] *= -1.0;
        }
        if (_puckX > 1.0) {
            _puckX = 1.0;
            _momentumX[0] *= -1.0;
        }
        if (_puckY < -1.0) {
            _puckY = -1.0;
            _momentumY[0] *= -1.0;
        }
        if (_puckY > 1.0) {
            _puckY = 1.0;
            _momentumY[0] *= -1.0;
        }
    }
}

- (void)drawInBitmap:(id)bitmap rect:(Int4)r
{
    [bitmap setColor:@"black"];
    [bitmap fillRect:r];
    [bitmap setColor:@"blue"];

    int radius = 5;
    int puckX = r.w * ((_puckX + 1.0)/2.0);
    int puckY = r.h * ((_puckY + 1.0)/2.0);
    [bitmap fillRectangleAtX:puckX-radius y:puckY-radius w:radius*2 h:radius*2];
}

@end
