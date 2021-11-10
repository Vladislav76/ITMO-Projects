import '../core/constants.dart';
import '../core/byte_storage.dart';
import '../core/distributions.dart';

class ArithmeticEncoder {
  final ByteOutputStorage output;
  var _low = 0;
  var _high = R - 1;
  var _btf = 0;

  ArithmeticEncoder({
    required this.output,
  });

  void encode(int x, ProbabilityModelDistribution distribution) {
    final range = _high - _low + 1;
    _high = _low + (range * distribution.getCumulativeFrequency(x + 1) / distribution.totalFrequences).floor() - 1;
    _low = _low + (range * distribution.getCumulativeFrequency(x) / distribution.totalFrequences).floor();

    // Normalization
    while (true) {
      if (_high < HALF) {
        output.writeBits(Bit.Zero, 1);
        output.writeBits(Bit.One, _btf);
        _btf = 0;
        _high = (_high << 1) | 1;
        _low = _low << 1;
      } else if (_low >= HALF) {
        output.writeBits(Bit.One, 1);
        output.writeBits(Bit.Zero, _btf);
        _btf = 0;
        _high = (_high << 1) - R + 1;
        _low = (_low << 1) - R;
      } else if (_low >= QUARTER && _high < THREE_QUARTER) {
        _high = (_high << 1) - HALF + 1;
        _low = (_low << 1) - HALF;
        _btf++;
      } else {
        break;
      }
    }
  }

  void finishEncoding() {
    if (_low < QUARTER) {
      output.writeBits(Bit.Zero, 1);
      output.writeBits(Bit.One, _btf + 1);
    } else {
      output.writeBits(Bit.One, 1);
      output.writeBits(Bit.Zero, _btf + 1);
    }
  }
}
