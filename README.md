# Assembly tasks
Some of the tasks implemented while learning assembly programming language. The descriptions of the tasks are presented below.

**TASK 1**\
The program reads any text and display the words in reverse order.\
*Example input:* `This is an example`\
*Example output:* `example an is This`

**TASK 2**\
`wyswietl_EAX_U2` subroutine converts a binary number stored in the EAX register into a decimal form (the number in the EAX register is stored in the U2 code). The result in the form of a number preceded by a + (for positive numbers) or - (for negative numbers) is printed to the console.\
`wczytaj_EAX_U2` subroutine reads a signed decimal number given by the user and save it to the EAX register in the U2 code.

**TASK 3**\
Implementation of the function with the following prototype
```
int dot_product(int tab1[], int tab2[], int n);
```
The function calculates the dot product of two vectors `tab1` and `tab2` of the same size `n`.

**TASK 4**\
 Implementation of a function that calculates time dilation. The program uses the instructions of an arithmetic coprocessor. The function prototype is as follows:
 ```
 float dylatacja_czasu(unsigned int detlta_t_zero, float predkosc);
 ```
 
 **TASK 5**\
The program working in the graphic mode that colors the appropriate half of the screen depending on the pressed arrow. The color changes every second in a red-green-blue cycle. The program should be run in the DosBOX virtual machine, which can be installed from the attached installation file or downloaded from the Internet.
