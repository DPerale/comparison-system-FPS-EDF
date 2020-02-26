This system need some tool and software to work.
The first is the "gnat-community-2018-20180524-arm-elf-linux64-bin" downloadable in the adacore site. If you use Windows get the right packet.
The second is "stlink" downloadable here: https://github.com/texane/stlink . This tool is needed for Linux users.
Here https://docs.adacore.com/gnat_ugx-docs/html/gnat_ugx/gnat_ugx/arm-elf_topics_and_tutorial.html you can find a tutorial on how the connection with board works. Also you can find what to download for Windows users.
We use the STM32F429I-DISC1 board. If you use another board you need to find if Ravenscar support the board and do some changes in the Ada project.
In the python-taskset-execution/compile_flash_run.py you need to write your location of the gnat runtime.
