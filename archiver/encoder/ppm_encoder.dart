import 'dart:typed_data';

import '../core/byte_storage.dart';
import '../core/constants.dart';
import '../core/ppm_object.dart';
import 'arithmetic_encoder.dart';
import '../core/distributions.dart';

class PpmEncoder extends PpmObject {
  final Uint8List data;
  final ByteOutputStorage output;
  final ArithmeticEncoder _encoder;
  final _uniformDistribution = UniformDistribution(alphabetPower: ALPHABET_POWER + 1);

  PpmEncoder({
    required this.output,
    required this.data,
    required int D,
  })  : _encoder = ArithmeticEncoder(output: output),
        super(D);

  void compress() {
    // Write data size in first 8 bytes
    final n = data.length;
    for (var i = 7; i >= 0; i--) {
      var byte = (n >> (8 * i));
      output.writeByte(byte);
    }
    // Encodes all symbols
    for (var x in data) {
      _encodeX(x);
      if (_uniformDistribution.getFrequency(x) > 0) {
        _uniformDistribution.resetFrequency(x);
      }
      incrementFrequency(x);
      updateCurrentContext(x);
    }
    _encoder.finishEncoding();
  }

  void _encodeX(int x) {
    HilbertMooreDistribution? distribution = unconditionalDistribution;
    var d = 0;
    // Find max d
    for (var i = 0; i < currentContext.length; i++) {
      if (distribution?.conditionalDistributions?[currentContext[i]] != null) {
        distribution = distribution?.conditionalDistributions?[currentContext[i]];
        d++;
      } else {
        break;
      }
    }

    // while p_t(x_t_+_1|s) = 0
    while (d > 0 && distribution?.getFrequency(x) == 0) {
      _encoder.encode(ESC_SYMBOL, distribution!);
      d--;
      distribution = unconditionalDistribution;
      for (var i = 0; i < d; i++) {
        distribution = distribution?.conditionalDistributions?[currentContext[i]];
      }
    }

    if (d > 0) {
      _encoder.encode(x, distribution!);
    } else {
      if (unconditionalDistribution.getFrequency(x) > 0) {
        _encoder.encode(x, unconditionalDistribution);
      } else {
        _encoder.encode(ESC_SYMBOL, unconditionalDistribution);
        _encoder.encode(x, _uniformDistribution);
      }
    }
  }
}
