# PPMA Encoder/Decoder

## Запуск архиватора
```
bin\encoder <path to original file> [path to output] 
``` 

## Запуск деархиватора
```
bin\decoder <path to encoded file> [path to output] 
``` 

## Запуск тестового стенда
```
bin\test <path to output CSV file> 
``` 

# JPEG Compressor/Decompressor

## Запуск архиватора
```
# Command structure
> bin\jpg_compressor <path to JPEG file>

# Example
> bin\jpg_compressor input\jpg80\fruits80.jpg
``` 

## Запуск деархиватора
```
# Command structure
> bin\jpg_decompressor <path to compressed JPEG file> [path to output decompressed JPEG file]

# Example 1
> bin\jpg_decompressor fruits80.jpg_compressed

# Example 2
> bin\jpg_decompressor fruits80.jpg_compressed ~fruits80.jpg
``` 

## Запуск тестового стенда
```
> bin\jpg_test
``` 