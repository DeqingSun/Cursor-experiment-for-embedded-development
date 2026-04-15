// PWM on ATmega328P PB3 (Arduino Uno D11 / OC2A) using direct register access.
// Target: ~2 kHz, 80% duty cycle.
//
// Note: With Timer2 Fast PWM mode using TOP=0xFF, the closest to 2 kHz is:
//   f_pwm = 16 MHz / (prescaler * 256)
// Using prescaler=32 gives 1953.125 Hz (close to 2 kHz).
//
// OC2A duty in non-inverting mode: duty ≈ (OCR2A + 1) / 256

#include <avr/io.h>

static constexpr uint8_t DUTY_OCR2A = 204;  // ~80% of 255 (80% duty)

void setup() {
  // PB3 (D11) as output.
  DDRB |= (1 << DDB3);

  // Stop timer while configuring.
  TCCR2A = 0;
  TCCR2B = 0;
  TCNT2 = 0;

  // Fast PWM, TOP=0xFF: WGM22:0 = 0b011
  // - WGM21=1, WGM20=1 (in TCCR2A)
  // - WGM22=0 (in TCCR2B)
  TCCR2A |= (1 << WGM21) | (1 << WGM20);

  // Clear OC2A on compare match, set at BOTTOM (non-inverting PWM on OC2A).
  TCCR2A |= (1 << COM2A1);

  // Duty cycle.
  OCR2A = DUTY_OCR2A;

  // Prescaler = 32: CS22:0 = 0b011 (Timer2 only)
  TCCR2B |= (1 << CS21) | (1 << CS20);
}

void loop() {
  // Hardware PWM runs continuously.
}

