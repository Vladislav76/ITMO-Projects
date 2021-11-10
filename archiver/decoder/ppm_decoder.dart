import 'dart:math';

import '../core/byte_storage.dart';
import '../core/constants.dart';
import '../core/distributions.dart';
import '../core/ppm_object.dart';
import '../decoder/arithmetic_decoder.dart';

class PpmDecoder extends PpmObject {
  final ArithmeticDecoder _decoder;
  final ByteOutputStorage output;
  final ByteInputStorage input;
  final _uniformDistribution = UniformDistribution(alphabetPower: ALPHABET_POWER + 1);

  PpmDecoder({
    required this.input,
    required this.output,
  }) : _decoder = ArithmeticDecoder(input: input);

  void decode() {
    // Read data size from first 8 bytes
    num n = 0;
    var exp = pow(256, 7);
    for (var i = 7; i >= 0; i--) {
      final byte = input.readByte();
      n += exp * byte;
      exp = exp / 256;
    }
    _decoder.prepare();
    for (var i = 1; i <= n; i++) {
      final x = _decodeX();
      if (_uniformDistribution.getFrequency(x) > 0) {
        _uniformDistribution.resetFrequency(x);
      }
      output.writeByte(x);
      incrementFrequency(x);
      updateCurrentContext(x);
    }
  }

  int _decodeX() {
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
    while (d >= 0) {
      final x = _decoder.decode(distribution!);
      if (x != ESC_SYMBOL) {
        return x;
      } else {
        d--;
        distribution = unconditionalDistribution;
        for (var i = 0; i < d; i++) {
          distribution = distribution?.conditionalDistributions?[currentContext[i]];
        }
      }
    }

    return _decoder.decode(_uniformDistribution);
  }
}
