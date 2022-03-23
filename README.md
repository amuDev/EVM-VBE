# EVM-VBE

## WIP
 **TODOS**
 - [ ] Decoder (fetch variables from storage)
 - [ ] Encoder (update variables in storage)
 - [ ] Encoder (return a bytes of packed params as a view function)

## What is VBE?
VBE or Variable Byte Encoding, is a method of tightly packing variables to the bit level
The base concept is you set the first bit of the byte as a continuation bit where 1 represents this is the last byte of the encoded gap and to 0 otherwise.
https://nlp.stanford.edu/IR-book/html/htmledition/variable-byte-codes-1.html

## Why use it in the EVM?
I noticed most smart contract developers are not being thoughtful of the gas requirements their code produces, I want to explore abstract concepts to improve gas in the EVM, one of the most basic and major gas costs of any smart contract is storage. By improving how much data is being stored, you can provide major gas improvements to your users, and in turn, improve the network for everyone as the gas per block is lower than the limit, improving scalability.