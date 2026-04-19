#include <SimpleUsbSerial.h>

void setup() {
  pinMode(PA11, OUTPUT);

  SerialUSB.begin();
}



void loop() {
  uint8_t readData[64];
  int readAddr = 0x0003C000;
  int readTotalLen = 8*1024; // 读取 8KB 数据
  int readOffset = 0;
  int readLen = sizeof(readData);
  while (readOffset < readTotalLen) {
    if (readOffset + readLen > readTotalLen) {
      readLen = readTotalLen - readOffset; // 最后一次读取剩余的数据
    }
    int addr = readAddr + readOffset;
    // 读取 Flash-ROM 数据
    FLASH_ROM_READ(addr, readData, readLen);
    SerialUSB.print("Read Flash-ROM Data on 0x");
    SerialUSB.print(addr, HEX);
    SerialUSB.print(": ");
    for (int i = 0; i < readLen; i++) {
      uint8_t readDataByte = readData[i];
      if (readDataByte < 16) {
        SerialUSB.print("0"); // 补零
      }
      SerialUSB.print(readDataByte, HEX);
    }
    SerialUSB.println();
    readOffset += readLen;
  }
}
