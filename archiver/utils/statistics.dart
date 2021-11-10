import 'dart:io';
import 'dart:math';

import '../core/constants.dart';
import '../core/distributions.dart';
import '../core/entropy.dart';

class Statistics {
  final String columnName;
  final Entropy entropy;
  final int archiveSizeInBytes;
  final double bitsPerSymbol;

  Statistics({
    required this.columnName,
    required this.entropy,
    required this.archiveSizeInBytes,
    required this.bitsPerSymbol,
  });
}

void saveToCsv({
  required String fileName,
  required List<Statistics> statistics,
}) {
  try {
    final output = File(fileName).openWrite();
    output.write(',${statistics.map((e) => e.columnName).join(',')}\n');
    output.write('H(X),${statistics.map((e) => e.entropy.unconditional.toStringAsFixed(5)).join(',')}\n');
    output.write('H(X|X),${statistics.map((e) => e.entropy.firstConditional.toStringAsFixed(5)).join(',')}\n');
    output.write('H(X|XX),${statistics.map((e) => e.entropy.secondConditional.toStringAsFixed(5)).join(',')}\n');
    output.write('Bits per symbol,${statistics.map((e) => e.bitsPerSymbol.toStringAsFixed(5)).join(',')}\n');
    output.write('Archive size in bytes,${statistics.map((e) => e.archiveSizeInBytes).join(',')}\n');
    output.write('All archive size,${statistics.map((e) => e.archiveSizeInBytes).fold<int>(0, (prev, e) => prev + e)}');
    output.close();
  } catch (_) {
    print('No such file!');
  }
}

Entropy calculateEntropy(HilbertMooreDistribution distribution) {
  var hX = 0.0;
  var hXX = 0.0;
  var hXXX = 0.0;
  for (var z = 0; z < ALPHABET_POWER; z++) {
    final freqZ = distribution.getFrequency(z);
    final yy = distribution.conditionalDistributions?[z];
    final pZ = freqZ / (distribution.totalFrequences - distribution.getFrequency(ESC_SYMBOL));
    if (pZ > 0) {
      hX += (log(pZ) / log(2)) * pZ;
      if (yy != null) {
        for (var y = 0; y < ALPHABET_POWER; y++) {
          final freqY = yy.getFrequency(y);
          final xx = yy.conditionalDistributions?[y];
          final pY_Z = freqY / (yy.totalFrequences - yy.getFrequency(ESC_SYMBOL));
          if (pY_Z > 0) {
            hXX += (log(pY_Z) / log(2)) * pY_Z * freqZ / (distribution.totalFrequences - distribution.getFrequency(ESC_SYMBOL));
            if (xx != null) {
              for (var x = 0; x < ALPHABET_POWER; x++) {
                final freqX = xx.getFrequency(x);
                final pX_YZ = freqX / (xx.totalFrequences - xx.getFrequency(ESC_SYMBOL));
                if (pX_YZ > 0) {
                  hXXX += (log(pX_YZ) / log(2)) *
                      pX_YZ *
                      freqZ /
                      (distribution.totalFrequences - distribution.getFrequency(ESC_SYMBOL)) *
                      freqY /
                      (yy.totalFrequences - yy.getFrequency(ESC_SYMBOL));
                }
              }
            }
          }
        }
      }
    }
  }
  return Entropy(
    unconditional: -hX,
    firstConditional: -hXX,
    secondConditional: -hXXX,
  );
}
