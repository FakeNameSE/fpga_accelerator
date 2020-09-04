# fpga_accelerator

## What Is This?
This was developed as a team project for the final project of the systems programming honors class CS 296-41
at the University of Illinois at Urbana-Champaign. The project goal was to offload certain computations to an FPGA to accelerate those operations. It was inspired by the rise of domain specific acceleration in computer architecture. We accomplished this by developing three components.
1. A datapath and control circuit for the FPGA capable of receiving data from a computer over UART, performing a computation with it, and transmitting the result back.
2. A Character device driver kernel module to communicate with the FPGA.
3. A user space C library which wrapped around the kernel module to facilitate using the FPGA within existing code by just calling a single function to perform an operation on the FPGA.

## A Few of the Challenges Encountered
Over the course of this project, my teammates and I learned quite a lot about just how tough hardware is. We spent plenty of time debugging our UART modules so that the FPGA could send and receive bytes while still having enough time to learn about systems programming with serial protocols and basic Linux kernel module (specifically character device drivers) development. Ultimately, we managed to get a fully working system capable of sending two bytes to the FPGA, XORing them, and sending them back.

## Technical Information!
FPGA Accelerator is built with:
  * Verilog for the accelerator and UART communication on the FPGA.
  * C for the kernel module and user space library.
  * A Makefile for the kernel module and another to make it easy to use the user space library.

## Pictures!
![Demo of using the accelerator](https://ggarrettgrossman.ddns.net/assets/images/fpga_accelerator_demo.png)

FPGA Accelerator XORing some bytes using the example program.

![FPGA LEDs lighting up from bytes received](https://ggarrettgrossman.ddns.net/assets/images/fpga_accelerator_lighting_up.png)

FPGA LEDs lighting up in response to byte received while debugging.

![Finite state machine of control circuit](https://ggarrettgrossman.ddns.net/assets/images/fpga_accelerator_fsm.png)

Diagram of finite state machine upon which the control circuit of the FPGA is based.

![Block diagram of datapath](https://ggarrettgrossman.ddns.net/assets/images/fpga_accelerator_block_diagram.png)

Block diagram of major components in the FPGA's datapath.
