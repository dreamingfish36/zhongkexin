# Tensor_Mem

## Tensor Caculation

### Mid

This part is built for Tensor Cross Bar processing unit, the mid structure of Tensor caculate 

#### Current Implementation ✨
- [x] Tensor_Crossbar_Array_4m4n4k
  - [x] State machine
  - [x] Load the matrix with column form
  - [x] Output the array with column form
  - [x] Array multiplication
  - [x] Array plus
  - [x] Fixed the first result output timing error, which ignored the first column
  - [x] Transpose bug fixed

- [x] Tensor_Simpel_Output_Adder


#### Files

- ```Tensor_Crossbar_Array_4m4n4k.v```      Tensor Array caculate Crossbar unit
- ```Tensor_Crossbar_Array_4m4n4k_tb.v```   Test Bench file of Tensor_Crossbar_Array_4m4n4k
- ```Tensor_Simple_Output_Adder.v```        Just a simple adder module without any optimization
- ```Tensor_Simple_Output_Adder_tb.v```     Test Bench file of Tensor_Simple_Output_Adder