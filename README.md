# APB-Based Serial Peripheral Interface (SPI) Core

## Project Overview

This repository presents the design and implementation of an "APB-Based Serial Peripheral Interface (SPI) Core", a "versatile and efficient module" engineered for seamless, high-speed communication between a master device (such as a microcontroller) and various peripheral devices. Recognised for its simplicity and robust data transfer capabilities, this SPI Core is an "ideal solution for diverse applications", including embedded systems, sensor interfacing, and sophisticated communication modules.

The core facilitates **duplex mode communication**, enabling simultaneous two-way data transfer, and ensures **synchronous data transfer** in perfect alignment with a clock signal. It is fully compliant with the **AMBA APB3 protocol**, guaranteeing straightforward integration into existing APB-based systems. The entire system is orchestrated by the "spi_top_module.v", which integrates all the core functionalities from its sub-blocks to provide a complete and operational SPI solution.

## Key Features

*   **AMBA APB3 Compliance**: Designed to integrate effortlessly into Advanced Peripheral Bus (APB) architectures.
*   **Duplex Communication**: Supports simultaneous two-way data transfer, enhancing communication efficiency.
*   **Synchronous Data Transfer**: Ensures reliable data transmission by synchronising all operations with the clock signal.
*   **Configurable Clock Characteristics**: Provides control over clock polarity (CPOL) and clock phase (CPHA) to accommodate **all four SPI modes (Mode 0, Mode 1, Mode 2, Mode 3)**.
*   **High Clock Frequencies**: Capable of operating at high clock speeds for rapid data transfer.
*   **Interrupt Capabilities**: Includes built-in mechanisms for efficient event handling and achieving low-latency data transfers.
*   **Low Power Consumption**: Optimised for power efficiency, making it suitable for battery-operated devices.
*   **Flexible Data Handling**: Supports both **Least Significant Bit First Enable (LSBFE)** and Most Significant Bit First transfer.

## Architectural Components

The SPI Core is modular, comprising several essential blocks, managed by the **`spi_top_module.v`**, which work in concert to provide its full functionality.

*   **`spi_apb_slave_select.v` (APB Slave Interface)**:
    *   This module is designed to **interface with an APB Master** and control the SPI device.
    *   It manages **read and write operations** to the SPI's internal registers (control, status, data) via the APB bus.
    *   Implements a state machine (IDLE, SETUP, ENABLE) to ensure proper APB protocol adherence.
    *   Generates write and read enable signals and updates SPI control registers with appropriate masks.
    *   Manages the SPI mode state machine (normal, wait, stop modes) and generates interrupt requests based on status flags.

      
*   **`spi_baud_generator.v` (Baud Rate Generator)**:
    *   Responsible for generating the **serial clock (SCLK)** for the SPI device from the APB clock (PCLK).
    *   It calculates the baud rate divisor using configurable SPI Baud Rate Preselection Bits (`sppr`) and SPI Baud Rate Selection Bits (`spr`).
    *   The Baud Rate Divisor is calculated as `(SPPR+1) × 2^(SPR+1)`.
    *   Operates in different SPI modes (run, wait, stop) and adjusts clock generation accordingly.
    *   Provides flags for sampling MISO and transmitting MOSI based on CPOL and CPHA.

      
*   **`spi_slave_select.v` (SPI Slave Select Generator)**:
    *   Manages the **Slave Select (SS) signal** for the SPI device when operating in master mode.
    *   It ensures the SPI device is appropriately selected (SS low) and deselected (SS high) based on data transmission requirements and SPI mode settings.
    *   Utilises a counter to keep SS low for a duration determined by the baud rate divisor.
    *   Generates the `receive_data` signal to ensure proper data reception, asserted after SS has been low for the required period.
    *   Provides a `tip` signal to indicate the transaction-in-progress status.

      
*   **`spi_shifter.v` (SPI Shifter)**:
    *   Handles the core logic for **serial-to-parallel and parallel-to-serial data conversion**.
    *   Manages the **Master Out Slave In (MOSI)** and **Master In Slave Out (MISO)** data lines during SPI transactions.
    *   Utilises configuration parameters such as clock polarity (CPOL), clock phase (CPHA), and least significant bit first enable (LSBFE) to correctly align data according to the SPI protocol settings.
    *   Data to be transmitted via MOSI is loaded into a shift register when the `send_data` signal is asserted and shifted out on the MOSI line.
    *   Captures data from the MISO line into a temporary register when the `receive_data` signal is asserted.

## Register Address Map Overview

The core provides access to key registers for configuration and status monitoring via the APB bus:

*   **Address 0: SPI Control Register 1 (RW)**: Configures core operations like SPI Enable (SPE), Master/Slave mode (MSTR), Clock Polarity (CPOL), Clock Phase (CPHA), and Slave Select Output Enable (SSOE).
*   **Address 1: SPI Control Register 2 (RW)**: Manages features such as Mode Fault Detection Enable (MODFEN), Bidirectional Output Enable (BIDIROE), and power conservation during wait mode (SPISWAI).
*   **Address 2: SPI Baud Rate Register (RW)**: Configures the serial clock frequency using preselection (SPPR) and selection (SPR) bits.
*   **Address 3: SPI Status Register (RO)**: Provides read-only status flags, including SPI Transfer Complete Flag (SPIF), Transmit Buffer Empty Flag (SPTEF), and Mode Fault Flag (MODF).
*   **Address 5: SPI Data Register (RW)**: Used for temporary storage of data bytes to be transmitted or received.

## Implementation Details

This project involves writing **synthesizable RTL code** (Verilog) for each component, ensuring it is ready for hardware implementation. The development process includes:

*   **RTL Coding**: Developing the Verilog code for each module (`spi_top_module.v`, `spi_baud_generator.v`, `spi_apb_slave_select.v`, `spi_slave_select.v`, `spi_shifter.v`).
*   **Linting**: Validating the RTL coding style and identifying potential issues using linting processes.
