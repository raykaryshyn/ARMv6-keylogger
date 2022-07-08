# ARMv6 Keylogger

This project is a keylogger written in ARMv6 assembly and originally intended for the Raspberry Pi Zero W.

An explanation of most of the code and methodology can be found in the following Medium article: 
<https://medium.com/@raykaryshyn/keylogging-with-armv6-assembly-40edcf5bd0ff>.

## Usage

```
make

make run

[type things]

make stop

cat key.log
```

*Note: Make sure the `source` variable in main.s holds the correct /dev/input/eventX file path for the victim's keyboard.*
