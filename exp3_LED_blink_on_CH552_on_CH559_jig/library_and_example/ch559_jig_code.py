"""
Python client for the CH552 automatic test jig (CH559 controller over USB serial).

Hardware context (see exp3 README and upstream project):
  A CH559 on the jig drives a CH446Q switch matrix so any CH552 pin can be
  routed to CH559 GPIO, LEDs, or headers. The CH559 can power-cycle the CH552
  and force bootloader entry. A host PC (often a Raspberry Pi in CI) compiles
  and uploads firmware to the CH552 over USB using a separate tool (e.g.
  vnproch55x); this library only speaks to the CH559.

Firmware (serial protocol implementation):
  CH559_firmware/controller_ch559_sketch/ — CH55xduino sketch; USB CDC string
  commands (I, C/c, B, b, R/r, A/a, W, w, T, U, …) are parsed there.

Upstream documentation and full test flow:
  https://github.com/DeqingSun/CH552-Automatic-Test-Jig

Typical usage:
  1. pip install pyserial
  2. jig = CH559_jig(); jig.connect()  # finds port by USB serial "CH559 jig"
  3. jig.initailize()  # reset matrix and GPIO state on the controller
  4. jig.connect_pins(jig.PIN_CH552_P33_X, jig.PIN_CH559_P25)  # example route
  5. digital_read / digital_write / analog_* use the firmware GPIO index (see
     pinUtil.c), not the PIN_CH559_* values — those constants are CH446 Y
     indices only for connect_pins / disconnect_pins.
  6. jig.enter_bootloader_mode() before flashing CH552; disconnect when done

Batch testing pattern (see reference/run_arduino_test.py):
  connect → enter_bootloader_mode() → disconnect → run uploader on CH552 USB
  → run per-sketch test script that imports this class again for assertions.

wait_for_input_time:
  Many methods accept wait_for_input_time (seconds). 0 means send only and
  treat as success without waiting for a reply. >0 waits for a response line
  containing the expected prefix (used when you need confirmation or a value).
"""

import time
import serial
import serial.tools.list_ports


class CH559_jig:
    """USB-serial bridge to CH559 jig firmware: matrix routing, DUT control, and GPIO/UART."""

    def __init__(self):
        # CH446 matrix X-side: nets toward the CH552 (DUT). Pass to connect_pins / disconnect_pins as pin_CH552.
        self.PIN_CH552_P30_X =       0
        self.PIN_CH552_P31_X =       1
        self.PIN_CH552_RST_X =       2
        self.PIN_CH552_P17_X =       3
        self.PIN_CH552_P16_X =       4
        self.PIN_CH552_P15_X =       5
        self.PIN_CH552_DP_PULLUP_X = 6
        self.PIN_CH552_P34_X =       7
        self.PIN_CH552_P33_X =       8
        self.PIN_CH552_P11_X =       9
        self.PIN_EXT_LED_10_X =     10
        self.PIN_EXT_LED_11_X =     11
        self.PIN_CH552_P14_X =      12
        self.PIN_CH552_P32_X =      13
        self.PIN_CH552_P37_X =      14
        self.PIN_CH552_P36_X =      15

        # CH446 matrix Y-side: CH559 chip resources (GPIO, RC node, ext header). Pass as pin_CH559.
        self.PIN_CH559_P32 =         0
        self.PIN_CH559_P03 =         1
        self.PIN_CH559_P02 =         2
        self.PIN_CH559_P12_RC =      3
        self.PIN_CH559_P25 =         4
        self.PIN_CH559_P26 =         5
        self.PIN_CH559_P27 =         6
        self.PIN_EXT_PIN_Y7  =       7

        self.serial_port = None  # pyserial handle (USB CDC to CH559).
        self.serial_buffer = ""  # Incomplete line reassembly from USB reads.
        self.uart0_buffer = ""  # Bytes from target UART forwarded as "U:..." lines by firmware.
        self.print_serial_input = False  # If True, check_input() prints every completed line.

    def connect(self):
        """Open the serial port whose USB iSerial is CH559 jig or CH559_JIG; return True on success."""
        ch559_port = None
        for port in serial.tools.list_ports.comports():
            if ((port.serial_number == "CH559 jig") or (port.serial_number == "CH559_JIG")):
                ch559_port = port
                break
        if (ch559_port == None):
            print("CH559 jig not found")
            return False
        try:
            self.serial_port = serial.Serial(ch559_port.device, 115200, timeout=0)
        except Exception as e:
            print("CH559 jig open failed on "+ch559_port.device+" with error: "+type(e).__name__)
            return False
        if (self.serial_port == None):
            print("CH559 jig open failed on "+ch559_port.device)
            return False
        return True

    def disconnect(self):
        """Close the serial port if open."""
        if (self.serial_port == None):
            return
        self.serial_port.close()
        self.serial_port = None

    def check_input(self):
        """Drain available USB bytes, split on newlines, return list of complete text lines.

        Side effects: lines starting with ``U:`` append payload to ``uart0_buffer`` (target UART0
        bridged to USB). Optionally prints lines when ``print_serial_input`` is set.
        """
        return_list = []
        if (self.serial_port == None):
            return return_list
        if (self.serial_port.in_waiting == 0):
            return return_list
        input_bytes = self.serial_port.read(self.serial_port.in_waiting)
        input_string = input_bytes.decode('ascii', errors='ignore')
        while ( (pos_newline := input_string.find('\n')) >=0 ):
            part_before_newline = input_string[0:pos_newline]
            part_after_newline = input_string[pos_newline+1:]
            self.serial_buffer = self.serial_buffer+part_before_newline
            if (len(self.serial_buffer)>0):
                if (self.print_serial_input):
                    print(self.serial_buffer)
                if (self.serial_buffer.startswith("U:")):
                    self.uart0_buffer = self.uart0_buffer + self.serial_buffer[2:].strip("\n\r")
                return_list.append(self.serial_buffer.strip())
            self.serial_buffer = ""
            input_string = part_after_newline
        self.serial_buffer = self.serial_buffer+input_string
        return return_list

    def write_string_wait_for_response(self, string, string_to_wait, wait_for_input_time):
        """Write ``string`` to USB; if ``wait_for_input_time`` > 0, poll until a line contains ``string_to_wait``."""
        if (self.serial_port == None):
            return ""
        if (len(string)>0):
            self.serial_port.write(string.encode('ascii'))
        if (wait_for_input_time == 0):
            #assume the command got processed successfully
            return ""
        else:
            #wait for the input
            if (len(string)>0):
                self.serial_port.flush()
            start_time = time.monotonic()
            while (time.monotonic() - start_time < wait_for_input_time):
                time.sleep(0.001)
                response = self.check_input()
                if (len(response) > 0):
                    for line in response:
                        if string_to_wait in line:
                            return line
            return ""

    def initailize(self, wait_for_input_time=0):
        """Send ``I`` (initialize): CH446 reset, restore pins, clear pin subscriptions on firmware."""
        command = "I\n"
        write_response = self.write_string_wait_for_response(command, "I:", wait_for_input_time)
        if (wait_for_input_time == 0):
            return True
        else:
            return (len(write_response)>0)

    def connect_pins(self, pin_CH552, pin_CH559, wait_for_input_time=0):
        """Close one matrix crosspoint: tie CH552 side ``pin_CH552`` to CH559 resource ``pin_CH559`` (``C`` command)."""
        command = f"C{pin_CH552:X}{pin_CH559:X}\n"
        write_response = self.write_string_wait_for_response(command, "C:", wait_for_input_time)
        if (wait_for_input_time == 0):
            return True
        else:
            return (len(write_response)>0)

    def disconnect_pins(self, pin_CH552, pin_CH559, wait_for_input_time=0):
        """Open that crosspoint again (lowercase ``c`` command)."""
        command = f"c{pin_CH552:X}{pin_CH559:X}\n"
        write_response = self.write_string_wait_for_response(command, "c:", wait_for_input_time)
        if (wait_for_input_time == 0):
            return True
        else:
            return (len(write_response)>0)

    def digital_pin_subscribe(self, pin, wait_for_input_time=0):
        """``r`` + pin: one-shot read and subscribe; firmware then streams ``rNN:0|1`` about every 25 ms until changed.

        ``pin`` is the firmware GPIO index (same numbering as ``digital_read``).
        """
        command = f"r{pin:02d}\n"
        responseHeader = f"r{pin:02d}:"
        write_response = self.write_string_wait_for_response(command, responseHeader, wait_for_input_time)
        if (wait_for_input_time == 0):
            return None
        else:
            if (len(write_response)>0):
                try:
                    colon_pos = write_response.find(":")
                    return (int(write_response[colon_pos+1])>0)
                except:
                    return None
            else:
                return None

    def analog_pin_subscribe(self, pin, wait_for_input_time=0):
        """``a`` + pin: subscribe to repeated analog reports (firmware only supports GPIO 12 for this path)."""
        command = f"a{pin:02d}\n"
        responseHeader = f"a{pin:02d}:"
        write_response = self.write_string_wait_for_response(command, responseHeader, wait_for_input_time)
        if (wait_for_input_time == 0):
            return None
        else:
            if (len(write_response)>0):
                try:
                    colon_pos = write_response.find(":")
                    return (int(write_response[colon_pos+1:]))
                except:
                    return None
            else:
                return None

    def check_digital_pin_subscription(self, pin, wait_for_input_time=0):
        """Without sending a new command, wait for the next ``rNN:`` line (works while subscribed). Returns bool or None."""
        command = ""
        responseHeader = f"r{pin:02d}:"
        write_response = self.write_string_wait_for_response(command, responseHeader, wait_for_input_time)
        if (wait_for_input_time == 0):
            return None
        else:
            if (len(write_response)>0):
                try:
                    colon_pos = write_response.find(":")
                    return (int(write_response[colon_pos+1])>0)
                except:
                    return None
            else:
                return None

    def check_analog_pin_subscription(self, pin, wait_for_input_time=0):
        """Wait for next ``aNN:`` analog line for the subscribed pin."""
        command = ""
        responseHeader = f"a{pin:02d}:"
        write_response = self.write_string_wait_for_response(command, responseHeader, wait_for_input_time)
        if (wait_for_input_time == 0):
            return None
        else:
            if (len(write_response)>0):
                try:
                    colon_pos = write_response.find(":")
                    return (int(write_response[colon_pos+1:]))
                except:
                    return None
            else:
                return None

    def analog_read(self, pin, wait_for_input_time=1):
        """Single-shot ``A`` read; clears analog subscription. Firmware accepts pin 12 for analog (GPIO index)."""
        command = f"A{pin:02d}\n"
        responseHeader = f"A{pin:02d}:"
        write_response = self.write_string_wait_for_response(command, responseHeader, wait_for_input_time)
        if (wait_for_input_time == 0):
            return None
        else:
            if (len(write_response)>0):
                try:
                    colon_pos = write_response.find(":")
                    return (int(write_response[colon_pos+1:]))
                except:
                    return None
            else:
                return None

    def analog_write(self, pin, value, wait_for_input_time=0):
        """PWM / DAC-style ``w``: GPIO 12 (~20 kHz) or 25 (~4 kHz) per firmware; ``value`` is two hex digits."""
        command = f"w{pin:02d}{value:02x}\n"
        write_response = self.write_string_wait_for_response(command, f"w{pin:02d}:", wait_for_input_time)
        if (wait_for_input_time == 0):
            return True
        else:
            if (len(write_response)==0):
                return False
            if ("not valid" in write_response):
                return False
            return True

    def digital_write(self, pin, value, wait_for_input_time=0):
        """Drive CH559 GPIO ``pin`` high (1) or low (0); ``value`` may be bool or int.

        ``pin`` is the firmware GPIO index (``W``/``R`` commands), not a ``PIN_CH559_*`` matrix constant.
        """
        if (value == True):
            value = 1
        if (value == False):
            value = 0
        command = f"W{pin:02d}{value}\n"
        write_response = self.write_string_wait_for_response(command, f"W{pin:02d}:", wait_for_input_time)
        if (wait_for_input_time == 0):
            return True
        else:
            if (len(write_response)==0):
                return False
            if ("not valid" in write_response):
                return False
            return True

    def digital_read(self, pin, wait_for_input_time=1):
        """Single-shot ``R`` read; clears digital subscription. ``pin`` is the firmware GPIO index."""
        command = f"R{pin:02d}\n"
        responseHeader = f"R{pin:02d}:"
        write_response = self.write_string_wait_for_response(command, responseHeader, wait_for_input_time)
        if (wait_for_input_time == 0):
            return None
        else:
            if (len(write_response)>0):
                try:
                    colon_pos = write_response.find(":")
                    return (int(write_response[colon_pos+1])>0)
                except:
                    return None
            else:
                return None

    def enter_bootloader_mode(self):
        """Sequence CH552 into USB bootloader (matrix + power routing); call before host uploads hex via CH552 USB."""
        command = "B\n"
        write_response = self.write_string_wait_for_response(command, "B:", 1)
        if (len(write_response)==0):
            return False
        return True

    def reboot_target(self):
        """Reset CH552 out of bootloader into user firmware (``b`` command)."""
        command = "b\n"
        write_response = self.write_string_wait_for_response(command, "b:", 1)
        if (len(write_response)==0):
            return False
        return True

    def init_uart0(self, baudrate=115200, wait_for_input_time=1):
        """Enable UART0 from CH559 toward the routed target wiring at ``baudrate`` (multiple of 9600); 0× disables."""
        baudrateMuliplexer = int(baudrate/9600)
        command = f"T{baudrateMuliplexer:01x}\n"
        responseHeader = f"T:"
        write_response = self.write_string_wait_for_response(command, responseHeader, wait_for_input_time)
        if (wait_for_input_time == 0):
            return None
        else:
            if (len(write_response)>0):
                try:
                    colon_pos = write_response.find(":")
                    after_pos_content = write_response[colon_pos+1:]
                    if after_pos_content == "disable UART":
                        return 0
                    else:
                        return (int(after_pos_content))
                except:
                    return None
            else:
                return None

    def uart0_send_string(self, string_to_send):
        """Send text to target UART0; newlines must be escaped as ``\\n`` / ``\\r`` (handled automatically here)."""
        string_to_send = string_to_send.replace("\n", "\\n")
        string_to_send = string_to_send.replace("\r", "\\r")
        command = f"U{string_to_send}\n"
        self.write_string_wait_for_response(command, "", 0)
        return

    def uart0_get_buffered_string(self, escape_characters=True):
        """Return and clear data accumulated from ``U:...`` USB lines (UART0 from target). Optionally un-escape CR/LF."""
        buffer_string = self.uart0_buffer
        self.uart0_buffer = ""
        if (escape_characters):
            buffer_string = buffer_string.replace("\\n", "\n")
            buffer_string = buffer_string.replace("\\r", "\r")
        return buffer_string
