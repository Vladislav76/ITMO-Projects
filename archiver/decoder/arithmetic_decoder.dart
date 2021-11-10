import '../core/byte_storage.dart';
import '../core/constants.dart';
import '../core/distributions.dart';

class ArithmeticDecoder {
  final ByteInputStorage input;
  var _low = 0;
  var _high = R - 1;
  var _value = 0;

  ArithmeticDecoder({
    required this.input,
  });

  void prepare() {
    for (var i = 0; i < BITNESS; i++) {
      _value <<= 1;
      if (!tryReadNewBit()) break;
    }
  }

  int decode(ProbabilityModelDistribution distribution) {
    final range = _high - _low + 1;
    final aux = (((_value - _low + 1) * distribution.totalFrequences - 1) / range).floor();
    var i = 0;

    while (distribution.getCumulativeFrequency(i + 1) <= aux) i++;
    final x = i;
    _high = _low + (range * distribution.getCumulativeFrequency(x + 1) / distribution.totalFrequences).floor() - 1;
    _low = _low + (range * distribution.getCumulativeFrequency(x) / distribution.totalFrequences).floor();

    // Normalization
    while (true) {
      if (_high < HALF) {
        _high = (_high << 1) | 1;
        _low = _low << 1;
        _value = (_value << 1);
        if (!tryReadNewBit()) break;
      } else if (_low >= HALF) {
        _high = (_high << 1) - R + 1;
        _low = (_low << 1) - R;
        _value = (_value << 1) - R;
        if (!tryReadNewBit()) break;
      } else if (_low >= QUARTER && _high < THREE_QUARTER) {
        _high = (_high << 1) - HALF + 1;
        _low = (_low << 1) - HALF;
        _value = (_value << 1) - HALF;
        if (!tryReadNewBit()) break;
      } else {
        break;
      }
    }
    return x;
  }

  bool tryReadNewBit() {
    final bit = input.readBit();
    if (bit == null) {
      return false;
    } else {
      _value |= (bit == Bit.Zero) ? 0 : 1;
      return true;
    }
  }
}
