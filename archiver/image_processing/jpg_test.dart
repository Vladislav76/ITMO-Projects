import 'dart:io';

import 'jpg_compressor.dart';
import 'jpg_decompressor.dart';

const TEST_FILE_NAMES = [
  'airplane',
  'arctichare',
  'baboon',
  'cat',
  'fruits',
  'frymire',
  'girl',
  'lena',
  'monarch',
  'peppers',
  'pool',
  'sails',
  'serrano',
  'tulips',
  'watch',
];

Future<void> main(List<String> args) async {
  final qfactors = [30, 80];
  final originalSize = [0, 0];
  final compressedSize = [0, 0];
  final passedSize = [0, 0];
  for (var i = 0; i < qfactors.length; i++) {
    var compressedSizeSum = 0;
    var originalSizeSum = 0;
    for (var testName in TEST_FILE_NAMES) {
      final jpgFileName = '$testName${qfactors[i]}.jpg';
      final jpgPath = 'input/jpg${qfactors[i]}/$jpgFileName';
      final originalData = File(jpgPath).readAsBytesSync();
      originalSizeSum += originalData.length;
      final compressedData = await launchCompression(jpgPath, true);
      compressedSizeSum += compressedData.length;
      final endData = await launchDecompression(jpgFileName + '_compressed');
      File(jpgFileName).delete();
      if (originalData.length == endData.length) {
        var k = 0;
        while (k < originalData.length) {
          if (originalData[k] != endData[k]) break;
          k++;
        }
        if (k == originalData.length) passedSize[i]++;
      }
    }
    originalSize[i] = originalSizeSum;
    compressedSize[i] = compressedSizeSum;
  }

  print('* * * TEST LAUNCH RESULTS * * *');
  print('Quality factor | Passed tests | Original bytes | Compressed bytes | Compression percent');
  for (var i = 0; i < qfactors.length; i++) {
    print('${qfactors[i].toString().padRight(14, ' ')} | ' +
        '${(passedSize[i].toString() + '/' + TEST_FILE_NAMES.length.toString()).padRight(12, ' ')} | ' +
        '${originalSize[i].toString().padRight(14, ' ')} | ' +
        '${compressedSize[i].toString().padRight(16, ' ')} | ' +
        '${(1 - compressedSize[i] / originalSize[i]) * 100}');
  }
}
