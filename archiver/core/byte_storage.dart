import 'dart:typed_data';

enum Bit {
  Zero,
  One,
}

class ByteOutputStorage {
  final _data = <int>[];
  var _currentByte = 0;
  var _currentFilledBitCount = 0;

  void writeBits(Bit bit, int count) {
    for (var i = 0; i < count; i++) {
      _currentFilledBitCount++;
      _currentByte <<= 1;
      if (bit == Bit.One) {
        _currentByte |= 1;
      }
      if (_currentFilledBitCount == 8) {
        _data.add(_currentByte);
        _currentByte = 0;
        _currentFilledBitCount = 0;
      }
    }
  }

  void writeByte(int byte) {
    for (var i = 0; i < 8; i++) {
      final bit = (byte >> (7 - i)) & 1;
      writeBits((bit == 0) ? Bit.Zero : Bit.One, 1);
    }
  }

  Uint8List toList() {
    if (_currentFilledBitCount > 0) {
      _currentByte <<= (8 - _currentFilledBitCount);
      _data.add(_currentByte);
      _currentByte = 0;
    }
    return Uint8List.fromList(_data);
  }
}

class ByteInputStorage {
  final Uint8List data;
  var _currentByteIndex = 0;
  var _currentReadedBitCount = 0;

  ByteInputStorage({
    required this.data,
  });

  Bit? readBit() {
    if (_currentByteIndex >= data.length) {
      return null;
    }
    var bitValue = data[_currentByteIndex] >> (7 - _currentReadedBitCount);
    _currentReadedBitCount++;
    if (_currentReadedBitCount == 8) {
      _currentReadedBitCount = 0;
      _currentByteIndex++;
    }

    return (bitValue & 1 == 1) ? Bit.One : Bit.Zero;
  }

  int readByte() {
    var byte = 0;
    for (var i = 0; i < 8; i++) {
      final bit = readBit();
      byte <<= 1;
      byte |= (bit == Bit.One) ? 1 : 0;
    }
    return byte;
  }
}
