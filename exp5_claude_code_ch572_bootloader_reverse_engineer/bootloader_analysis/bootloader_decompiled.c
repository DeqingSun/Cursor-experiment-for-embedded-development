/*
 * CH572 Stock Bootloader Reverse-Engineered Pseudocode
 *
 * Source:  reference/bootloader_dumpedHex.hex  (load address 0x3C000, 8 KB)
 * Tool:    riscv-wch-elf-objdump  (disassembly)
 * Headers: CH572SFR.h, ISP572.h  (register names)
 *
 * Architecture: RISC-V RV32IMC (compressed instructions)
 * The bootloader copies itself to RAM and runs there.
 *
 * RAM Layout used by bootloader
 * ──────────────────────────────
 *  0x2003C000 – 0x2003C0F7  initialised data copied from flash 0x3C0C0
 *  0x2003C0F8 – ....        interrupt vector table (in RAM, vectored mode)
 *  0x2003C080               main() entry point in RAM
 *  0x20001B38 – 0x20002013  run-time state variables (see struct BL_STATE)
 *  0x20001DF0               flash I/O buffer A (512 B)
 *  0x20001E08               flash I/O buffer B
 *  0x20001E8C               USB descriptor block
 *  0x20001F10               boot-info / configuration block
 *  0x2003DB64               second initialised data segment
 *  0x2003DBB4 – 0x2003E013  BSS (zeroed at startup)
 *  0x2003E398               global pointer (gp)
 *  0x2003E800               initial stack pointer (sp)
 */

#include <stdint.h>

/* ─── Register aliases from CH572SFR.h ──────────────────────────────────── */

/* Clock / power */
#define R8_CLK_SYS_CFG    (*(volatile uint8_t  *)0x40001008)
#define R8_HFCK_PWR_CTRL  (*(volatile uint8_t  *)0x4000100A)
#define  RB_CLK_PLL_PON   0x10

/* Safe-access */
#define R8_SAFE_ACCESS_SIG (*(volatile uint8_t *)0x40001040)
#define SAFE_ACCESS_SIG1   0x57
#define SAFE_ACCESS_SIG2   0xA8   /* (int8)-88  */
#define SAFE_ACCESS_SIG0   0x00
#define R8_GLOB_ROM_CFG   R8_RESET_STATUS  /* overlapping register */
#define  RB_ROM_CODE_WE   0xC0

/* System info */
#define R8_CHIP_ID        (*(volatile uint8_t  *)0x40001041)
#define R8_GLOB_CFG_INFO  (*(volatile uint8_t  *)0x40001045)
#define  RB_BOOT_LOADER   0x20
#define R8_RST_WDOG_CTRL  (*(volatile uint8_t  *)0x40001046)
#define  RB_SOFTWARE_RESET 0x01

/* GPIO PA */
#define R32_PA_PIN        (*(volatile uint32_t *)0x400010A4)
#define R32_PA_DIR        (*(volatile uint32_t *)0x400010A0)
#define R32_PA_OUT        (*(volatile uint32_t *)0x400010A8)
#define R16_PIN_ALTERNATE_H (*(volatile uint16_t*)0x4000101A)
#define  RB_PIN_USB_EN    0x2000
#define  RB_UDP_PU_EN     0x1000

/* Flash controller (0x40001800 area) */
#define R32_FLASH_DATA    (*(volatile uint32_t *)0x40001800)
#define R8_FLASH_DATA_BUF (*(volatile uint8_t  *)0x40001804)
#define R8_FLASH_SCK      (*(volatile uint8_t  *)0x40001805)
#define R8_FLASH_CTRL     (*(volatile uint8_t  *)0x40001806)
#define R8_FLASH_CFG      (*(volatile uint8_t  *)0x40001807)

/* Timer */
#define R8_TMR_CTRL_MOD   (*(volatile uint8_t  *)0x40002400)
#define R32_TMR_CNT_END   (*(volatile uint32_t *)0x4000240C)
#define R8_TMR_INT_FLAG   (*(volatile uint8_t  *)0x40002406)
#define  RB_TMR_IF_CYC_END 0x01

/* UART */
#define R8_UART_MCR       (*(volatile uint8_t  *)0x40003400)
#define R8_UART_IER       (*(volatile uint8_t  *)0x40003401)
#define  RB_IER_TXD_EN    0x40
#define R8_UART_FCR       (*(volatile uint8_t  *)0x40003402)
#define R8_UART_LCR       (*(volatile uint8_t  *)0x40003403)
#define R8_UART_LSR       (*(volatile uint8_t  *)0x40003405)
#define  RB_LSR_TX_ALL_EMP 0x40
#define  RB_LSR_DATA_RDY  0x01
#define R8_UART_RBR       (*(volatile uint8_t  *)0x40003408)
#define R8_UART_THR       (*(volatile uint8_t  *)0x40003408)
#define R16_UART_DL       (*(volatile uint16_t *)0x4000340C)
#define R8_UART_DIV       (*(volatile uint8_t  *)0x4000340E)

/* USB (0x40008000) */
#define R8_USB_CTRL       (*(volatile uint8_t  *)0x40008000)
#define  RB_UC_DMA_EN     0x01
#define  RB_UC_CLR_ALL    0x02
#define  RB_UC_RESET_SIE  0x04
#define  RB_UC_DEV_PU_EN  0x20
#define R8_UDEV_CTRL      (*(volatile uint8_t  *)0x40008001)
#define  RB_UD_PORT_EN    0x01
#define  RB_UD_PD_DIS     0x80
#define R8_USB_INT_EN     (*(volatile uint8_t  *)0x40008002)
#define  RB_UIE_TRANSFER  0x02
#define  RB_UIE_BUS_RST   0x01
#define  RB_UIE_SUSPEND   0x04
#define R8_USB_DEV_AD     (*(volatile uint8_t  *)0x40008003)
#define R8_USB_INT_FG     (*(volatile uint8_t  *)0x40008006)
#define  RB_UIF_TRANSFER  0x02
#define  RB_UIF_BUS_RST   0x01
#define  RB_UIF_SUSPEND   0x04
#define R8_USB_INT_ST     (*(volatile uint8_t  *)0x40008007)
#define  MASK_UIS_TOKEN   0x30
#define  UIS_TOKEN_SETUP  0x30
#define  UIS_TOKEN_IN     0x20
#define  UIS_TOKEN_OUT    0x00
#define  MASK_UIS_ENDP    0x0F
#define  RB_UIS_SETUP_ACT 0x80
#define R8_USB_RX_LEN     (*(volatile uint8_t  *)0x40008008)
#define R8_UEP4_1_MOD     (*(volatile uint8_t  *)0x4000800C)
#define R8_UEP2_3_MOD     (*(volatile uint8_t  *)0x4000800D)
#define R8_UEP0_T_LEN     (*(volatile uint8_t  *)0x40008020)
#define R8_UEP0_CTRL      (*(volatile uint8_t  *)0x40008022)
#define  UEP_T_RES_ACK    0x00
#define  UEP_T_RES_NAK    0x02
#define  UEP_T_RES_STALL  0x03
#define  UEP_R_RES_ACK    0x00
#define  UEP_R_RES_NAK    0x08
#define  RB_UEP_T_TOG     0x40
#define  RB_UEP_AUTO_TOG  0x10
#define R8_UEP2_CTRL      (*(volatile uint8_t  *)0x4000802A)
#define R16_UEP0_DMA      (*(volatile uint16_t *)0x40008010)
#define R16_UEP2_DMA      (*(volatile uint16_t *)0x40008018)
#define R16_UEP3_DMA      (*(volatile uint16_t *)0x4000801C)

/* PFIC (platform interrupt controller, WCH-specific at 0xE000E000) */
#define PFIC_IENR1        (*(volatile uint32_t *)0xE000E100)  /* enable */
#define PFIC_IENR2        (*(volatile uint32_t *)0xE000E104)
#define PFIC_IRER1        (*(volatile uint32_t *)0xE000E180)  /* disable */
#define PFIC_IRER2        (*(volatile uint32_t *)0xE000E184)


/* ─── WCH ISP command codes ──────────────────────────────────────────────── */
#define ISP_CMD_IDENTIFY       0xA1  /* identify/get chip info */
#define ISP_CMD_SET_BAUD       0xA2  /* change baud rate (UART only) */
#define ISP_CMD_ERASE_BLOCK    0xA3  /* erase 4 KB flash block(s) */
#define ISP_CMD_WRITE_DATA     0xA4  /* write data to flash */
#define ISP_CMD_VERIFY_DATA    0xA5  /* verify flash (XOR checksum) */
#define ISP_CMD_GET_STATUS     0xA6  /* get last command status (implicit) */
#define ISP_CMD_END_DOWNLOAD   0xA7  /* download complete, optional reset */
#define ISP_CMD_SET_ADDRESS    0xA8  /* set flash start address */
#define ISP_CMD_SET_CONFIG     0xC5  /* set erase/write configuration */


/* ─── Run-time state structure (inferred from disassembly) ───────────────── */
/* Base = 0x20001B98 – 0x20002013  (actual offsets confirmed from accesses) */
typedef struct {
    uint8_t  _pad0[0x08];          /* 0x20001B98 – 0x20001B9F (reserved) */
    uint8_t  flash_buf_a[0x40];    /* 0x20001BA0  main ISP receive/send buffer */
    uint32_t flash_target_addr;    /* 0x20001BA4  current flash write pointer  */
    uint32_t bytes_received;       /* 0x20001BA8  running byte counter          */
    uint32_t isp_session;          /* 0x20001BAC  session info word             */
    uint32_t isp_buf_ptr;          /* 0x20001BB0  pointer into flash_buf_a      */
    uint32_t max_pkt_size_w;       /* 0x20001BB4  max transfer size (words)     */
    uint8_t  mac_or_key[8];        /* 0x20001BB8 – 0x20001BBF encryption key    */
    uint8_t  _pad1[4];             /* 0x20001BC0 – 0x20001BC3                   */
    uint8_t  flag_bc4;             /* 0x20001BC4                                */
    uint8_t  verify_mode;          /* 0x20001BC5  1 = verify after write        */
    uint8_t  boot_cont;            /* 0x20001BC6  1 = jump back to user code    */
    uint8_t  pkt_count;            /* 0x20001BC7  packets per transfer           */
    uint16_t usb_wLength;          /* 0x20001BC8  USB SETUP.wLength             */
    uint8_t  usb_bRequest;         /* 0x20001BCA  USB SETUP.bRequest            */
    uint8_t  usb_wValue_lo;        /* 0x20001BCC                               */
    uint8_t  usb_wValue_hi;        /* 0x20001BCD                               */
    uint8_t  flag_bce;             /* 0x20001BCE                                */
    uint8_t  nak_ctr;              /* 0x20001BCF  USB NAK retry counter         */
    uint8_t  flash_busy;           /* 0x20001BD0  1 = flash operation in progress*/
    uint8_t  flag_bd1;             /* 0x20001BD1                                */
    /* ... */
    uint8_t  isp_connected;        /* 0x20001BE1  1 = host connected / ISP active*/
    uint8_t  session_active;       /* 0x20001BE2                                */
    uint8_t  flag_be3;             /* 0x20001BE3                                */
    uint32_t flash_iobuf[16];      /* 0x20001BE4  12-byte descriptor send buf   */
    uint32_t flash_sector_buf[64]; /* 0x20001BF0  256-byte sector buffer        */
    /* large scratch area through 0x20002013 */
} BL_STATE;


/* ─── Flash ROM command codes (internal, from ISP572.h) ─────────────────── */
#define CMD_FLASH_ROM_START_IO  0x00
#define CMD_FLASH_ROM_SW_RESET  0x04
#define CMD_GET_ROM_INFO        0x06
#define CMD_GET_UNIQUE_ID       0x07
#define CMD_FLASH_ROM_PWR_DOWN  0x0D
#define CMD_FLASH_ROM_PWR_UP    0x0C
#define CMD_FLASH_ROM_ERASE     0x01
#define CMD_FLASH_ROM_WRITE     0x02
#define CMD_FLASH_ROM_VERIFY    0x03

/* ROM info / config addresses */
#define ROM_CFG_MAC_ADDR   0x3F018   /* 6-byte MAC address in info flash */
#define ROM_CFG_BOOT_INFO  0x3DFF8   /* boot configuration word */


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 1 – STARTUP  (flash 0x3C000 – 0x3C0BE, runs once from flash)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * _start  (0x3C000)
 *
 * Very first instruction in bootloader flash.
 * Jumps straight to _startup to keep address 0x3C000 a single branch target.
 */
void __attribute__((naked)) _start(void)
{
    /* 0x3C000: jal x0, 0x3C004 */
    goto _startup;
}

/*
 * _startup  (0x3C004)
 *
 * 1. Load global pointer (gp) and stack pointer (sp) from ROM constants.
 * 2. Copy two initialised-data segments from flash to RAM.
 * 3. Zero BSS segment.
 * 4. Configure RISC-V CSRs for vectored interrupt mode.
 * 5. Set MEPC = main and MRET to enter user mode in RAM.
 */
void __attribute__((naked)) _startup(void)
{
    /* --- set up ABI registers ------------------------------------------ */
    /* gp = 0x2003E398  (global pointer) */
    /* sp = 0x2003E800  (stack pointer, top of RAM) */

    /* --- copy initialised data segment 1 -------------------------------- */
    /*  src = 0x3C0C0 (flash), dst = 0x2003C000..0x2003C0F7 (RAM) */
    uint32_t *src = (uint32_t *)0x3C0C0;
    uint32_t *dst = (uint32_t *)0x2003C000;
    uint32_t *end = (uint32_t *)0x2003C0F8;
    while (dst < end) *dst++ = *src++;

    /* --- copy initialised data segment 2 -------------------------------- */
    /*  src = 0x3DC24 (flash), dst = 0x2003DB64..0x2003DB9F (RAM) */
    src = (uint32_t *)0x3DC24;
    dst = (uint32_t *)0x2003DB64;
    end = (uint32_t *)0x2003DBA0;
    while (dst < end) *dst++ = *src++;

    /* --- zero BSS ------------------------------------------------------- */
    /*  0x2003DBA0 – 0x2003E013 */
    dst = (uint32_t *)0x2003DBA0;
    end = (uint32_t *)0x2003E014;
    while (dst < end) *dst++ = 0;

    /* --- RISC-V CSR setup ----------------------------------------------- */
    /* intsyscr (0xBC0) = 31  — enable hardware stack push/pop in ISR */
    /* gintenr  (0x804) = 3   — enable global fast-interrupt mode */
    /* mstatus  |= 0x88       — MIE + previous MIE (MPIE) */

    /* MTVEC = 0x2003C0F8 | 3  (vectored mode, vector table in RAM) */
    /* MEPC   = 0x2003C080     (main() in RAM) */
    /* mret                    — jump to main() */
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 2 – HARDWARE INIT  (code runs from RAM 0x2003C080 area)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * hw_init  (RAM equivalent of flash 0x3C140)
 *
 * Enables the PLL, sets system clock to 24 MHz, and configures the
 * flash controller timing.
 */
static void hw_init(void)
{
    /* Check if PLL is already powered on */
    if (!(R8_HFCK_PWR_CTRL & RB_CLK_PLL_PON))
    {
        /* Enter safe-access mode to write protected registers */
        R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;   /* 0x57 */
        R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;   /* 0xA8 */

        /* Power on PLL */
        R8_HFCK_PWR_CTRL |= RB_CLK_PLL_PON;

        /* Exit safe-access */
        R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG0;

        /* Wait ~480 cycles for PLL to lock */
        for (volatile int i = 480; i > 0; i--) {}
    }

    /* Enter safe-access again to change clock source */
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;

    /*
     * Set system clock:
     *   R8_CLK_SYS_CFG = 0x59
     *     bits[7:6] = 0b01 → clock from PLL (600 MHz)
     *     bits[4:0] = 25  → divide by 25 → Fsys = 24 MHz
     *
     * Also write 0x00 to the adjacent byte (R8_HFCK_PWR_CTRL) which
     * leaves PLL bit unchanged (SAM write).
     */
    *(volatile uint16_t *)0x40001008 = 0x0059;  /* R8_CLK_SYS_CFG = 0x59 */

    /* Flash controller clock / timing (values for 24 MHz operation) */
    R8_FLASH_SCK = 0x10;   /* flash SCK timing: moderate speed */
    R8_FLASH_CFG = 0x07;   /* flash config byte */

    /* Exit safe-access */
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG0;
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 3 – USB INIT  (flash 0x3D102)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * usb_init  (flash 0x3D102)
 *
 * Initialises the USB device as a full-speed device.
 * Endpoints:
 *   EP0 – control,  DMA buffer at 0x20001E8C (64 B)
 *   EP2 – bulk OUT, DMA buffer at 0x20001E08
 *   EP3 – bulk IN
 */
static void usb_init(void)
{
    /* Disable pull-down on D+ / D- */
    R32_PA_DIR &= ~3u;           /* PA0,PA1 as input */

    /* Clear USB pin alternate bits (turn off USB analog before reset) */
    *(volatile uint16_t *)0x4000101A &= ~(uint16_t)0x3000;  /* R16_PIN_ALTERNATE_H */

    /* Reset USB SIE and clear FIFOs */
    R8_USB_CTRL  = 0x00;
    R8_USB_DEV_AD= 0x00;

    /* Disable pull-down on D+/D- at GPIO level */
    *(volatile uint32_t *)0x400010B4 &= ~3u; /* PA_PD_DRV: clear PD on PA0/PA1 */

    /* Set endpoint buffer mode */
    R8_UEP4_1_MOD = 0x0C;  /* EP1: 64B TX+RX */
    /* EP2/EP3 bulk pair */

    /* Set DMA addresses (low 16 bits of RAM address) */
    R16_UEP0_DMA = (uint16_t)(uint32_t)0x20001E8C;  /* EP0 64-byte control buffer */
    R16_UEP2_DMA = (uint16_t)(uint32_t)0x20001E08;  /* EP2 OUT buffer */
    R16_UEP3_DMA = (uint16_t)(uint32_t)0x20001DF0;  /* EP3 IN buffer */

    /* Enable USB device + DMA, set full-speed (12 Mbps) */
    R8_USB_CTRL = 0x29;   /* RB_UC_DMA_EN | RB_UC_DEV_PU_EN | RB_UC_INT_BUSY */

    /* Enable USB pin alternate function */
    *(volatile uint16_t *)0x4000101A |= 0x0012;  /* USB pins + auto-toggle */

    /* USB device pull-up and port enable */
    R8_UDEV_CTRL = RB_UD_PD_DIS | RB_UD_PORT_EN;

    /* Enable interrupts: bus-reset, transfer, suspend */
    R8_USB_INT_EN = RB_UIE_TRANSFER | RB_UIE_BUS_RST | RB_UIE_SUSPEND;

    /* Clear state flags */
    /* BL_STATE.isp_connected  = 0 */
    /* BL_STATE.session_active = 0 */
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 4 – UART INIT  (flash 0x3D190)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * uart_init  (flash 0x3D190)
 *
 * Configures UART for ISP communication.
 *   Baud rate = Fsys / (R8_UART_DIV * R16_UART_DL * 16)
 *   At 24 MHz with DIV=1, DL=26 → 57600 baud
 */
static void uart_init(void)
{
    /* BL_STATE.baud_change_flag = 0 */

    R8_UART_DIV = 1;              /* pre-scaler = 1 */
    R16_UART_DL = 26;             /* baud rate divisor → 57600 baud @ 24 MHz */
    R8_UART_IER = RB_IER_TXD_EN; /* enable TXD pin */
    R8_UART_LCR = 0x03;          /* 8 data bits, no parity, 1 stop */
    R8_UART_FCR = 0x01;          /* enable FIFO */
    R8_UART_MCR |= 0x08;         /* OUT2 = 1 (enables UART interrupt output) */

    /* Enable USB analog pins (sets RB_PIN_USB_EN in PIN_ALTERNATE) */
    *(volatile uint16_t *)0x4000101A = (*(volatile uint16_t *)0x4000101A
                                        & ~0x003F) | 0x0012;
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 5 – HELPER: is_usb_connected  (flash 0x3C1C0)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * is_usb_connected  (flash 0x3C1C0)
 *
 * Returns 1 if a USB host is detected (D+ or D- driven),
 *         0 otherwise.
 *
 * Reads R32_PA_PIN (0x400010A4).  USB lines are PA0 (D−) and PA1 (D+).
 * A full-speed host drives D+ high (logical 1) and D− low.
 */
static int is_usb_connected(void)
{
    uint32_t pa_pin = R32_PA_PIN;
    uint8_t d_state = (uint8_t)(pa_pin & 3u);  /* PA0=D−, PA1=D+ */
    /* Return 1 if state is J (D+=1, D−=0) or K (D+=0, D−=1), i.e. not SE0 */
    return (d_state - 2u) <= 1u;   /* true for values 1 and 2 */
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 6 – HELPER: uart_write_byte  (flash 0x3C1D2)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * uart_write_byte  (flash 0x3C1D2)
 *
 * Writes a single byte to UART, blocking until the TX FIFO is empty.
 */
static void uart_write_byte(uint8_t byte)
{
    R8_UART_THR = byte;
    while (!(R8_UART_LSR & RB_LSR_TX_ALL_EMP)) {}  /* wait TX empty */
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 7 – HELPER: uart_read_byte  (flash 0x3C1EA)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * uart_read_byte  (flash 0x3C1EA)
 *
 * Returns the next received byte from UART.
 * Blocks until RX data is ready (RB_LSR_DATA_RDY).
 */
static uint8_t uart_read_byte(void)
{
    while (!(R8_UART_LSR & RB_LSR_DATA_RDY)) {}
    return R8_UART_RBR;
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 8 – HELPER: memcpy_helper  (flash 0x3C1FC)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * memcpy_helper  (flash 0x3C1FC)
 *
 * Copies 'len' bytes from src to dst.
 *   a0 = dst, a1 = src, a2 = len
 */
static void memcpy_helper(uint8_t *dst, const uint8_t *src, uint32_t len)
{
    for (uint32_t i = 0; i < len; i++)
        dst[i] = src[i];
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 9 – FLASH_EEPROM_CMD  (flash 0x3D7F8)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * FLASH_EEPROM_CMD  (flash 0x3D7F8)
 *
 * Core flash-access function called by the ISP handler.
 * Matches the public API declared in ISP572.h.
 *
 * Supported internal commands (x19 = cmd after dispatch):
 *   0  = start I/O (reset flash state machine)
 *   1  = erase 4 KB block
 *   2  = write  (256-byte aligned)
 *   3  = verify (XOR check)
 *   4  = software reset (send 0xFF reset sequence)
 *   6  = read ROM (reads 4-byte words)
 *   7  = get unique ID (reads 8 bytes)
 *   8  = no-op / success return
 *   9  = read flash via SPI commands
 *  10  = program page (send data to flash)
 *  11  = send SPI byte (generic)
 *  12  = power-down flash
 *  13  = power-up flash
 *  21  = page-program with auto-sector-count
 *
 * Returns 0 on success, non-zero on failure.
 *
 * Implements protocol:
 *  1. Save & disable all PFIC interrupts (IRER1/IRER2 at 0xE000E180)
 *  2. Enter safe-access mode
 *  3. Enable flash ROM write (RB_ROM_CODE_WE in GLOB_ROM_CFG = 0xE0)
 *  4. Send command byte to flash controller via R8_FLASH_CTRL
 *  5. Exchange SPI-like bytes through R8_FLASH_DATA_BUF / R32_FLASH_DATA
 *  6. Restore PFIC interrupt enables (IENR1/IENR2 at 0xE000E100)
 *
 * SPI helper functions (used internally, flash ~0x3D6E2–0x3D740):
 *   flash_spi_send(byte)   – write byte, wait for completion
 *   flash_spi_recv()       – read byte after dummy write
 *   flash_spi_cs_low()     – assert chip-select (R8_FLASH_CTRL |= 4)
 *   flash_spi_cs_high()    – deassert chip-select
 */
extern uint32_t FLASH_EEPROM_CMD(uint8_t cmd, uint32_t StartAddr,
                                  void *Buffer, uint32_t Length);

/*
 * Safe-access wrapper used before every flash command:
 */
static inline void safe_access_open(void)
{
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
}
static inline void safe_access_close(void)
{
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG0;
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 10 – ISP PROTOCOL HANDLER  (flash 0x3C218)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * isp_process_packet  (flash 0x3C218)
 *
 * Processes a single WCH ISP command packet received over USB or UART.
 *
 * Packet format (received in BL_STATE.flash_buf_a):
 *   [0]   command byte (ISP_CMD_*)
 *   [1]   sub-command / flags
 *   [2]   checksum (sum of all bytes must be 0)
 *   [3]   packet info / wIndex
 *   [4–6] 3-byte length or address
 *   [7–N] data payload
 *
 * Response packet (sent back in BL_STATE.flash_buf_a):
 *   [0]   echoed command byte
 *   [1]   status (0=success, 0xFE=busy, ...)
 *   [2]   data length (number of bytes following)
 *   [3]   checksum of response
 *   [4]   ISP_CMD.bReturn (device-specific)
 *   [5]   R8_CHIP_ID
 *   [6]   0x13  (fixed tag)
 *   [7–N] optional response data
 *
 * Key registers used:
 *   x8  (s0)  = BL_STATE.flash_buf_a   (0x20001F10 at startup via s0 = BL_STATE_BASE - 0xF0)
 *   x18 (s2)  = &BL_STATE.pkt_count    (0x20001BC7)
 *   x19 (s3)  = &BL_STATE.flash_buf_a  (0x20001BDC → current ptr)
 *   x20 (s4)  = &BL_STATE.bytes_received(0x20001BAC)
 */
static void isp_process_packet(void)
{
    /* Locate pointers into BL_STATE (pre-loaded in caller) */
    volatile uint8_t  *buf   = (uint8_t *)0x20001F10;  /* received packet */
    volatile uint8_t  *pkt_count = (uint8_t *)0x20001BC7;
    volatile uint32_t *bytes_rx  = (uint32_t*)0x20001BAC;
    volatile uint8_t  *isp_state_ptr = *(uint8_t **)0x20001BDC; /* current ISP state buffer */

    uint8_t cmd = buf[0];

    /* Check if we already have a pending flash operation in progress */
    if (*bytes_rx == 0 || buf[0] == 0xA5)
    {
        /* skip duplicate / idle handling, return 0xFE (busy) */
        goto set_response_busy;
    }

    /* Decode the 4-byte payload length (little-endian, bytes [4:7]) */
    uint32_t payload_len = buf[4]
                         | ((uint32_t)buf[5] << 8)
                         | ((uint32_t)buf[6] << 16)
                         | ((uint32_t)buf[7] << 24);
    /* clamp minimum to 8 */
    if (payload_len < 8) payload_len = 8;

    /* ── Command dispatch ─────────────────────────────────────────────── */
    switch (cmd)
    {
    /* ── 0xA1: IDENTIFY ───────────────────────────────────────────────── */
    case ISP_CMD_IDENTIFY:   /* 0x3C45C */
        /*
         * Response payload contains:
         *   [0x0C+0] = timer count low byte (timer used for baud calibration)
         *   [0x0C+1] = R8_CHIP_ID  (0x72 for CH572)
         *   [0x0C+2] = 0x13        (fixed bootloader tag)
         *
         * Also initialises TMR1 for timebase:
         *   TMR_CNT_END = 0x57E400  (6,000,640 cycles ≈ 250 ms @ 24 MHz)
         *   TMR_CTRL_MOD = 4 (timer enable, free-running)
         */
        R32_TMR_CNT_END = 0x57E400;
        R8_TMR_CTRL_MOD = 4;
        /* call FLASH_EEPROM_CMD(CMD_GET_ROM_INFO, 0x3DFF8, buf_12, 12) */
        FLASH_EEPROM_CMD(CMD_GET_ROM_INFO, ROM_CFG_BOOT_INFO,
                         (void *)0x20001DF0, 12);
        /* copy boot-info response into ISP response buffer */
        /* BL_STATE.flash_target_addr reset to 0 */
        break;

    /* ── 0xA2: SET_BAUD (UART) / SET_CONFIG ──────────────────────────── */
    case ISP_CMD_SET_BAUD:   /* 0x3CB30 */
        /*
         * For UART ISP: updates R16_UART_DL and R8_UART_DIV from the
         * baud rate embedded in the command payload.
         * Baud = 0x1C9C380 / (baud_word * 10 + 5) / 10
         *      where baud_word = 24-bit value at buf[4:7]
         *
         * For USB ISP: sets BL_STATE.boot_cont flag if buf[3] == 1.
         */
        if (buf[3] == 1)
        {
            /* set boot_cont flag → after session ends, jump back to user */
            *(uint8_t *)0x20001BC6 = buf[3]; /* BL_STATE.boot_cont = 1 */
        }
        /* always re-enable USB pull-up (R8_GLOB_CFG_INFO bit 5 = RB_BOOT_LOADER) */
        safe_access_open();
        R8_GLOB_CFG_INFO |= RB_BOOT_LOADER;  /* 0x20 */
        safe_access_close();
        /* jump to 0x3C694 (build response and return) */
        break;

    /* ── 0xA3: ERASE  ────────────────────────────────────────────────── */
    case ISP_CMD_ERASE_BLOCK:  /* 0x3C6BA */
        /*
         * Expects buf[1] = number of 4 KB blocks to erase, min 29.
         * XORs buf[3] with a key byte derived from the block count to
         * form an 8-byte encryption/verification key stored in
         * BL_STATE.mac_or_key[0..7].
         * Calls FLASH_EEPROM_CMD(CMD_FLASH_ROM_ERASE, ...) internally.
         * Updates checksum byte buf[7] as a running XOR checksum.
         */
        {
            uint8_t blk_count = buf[1];
            if (blk_count < 29) goto set_response_ok;  /* too small, ignore */
            /* derive per-block key from stored secret + device unique ID */
            /* store in BL_STATE.mac_or_key */
        }
        break;

    /* ── 0xA4: WRITE  ────────────────────────────────────────────────── */
    case ISP_CMD_WRITE_DATA:  /* 0x3C31E */
        /*
         * buf[1] must be 4 (packet type: write).
         * buf[3] = packet index.
         * buf[4..7] = 32-bit length.
         * Data follows at buf+8.
         *
         * Calls FLASH_EEPROM_CMD(CMD_FLASH_ROM_WRITE, target_addr, buf+8, len).
         * Increments BL_STATE.flash_target_addr by len.
         * Enforces: flash_target_addr + len < 0x3C000 (must not overwrite bootloader).
         */
        {
            uint32_t len = (buf[1] == 4) ? payload_len : buf[3];
            if (len < 8) len = 8;
            /* Check address bounds */
            if (*(uint32_t *)0x20001BA4 + *(uint32_t *)0x20001BA8 >= 0x3C000)
                goto set_response_error;  /* would overwrite bootloader */
            FLASH_EEPROM_CMD(CMD_FLASH_ROM_WRITE,
                             *(uint32_t *)0x20001BA4,
                             buf + 8, len);
            *(uint32_t *)0x20001BA4 += len;
            *(uint32_t *)0x20001BA8 += len;
        }
        break;

    /* ── 0xA5: VERIFY ────────────────────────────────────────────────── */
    case ISP_CMD_VERIFY_DATA:  /* 0x3C51E */
        /*
         * buf[1..2] = 16-bit address offset within verify window.
         * buf[3..6] = 32-bit total byte count to verify.
         * Reads 8 key bytes from BL_STATE.mac_or_key[0..7].
         * XOR-verifies sectors of flash against key XOR expected.
         *
         * Returns 0 on match, 0x01 on mismatch.
         */
        {
            uint16_t addr_offset = (uint16_t)((buf[2] << 8) | buf[1]) - 5;
            uint32_t total = (uint32_t)buf[3]
                           | ((uint32_t)buf[4] << 8)
                           | ((uint32_t)buf[5] << 16)
                           | ((uint32_t)buf[6] << 24);
            (void)addr_offset; (void)total;
            /* XOR each 8-byte block with key; accumulate into checksum */
        }
        break;

    /* ── 0xA7: END_DOWNLOAD  ─────────────────────────────────────────── */
    case ISP_CMD_END_DOWNLOAD:  /* 0x3C956 */
        /*
         * buf[3] & 7 must == 7 for a valid end-download packet.
         * Copies current flash pointer into the ISP response.
         * If buf[3] & 8 set → reads 4 extra bytes from BL_STATE and appends.
         * If buf[3] & 16 set → calls FLASH_EEPROM_CMD(CMD_FLASH_ROM_WRITE)
         *   to flush the partial last page.
         * Calls FLASH_EEPROM_CMD(CMD_FLASH_ROM_SW_RESET) on success.
         * Sets BL_STATE.verify_mode = 1 on success.
         */
        break;

    /* ── 0xA8: SET_ADDRESS  ──────────────────────────────────────────── */
    case ISP_CMD_SET_ADDRESS:  /* 0x3C77E */
        /*
         * buf[3] & 7 must == 7.
         * buf[5..8] = 32-bit target address (big-endian? little-endian?).
         * Stores to BL_STATE.flash_target_addr (0x20001BE4).
         * Sets up the USB IN endpoint transmit configuration (
         *   either STALL=0xF0 or NAK=0x02 depending on buf[14]).
         */
        {
            uint32_t target_addr = (uint32_t)buf[6]
                                 | ((uint32_t)buf[7] << 8)
                                 | ((uint32_t)buf[5] << 16)
                                 | ((uint32_t)buf[8] << 24);
            *(uint32_t *)0x20001BE4 = target_addr;
        }
        break;

    /* ── 0xC5: SET_CONFIG  ───────────────────────────────────────────── */
    case ISP_CMD_SET_CONFIG:   /* 0x3C42C */
        /*
         * Sets BL_STATE.baud_change_flag = 2.
         * Stores buf[4..7] as a new baud-rate base address.
         * Used to configure UART ISP operation mode.
         */
        *(uint8_t *)0x20001BE0 = 2;
        break;

    default:
        /* Unknown command: store raw byte into state buffer, return NAK */
set_response_busy:
        /* Response byte[1] = 0xFE (busy / unrecognised) */
        break;
    }

    /* ── Build response header ──────────────────────────────────────────── */
set_response_ok:
    isp_state_ptr[0] = cmd;
    isp_state_ptr[1] = *pkt_count - 4;   /* bytes_remaining */
    isp_state_ptr[2] = 0;                /* response status = OK */
    isp_state_ptr[3] = 0;                /* checksum placeholder */
    isp_state_ptr[4] = 0xFE;             /* return code (default busy) */
    isp_state_ptr[5] = R8_CHIP_ID;       /* 0x72 for CH572 */
    isp_state_ptr[6] = 0x13;             /* bootloader tag */
    return;

set_response_error:
    isp_state_ptr[0] = cmd;
    isp_state_ptr[1] = 0;
    isp_state_ptr[2] = 0;
    isp_state_ptr[3] = 0;
    isp_state_ptr[4] = 0x01;             /* error code */
    isp_state_ptr[5] = R8_CHIP_ID;
    isp_state_ptr[6] = 0x13;
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 11 – USB ISP INTERRUPT HANDLER  (flash 0x3CD5A)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * usb_isr  (flash 0x3CD5A)
 *
 * Called from the vectored interrupt table on USB interrupt (INT_ID_USB = 22).
 *
 * Handles:
 *   • BUS_RESET   – re-initialise endpoints
 *   • SUSPEND     – (ignored in bootloader)
 *   • TRANSFER    – dispatch on token type + endpoint
 *
 * Token handling:
 *   SETUP on EP0 → parse USB standard requests
 *     bRequest = GET_DESCRIPTOR (0x06) → send device/config descriptor
 *     bRequest = SET_ADDRESS    (0x05) → update R8_USB_DEV_AD
 *     bRequest = SET_CONFIGURATION (0x09) → configure endpoints & ISP start
 *     bRequest = vendor (0x40) with wValue >> 8 indicating ISP state
 *   OUT   on EP0 → receive ISP data, call isp_process_packet()
 *   IN    on EP0 → send next chunk of response
 *   OUT   on EP2 → bulk receive (for large data transfers)
 *   IN    on EP3 → bulk transmit
 *
 * USB descriptor data (in flash 0x3DC24 copied to RAM 0x20001E8C):
 *   Device descriptor:
 *     bcdUSB        = 0x0110 (USB 1.1)
 *     bDeviceClass  = 0xFF  (vendor-defined)
 *     idVendor      = 0x1A86  (WCH)
 *     idProduct     = 0x55E0  (CH572 DFU/ISP)
 *     bcdDevice     = 0x0300
 *   Configuration: 1 × interface, 2 × bulk endpoints
 */
void __attribute__((interrupt)) usb_isr(void)
{
    uint8_t int_fg = R8_USB_INT_FG;

    if (!(int_fg & RB_UIF_TRANSFER))
    {
        if (int_fg & RB_UIF_BUS_RST)
        {
            /* USB bus reset: re-initialise device */
            R8_USB_DEV_AD = 0;
            R8_USB_INT_FG = RB_UIF_BUS_RST;  /* clear flag */
            /* Reset endpoint controls */
            R8_UEP0_CTRL  = UEP_T_RES_NAK | UEP_R_RES_ACK;
            /* mark ISP session as disconnected */
            *(uint8_t *)0x20001BC4 = 0;
            *(uint8_t *)0x20001BCB = 0;
            R8_UEP0_T_LEN = 18;
            R8_USB_INT_FG = RB_UIF_BUS_RST;
        }
        /* Clear any other flags and return */
        R8_USB_INT_FG = int_fg;
        return;
    }

    /* Transfer complete */
    uint8_t int_st  = R8_USB_INT_ST;
    uint8_t token   = int_st & MASK_UIS_TOKEN;
    uint8_t endp    = int_st & MASK_UIS_ENDP;

    switch (token)
    {
    case UIS_TOKEN_SETUP:  /* SETUP transaction on EP0 */
    {
        uint8_t *setup = (uint8_t *)0x20001E8C;  /* EP0 DMA buffer */
        uint8_t  bReqType = setup[0];
        uint8_t  bRequest = setup[1];
        uint16_t wValue   = (uint16_t)setup[2] | ((uint16_t)setup[3] << 8);
        uint16_t wLength  = (uint16_t)setup[6] | ((uint16_t)setup[7] << 8);

        /* Save SETUP fields to BL_STATE */
        *(uint16_t *)0x20001BC8 = wLength;
        *(uint8_t  *)0x20001BCA = bRequest;

        if ((bReqType & 0x60) == 0x00)
        {
            /* Standard request */
            if (bRequest <= 10)
            {
                /* Jump table at 0x20001B38 (copied from flash 0x3DC60+) */
                typedef void (*handler_t)(void);
                handler_t *tbl = (handler_t *)0x20001B38;
                tbl[bRequest]();
            }
        }
        else
        {
            /* Vendor/class request – return STALL */
            R8_UEP0_CTRL = UEP_T_RES_STALL;
        }
        R8_USB_INT_FG = RB_UIF_TRANSFER;
        break;
    }

    case UIS_TOKEN_IN:   /* IN token: host reading from us */
    {
        if (endp == 0)
        {
            /* EP0 IN: send next chunk */
            /* load next segment pointer from BL_STATE.bd8 */
            /* update toggle bit */
        }
        R8_USB_INT_FG = RB_UIF_TRANSFER;
        break;
    }

    case UIS_TOKEN_OUT:  /* OUT token: host writing to us */
    {
        if (endp == 0)
        {
            uint8_t rx_len = R8_USB_RX_LEN;
            /* Copy EP0 DMA buffer to ISP packet buffer */
            memcpy_helper((uint8_t *)0x20001E08,
                          (const uint8_t *)0x20001E8C, rx_len);
            /* Update ISP state pointer */
            *(uint32_t *)0x20001BDC = (uint32_t)0x20001E8C + 64;
            /* Call ISP handler */
            isp_process_packet();
            /* Copy response back to EP0 DMA buffer and queue TX */
            *(uint8_t *)0x20001BC7 = /* pkt_count */ 6;
            R8_UEP0_CTRL = UEP_T_RES_ACK;
        }
        R8_USB_INT_FG = RB_UIF_TRANSFER;
        break;
    }

    default:
        R8_USB_INT_FG = RB_UIF_TRANSFER;
        break;
    }
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 12 – UART ISP HANDLER  (flash 0x3CB72)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * uart_isp_task  (flash 0x3CB72)
 *
 * Implements the WCH ISP protocol over UART (for ch55xRebootTool scenario).
 *
 * Packet format on wire:
 *   [0]   0x57  (sync1)
 *   [1]   0xAB  (sync2)
 *   … then command byte … length … data … checksum
 *
 * State machine:
 *   0: Wait for 0x57 sync byte
 *   1: Wait for 0xAB sync byte
 *   2: Receive command byte
 *   3: Receive length bytes
 *   4: Receive payload data (accumulate checksum)
 *   → on complete packet: call isp_process_packet()
 *   → send response: iterate bytes, transmit each via uart_write_byte()
 *
 * Baud-rate re-config logic at 0x3CC66:
 *   If BL_STATE.baud_change_flag set, pause 100 ms, then write new
 *   R16_UART_DL value (computed from BL_STATE.flash_target_addr and Fsys).
 */
static void uart_isp_task(void)
{
    /* sync detection and packet assembly from UART bytes */
    /* ... (see disassembly 0x3CB72 – 0x3CD58) ... */
}


/* ═══════════════════════════════════════════════════════════════════════════
 *  SECTION 13 – MAIN FUNCTION  (RAM 0x2003C080, copied from flash 0x3C080 area)
 *               Entry point via usb_detect_and_init  (flash 0x3D256)
 * ═══════════════════════════════════════════════════════════════════════════ */

/*
 * main  (flash 0x3D256)
 *
 * Top-level bootloader loop:
 *
 *  1. Clear all state variables (BL_STATE).
 *  2. Call FLASH_EEPROM_CMD(CMD_GET_ROM_INFO, ROM_CFG_BOOT_INFO, …)
 *     to read the boot configuration word from info flash (0x3DFF8).
 *  3. If boot info word is all-1s (erased), fall back to defaults.
 *  4. Read MAC address from ROM_CFG_MAC_ADDR (0x3F018) into BL_STATE.mac_or_key.
 *  5. Detect USB presence (call is_usb_connected() up to 100×).
 *  6. If USB connected → usb_init() then loop on USB interrupts + timer.
 *     If not connected  → uart_init() then loop on UART ISP.
 *  7. In the USB path:
 *     a. Enable USB interrupt at PFIC level.
 *     b. Start a 60-second timeout timer (TMR1).
 *     c. Poll BL_STATE.isp_connected.
 *     d. When connected: handle flash R/W commands until session ends.
 *     e. On timeout with no activity: check R8_RST_WDOG_CTRL for manual
 *        boot-loader pin, then decide to stay or jump to user code.
 *  8. To jump to user code (0x00000000):
 *     - If RB_BOOT_LOADER bit clear in R8_GLOB_CFG_INFO → user firmware is running
 *       (this check distinguishes SW-reset vs hardware boot-loader entry).
 *     - Load user vector table: MTVEC = [0x00000000 + 64] (user vectors at offset 0x40)
 *     - MEPC = user code entry (first 32-bit word at 0x00000000 is boot jump)
 *     - mret → enter user code
 *
 * NOTE on "jump without erasing first sector":
 *   The bootloader does NOT erase sector 0 before jumping back to user code.
 *   It simply resets the USB/UART peripherals, clears state, and does MRET
 *   to the user's reset vector.  The user's code takes over from 0x00000000
 *   (the jal in the user's vector table).
 */
int main(void)
{
    /* 1. Initialise hardware */
    hw_init();

    /* 2. Read boot information from info flash */
    uint8_t boot_info[12];
    FLASH_EEPROM_CMD(CMD_GET_ROM_INFO, ROM_CFG_BOOT_INFO, boot_info, 0);

    /* 3. Read MAC address */
    uint8_t mac[8];
    FLASH_EEPROM_CMD(CMD_GET_ROM_INFO, ROM_CFG_MAC_ADDR, mac, 0);

    /* Store MAC in BL_STATE.mac_or_key for encryption key derivation */

    /* 4. Detect USB vs UART */
    int usb_present = 0;
    for (int i = 0; i < 100; i++)
    {
        usb_present = is_usb_connected();
        if (usb_present) break;
    }

    if (usb_present)
    {
        /* USB path */
        usb_init();

        /* Enable timer for ISP timeout / baud calibration */
        R32_TMR_CNT_END = 0xEA600;   /* ~6 ms at 24 MHz */
        R8_TMR_CTRL_MOD = 4;

        /* Main USB event loop */
        while (1)
        {
            /* Poll USB interrupt flag (ISR handles transfer events) */
            if (R8_USB_INT_FG & 7)
                usb_isr();

            /* Poll UART for any incoming bytes (dual-mode) */
            if (R8_UART_LSR & RB_LSR_DATA_RDY)
                uart_isp_task();

            /* Poll timer for ISP timeout */
            if (R8_TMR_INT_FLAG & RB_TMR_IF_CYC_END)
            {
                /* handle baud-rate change request */
                /* handle session timeout → jump to user code */
            }
        }
    }
    else
    {
        /* UART path */
        uart_init();

        while (1)
            uart_isp_task();
    }

    /* Never reached normally.  Boot-to-user-code path: */
    /* set MEPC = 0x00000000, mret */
    return 0;
}
