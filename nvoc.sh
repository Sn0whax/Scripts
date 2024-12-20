#!/usr/bin/env python

from pynvml import *

nvmlInit()

#This file is made in /usr/local/bin/
#This sets the GPU to adjust - if this gives you errors or you have multiple GPUs, set to 1 or try other values

myGPU = nvmlDeviceGetHandleByIndex(0)

#The GPU offset value should replace "240" in the line below.

nvmlDeviceSetGpcClkVfOffset(myGPU,0)

#The Mem Offset should be **multiplied by 2** to replace the "3000" below

#For example, an offset of 500 in GWE means inserting a value of 1000 in the next line

#nvmlDeviceSetMemClkVfOffset(myGPU,2000)

#The power limit should be set below in mW - 216W becomes 216000, etc. Remove the below line if you dont want to adjust power limits.

nvmlDeviceSetPowerManagementLimit(myGPU, 330000)
