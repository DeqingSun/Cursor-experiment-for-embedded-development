# Cursor Experiments for Embedded Development

Embedded development, at least for hardware engineers, usually follows a simple loop: **Think → Code → Test**.

In practice, this means making assumptions, writing code, testing on real hardware, observing the physical output, and repeating the cycle.

![code loop graph](imgs/code_loop.png)

I’ve been using GitHub Copilot to assist with the **Think** and **Code** parts of this loop. The **Test** stage, however, still depends heavily on physical-world work: measuring voltage, capturing waveforms, watching LEDs, soldering wires, and more. These steps require human involvement, which makes the loop difficult to fully automate and inherently slow.

This repository documents my experiments in reducing that manual effort and automating as much of the loop as possible.

I am **not** trying to automate physical tasks such as soldering or desoldering. Instead, I’m exploring ways to automate testing and interaction with hardware by using:

- logic analyzers to read signal levels and decode protocols,
- analog switch matrices to remap connections,
- possibly USB analyzers,
- and custom hardware that removes the need to physically press buttons or toggle switches for power cycling or bootloader entry.

The goal is to see how far this workflow can be pushed toward automation, even when real hardware remains part of the loop.

## Summary of experiment

| Experiment | Detail |
|------------|--------|
| [Exp1](exp1_LED_blink_on_Arduino_uno/README.md) | Using Cursor Agent to install Arduino Cli, compile blink code for Uno, upload code and check if LED is blinking with correct timing |
| [Exp2](exp2_PWM_register_Arduino_uno/README.md) | Generate code for PWM with register access. check PWM output for timing |
| [Exp3](exp3_LED_blink_on_CH552_on_CH559_jig/README.md) | Create CH552 blink code, test the code with custom made test jig |
| [Exp4](exp4_ch572_bootloader_reverse_engineer/README.md) | Reverse engineer CH572 bootloader feature, agent prove original idea unachievable. Agent also help to port proven code from another project |

## Conclusion

Agent is good at doing repetitve test iterations with clear instructions. As long as the hardware is setup in a fully accessible way by computer. The agent can do a good job to create test script and run the automated tests.
