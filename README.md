# GNU Debugger with CMSIS SVD support for NixOS

This is an overlay which adds `arm-none-eabi-gdb-svd` command which extends `arm-none-eabi-gdb-py` with support for SVD to help embedded developers view device periphery state.

The following packages and tools is used:

* [cmsis-svd](https://pypi.org/project/cmsis-svd/)
* [svd-dump](https://github.com/katyo/svd-dump) as alternative to _gdb-svd_
* [gdb-svd](https://github.com/1udo6arre/svd-tools) as alternative to _svd-dump_

## Installation

```
# Add overlay locally
git clone https://github.com/katyo/gcc-arm-embedded-svd ~/.config/nixpkgs/overlays

# Install package
nix-env -iA nixos.gcc-arm-embedded-svd
```

## Usage

Simply use `arm-none-eabi-gdb-svd` command instead of `arm-none-eabi-gdb` or `arm-none-eabi-gdb-py`.

```
# run debugger and attach to target
arm-none-eabi-gdb-svd program.elf ...
```

### Using _svd-dump_

```
# load system view for specific target
(gdb) svd_load STMicro STM32F103xx.svd

# or load it from an external SVD file
(gdb) svd_load_file /path/to/your_file.svd

# Show an entire peripheral
(gdb) svd_show USART2
USART2 @ 0x40004400
SR   CTS=0 LBD=0 TXE=1 TC=1 RXNE=0 IDLE=0 ORE=0 NE=0 FE=0 PE=0
DR   DR=0
BRR  DIV_Mantissa=19 DIV_Fraction=8
CR1  UE=1 M=0 WAKE=0 PCE=0 PS=0 PEIE=0 TXEIE=0 TCIE=0 RXNEIE=0 IDLEIE=0 TE=1 RE=1 RWU=0 SBK=0
CR2  LINEN=0 STOP=0 CLKEN=0 CPOL=0 CPHA=0 LBCL=0 LBDIE=0 LBDL=0 ADD=0
CR3  CTSIE=0 CTSE=0 RTSE=0 DMAT=0 DMAR=0 SCEN=0 NACK=0 HDSEL=0 IRLP=0 IREN=0 EIE=0
GTPR GT=0 PSC=0

# Show just one register
(gdb) svd_show USART2 BRR
BRR DIV_Mantissa=19 DIV_Fraction=8

# Show field values in hex
(gdb) svd_show/x USART2 BRR
BRR DIV_Mantissa=013 DIV_Fraction=8

# Show field values in binary
(gdb) svd_show/b USART2 BRR
BRR DIV_Mantissa=000000010011 DIV_Fraction=1000

# Show whole register value in binary
(gdb) svd_show/i USART2 BRR
BRR 00000000000000000000000100111000 DIV_Mantissa=19 DIV_Fraction=8

# Show register offsets
(gdb) svd_show/f USART2
USART2 @ 0x40004400
SR   0x0000 CTS=0 LBD=0 TXE=1 TC=1 RXNE=0 IDLE=0 ORE=0 NE=0 FE=0 PE=0
DR   0x0004 DR=0
BRR  0x0008 DIV_Mantissa=19 DIV_Fraction=8
CR1  0x000c UE=1 M=0 WAKE=0 PCE=0 PS=0 PEIE=0 TXEIE=0 TCIE=0 RXNEIE=0 IDLEIE=0 TE=1 RE=1 RWU=0 SBK=0
CR2  0x0010 LINEN=0 STOP=0 CLKEN=0 CPOL=0 CPHA=0 LBCL=0 LBDIE=0 LBDL=0 ADD=0
CR3  0x0014 CTSIE=0 CTSE=0 RTSE=0 DMAT=0 DMAR=0 SCEN=0 NACK=0 HDSEL=0 IRLP=0 IREN=0 EIE=0
GTPR 0x0018 GT=0 PSC=0
```

### Using _gdb-svd_

```
# Load svd file descriptor for specific target
(gdb) svd ../cmsis-svd/data/STMicro/STM32F7x9.svd
Svd Loading ../cmsis-svd/data/STMicro/STM32F7x9.svd Done

# Getting help
(gdb) help svd
The CMSIS SVD (System View Description) inspector commands
        This allows easy access to all peripheral registers supported by the system
        in the GDB debug environment

        svd [filename] load an SVD file and to create the command for inspecting
        that object
List of svd subcommands:
svd get -- Get register(s) value(s): svd get [peripheral] [register]
svd info -- Info on Peripheral|register|field: svd info <peripheral> [register] [field]
svd set -- Set register value: svd set <peripheral> <register> [field] <value>

# Get information on all ADC
(gdb) svd info ADC
+Peripherals--------|--------|-----------------------------+
| name | base       | access | description                 |
+------|------------|--------|-----------------------------+
| ADC1 | 0x40012000 | None   | Analog-to-digital converter |
| ADC2 | 0x40012100 | None   | Analog-to-digital converter |
| ADC3 | 0x40012200 | None   | Analog-to-digital converter |
+------|------------|--------|-----------------------------+

# Get information on all ADC1 registers beginning by S
(gdb) svd info ADC1 S
+Registers-----------|------------|-----------------------------+
| name  | address    | access     | description                 |
+-------|------------|------------|-----------------------------+
| SR    | 0x40012000 | read-write | status register             |
| SMPR1 | 0x4001200c | read-write | sample time register 1      |
| SMPR2 | 0x40012010 | read-write | sample time register 2      |
| SQR1  | 0x4001202c | read-write | regular sequence register 1 |
| SQR2  | 0x40012030 | read-write | regular sequence register 2 |
| SQR3  | 0x40012034 | read-write | regular sequence register 3 |
+-------|------------|------------|-----------------------------+

# Get information on all fields (peripheral: ADC1 register: CR1) beginning by J
(gdb) svd info ADC1 CR1 J
+Fields---|-----------|--------|---------------------------------------------+
| name    | [msb:lsb] | access | description                                 |
+---------|-----------|--------|---------------------------------------------+
| JAWDEN  | [22:22]   | None   | Analog watchdog enable on injected channels |
| JDISCEN | [12:12]   | None   | Discontinuous mode on injected channels     |
| JAUTO   | [10:10]   | None   | Automatic injected group conversion         |
| JEOCIE  | [7:7]     | None   | Interrupt enable for injected channels      |
+---------|-----------|--------|---------------------------------------------+

# Get registers and fields values (all registers of WWDG)
(gdb) svd get WWDG
+Registers----------|------------|----------------------------------------------------------+
| name | address    | value      | fields                                                   |
+------|------------|------------|----------------------------------------------------------+
| CR   | 0x40002c00 | 0x0000007f | WDGA[7:7]=0x0 T[6:0]=0x7f                                |
| CFR  | 0x40002c04 | 0x0000007f | EWI[9:9]=0x0 WDGTB1[8:8]=0x0 WDGTB0[7:7]=0x0 W[6:0]=0x7f |
| SR   | 0x40002c08 | 0x00000000 | EWIF[0:0]=0x0                                            |
+------|------------|------------|----------------------------------------------------------+

# Fields of RCC AHB3ENR
(gdb) svd get RCC AHB3ENR
+Registers+------------|------------|--------------------------------+
| name    | address    | value      | fields                         |
+---------|------------|------------|--------------------------------+
| AHB3ENR | 0x40023838 | 0x00000000 | FMCEN[0:0]=0x0 QSPIEN[1:1]=0x1 |
+---------|------------|------------|--------------------------------+

# Set register value
(gdb) svd set RCC AHB3ENR 0x0
(gdb) svd set RCC AHB3ENR QSPIEN 0x1
```
