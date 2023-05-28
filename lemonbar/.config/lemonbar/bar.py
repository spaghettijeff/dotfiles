#!/bin/python

from collections import OrderedDict
import re
import subprocess as sp
from time import time, strftime
import psutil

from lemonbar_manager import Module, Manager


color_bg="#282828"
color_bgl="#3c3836"
color_fg="#ebdbb2"
color_hl1="#fabd2f"
color_hl2="#d79921"
color_alert="#cc241d"

def wrap_btn(s, btn_label):
    return f'%{{A:{btn_label}:}}{s}%{{A}}'



class Const(Module):
    def __init__(self, value):
        """A constant value.

        Parameters:
            value (str): The value to output to the bar.
        """
        super().__init__()
        self._value = value

    def output(self):
        return self._value



class Clock(Module):
    def __init__(self):
        """A simple clock.

        The clock can be clicked and will switch to the date for a period of
        time.
        """
        super().__init__()
        self.wait_time = 1  # How often to update this module
        self._toggled = False  # When the clock was toggled

    def output(self):
        # If the clock has been toggled for more than a certain period of time
        if self._toggled:
            return  f'%{{B{color_hl2}}}%{{F{color_bg}}}' + \
                    '%{A:toggle_clock:}' + \
                    strftime(' %r | %a %b %d, %Y ') + \
                    '%{A}' + \
                    f'%{{B-}}%{{F-}}'
        else:
            return  f'%{{B{color_hl2}}}%{{F{color_bg}}}' + \
                     '%{A:toggle_clock:}' + \
                     strftime(' %r ') + \
                     '%{A}' + \
                     f'%{{B-}}%{{F-}}' 

    def handle_event(self, event):
        if event == 'toggle_clock':
            self._toggled = not self._toggled
        else:
            return


class Volume(Module):
    def __init__(self, device='@DEFAULT_SINK@'):
        """A simple Pulseaudio volume control.

        Parameters:
            device (str): The name of the Pulseaudio sink (default = @DEFAULT_SINK@).
        """
        super().__init__()
        self.wait_time = 1
        self._device = device
        self._regex = re.compile(r'(\d{1,3})%')  # For parsing ALSA output
        self._current_level = self._get_level()

    def _parse(self, data):
        """Parse the output from pactl command.

        Parameters::
            data (str): The output from pactl.

        Returns:
            int: An integer between 0 and 100 (inclusive) representing the
                volume level.
        """

        levels = [int(level) for level in re.findall(self._regex, data)]
        return int(sum(levels) / len(levels))

    def _get_level(self):
        """Get the current volume level for the device.

        Returns:
            int: An integer between 0 and 100 (inclusive) representing the
                volume level.
        """
        process = sp.Popen(
            ['pactl', 'get-sink-mute', self._device],
            stdout=sp.PIPE,
            encoding='UTF-8')
        mute, _ = process.communicate()
        mute = mute[6]
        if mute == 'y':
            return None
        
        process = sp.Popen(
            ['pactl', 'get-sink-volume', self._device],
            stdout=sp.PIPE,
            encoding='UTF-8')
        out, _ = process.communicate()
        #print(out)
        return self._parse(out)
    
    def handle_event(self, event):
        if event == 'toggle_mute':
            sp.Popen(['pactl', 'set-sink-mute', self._device, 'toggle'])
        else:
            return

    def output(self):
        self._current_level = self._get_level()
        if self._current_level:
            btn = wrap_btn('墳', 'toggle_mute')
            return f'%{{T2}}{btn}%{{T-}} {self._current_level:d}%'
        else:
            btn = wrap_btn('ﱝ', 'toggle_mute')
            return f'%{{T2}}{btn}%{{T-}}'

class Battery(Module):
    def __init__(self):
        super().__init__()
        self.wait_time = 10
    
    def _get_battery(self):
        with open('/sys/class/power_supply/BAT0/capacity', 'r') as f_bat:
            battery = int(f_bat.read()[:-1])
        return battery
    
    def _get_ac(self):
        with open('/sys/class/power_supply/AC/online', 'r') as f_ac:
            ac = int(f_ac.read()[:-1])
        return ac

    def handle_event(self, event):
        return


    def output(self):
        bat = self._get_battery()
        ac = self._get_ac()
 
        if ac == 1:
            icon="ﮣ"
        elif bat > 90:
            icon=""
        elif bat > 80:
            icon=""
        elif bat > 70:
            icon=""
        elif bat > 60:
            icon=""
        elif bat > 50:
            icon=""
        elif bat > 40: 
            icon=""
        elif bat > 30: 
            icon=""
        elif bat > 20: 
            icon=""
        elif bat > 10: 
            icon=""
        else:
            icon=""
        return f'%{{T2}}{icon}%{{T-}} {bat}%'

class Music(Module):
    def __init__(self):
        super().__init__()
        self.wait_time = 5

    def output(self):
        process = sp.run(
            ['mpc', 'current', '--format', '%title%'],
            stdout=sp.PIPE,
            encoding='UTF-8')
        song = process.stdout[:-1]
        return f'%{{T2}}{wrap_btn("玲", "mus_prev")} {wrap_btn("懶", "mus_play")} {wrap_btn("怜", "mus_next")}%{{T-}} {song}'
    
    def handle_event(self, event):
        if event == 'mus_prev':
            process = sp.run(
                ['mpc', 'prev'],
                stdout=sp.PIPE,
                encoding='UTF-8')

        elif event == 'mus_next':
            process = sp.run(
                ['mpc', 'next'],
                stdout=sp.PIPE,
                encoding='UTF-8')

        elif event == 'mus_play':
            process = sp.run(
                ['mpc', 'toggle'],
                stdout=sp.PIPE,
                encoding='UTF-8')
        else:
            return


class BSPWM(Module):
    def __init__(self, monitor):
        """A BSPWM desktop indicator.

        Parameters:
            monitor (str): The name of the monitor to show the desktop status
                for.
        """
        super().__init__()

        # Subscribe to BSPWM events and make the `Manager` class wait on it's
        # stdout before updating the module.
        self._subscription_process = sp.Popen(
            ['bspc', 'subscribe'], stdout=sp.PIPE, encoding='UTF-8')
        self.readables = [self._subscription_process.stdout]

        self._monitor = monitor

        # The different format strings use to display the stauts of the desktops
        self._formats = {
            'O': f'%{{F{color_hl1}}}  %{{F-}}',  # Focused, Occupied
            'F': f'%{{F{color_hl1}}}  %{{F-}}',  # Focused, Free
            'U': f'%{{F#CF6A4C}}  %{{F-}}',     # Focused, Urgent

            'o': f'  ',  # Unfocused, Occupied
            'f': f'  ',                   # Unfocused, Free
            'u': f'  ',  # Unfocused, Urgent
        }

    def _parse_event(self, event):
        """Parse a BSPWM event.

        Parameters:
            event (str): The BSPWM event.

        Returns:
            OrderedDict: Keys are desktop names, values are the status.
        """
        desktops = OrderedDict()

        event = event.lstrip('W')
        items = event.split(':')

        on_monitor = False

        for item in items:
            k, v = item[0], item[1:]

            if k in 'Mm':
                on_monitor = v == self._monitor
            elif on_monitor and k in 'OoFfUu':
                desktops[v] = k

        return desktops

    def output(self):
        event = self.readables[0].readline().strip()

        desktops = self._parse_event(event)

        output = []
        for desktop, state in desktops.items():
            output.append(self._formats[state])

        output = f'%{{B{color_bgl}}}%{{T2}}' + ''.join(output) + '%{T-}%{B-}'
        return output

    def handle_event(self, event):
        if not event.startswith('focus_desktop_'):
            return

        desktop = event[event.rindex('_')+1:]
        sp.Popen(['bspc', 'desktop', '--focus', '{}.local'.format(desktop)])

class Window(Module):
    def __init__(self, monitor):
        super().__init__()
        self._title = ''
        self._monitor = monitor
        self._regex = re.compile('"(.*)"')
        process = sp.run(['bspc', 'query', '-M', '-m', monitor],
            stdout=sp.PIPE,
            encoding='UTF-8')
        self._mon_id = process.stdout[:-1]
        self._subscription_process = sp.Popen(
            ['bspc', 'subscribe', 'node_focus', 'node_remove', 'desktop_focus'], 
            stdout=sp.PIPE, 
            encoding='UTF-8')
        self.readables = [self._subscription_process.stdout]

    def output(self):
        event = self.readables[0].readline().strip().split(' ')
        if event[1] == self._mon_id:
            process = sp.Popen(['bspc', 'query', '-N', '-n', '.active', '-m', self._monitor],
                stdout=sp.PIPE,
                encoding='UTF-8')
            winid, _ = process.communicate()
            if winid != '':
                process = sp.Popen(['xprop', '-id', winid, 'WM_NAME'],
                    stdout=sp.PIPE,
                    encoding='UTF-8')
                out, _ = process.communicate()

                self._title = self._regex.findall(out)[0]
            else:
                self._title = ''
        return self._title[0:64]



class CPU(Module):
    def __init__(self):
        super().__init__()
        self.wait_time = 10

    def output(self):
        usage = psutil.cpu_percent(interval=1)
        return f'CPU:{usage}%'


class Memory(Module):
    def __init__(self):
        super().__init__()
        self.wait_time = 10

    def output(self):
        usage = int(psutil.virtual_memory()[3] * 1e-6)
        return f'MEM:{usage}M'

class Network(Module):
    def __init__(self, interface):
        super().__init__()
        self.wait_time = 10
        self._interface = interface 

    def output(self):
        if psutil.net_if_stats()[self._interface].isup:
            ip = psutil.net_if_addrs()[self._interface][0].address
            return f'{self._interface}:{ip}'

        else:
            return f'{self._interface}:OFFLINE'


# Define the modules to put on the bar (in order)
modules = (
    Const('%{Sf}%{l}'),
    BSPWM('eDP-1'),
    Const('  '),
    Window('eDP-1'),
    Const('%{r}'),
    Volume('@DEFAULT_SINK@'),
    Const('  '),
    Network('wlp3s0'),
    Const('  '),
    Memory(),
    Const('  '),
    CPU(), 
    Const('  '),
    Battery(),
    Const('  '),
    Clock(),

#   Const('%{Sl}%{l}'),
#   BSPWM('HDMI-1-0'),
#   Const('  '),
#   Window('HDMI-1-0'),
#   Const('%{r}'),
#   Volume('@DEFAULT_SINK@'),
#   Const('  '),
#   Memory(),
#   Const('  '),
#   CPU(), 
#   Const('  '),
#   Clock(),
)


# Lemonbar command
command = (
    'lemonbar',
    '-g', 'x22',
    '-B', f'{color_bg}',
    '-F', f'{color_fg}',
    '-U', '#D8AD4C',
    '-u', '2',
    '-o', '-1',  # Push Noto down 1px
    '-o', '-1', # Pull Material Desicn Icons up 1px
    '-f', 'Hurmit NerdFont Mono:style=medium:size=8',
    '-f', 'Hurmit NerdFont Mono:style=medium:size=11',
)

# Run the bar with the given modules
with Manager(command, modules) as mgr:
    mgr.loop()
