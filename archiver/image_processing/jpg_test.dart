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
  final testCompressedSize = [List.filled(TEST_FILE_NAMES.length, 0), List.filled(TEST_FILE_NAMES.length, 0)];
  for (var i = 0; i < qfactors.length; i++) {
    var compressedSizeSum = 0;
    var originalSizeSum = 0;
    for (var testNum = 0; testNum < TEST_FILE_NAMES.length; testNum++) {
      final jpgFileName = '${TEST_FILE_NAMES[testNum]}${qfactors[i]}.jpg';
      final jpgPath = 'input/jpg${qfactors[i]}/$jpgFileName';
      final originalData = File(jpgPath).readAsBytesSync();
      originalSizeSum += originalData.length;
      final compressedData = await launchCompression(jpgPath, true);
      compressedSizeSum += compressedData.length;
      testCompressedSize[i][testNum] = compressedData.length;
      final endData = await launchDecompression(jpgFileName + '_compressed', null);
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

  print('* * * TEST LAUNCH DETAILS * * *');
  for (var testNum = 0; testNum < TEST_FILE_NAMES.length; testNum++) {
    stdout.write(TEST_FILE_NAMES[testNum]);
    for (var i = 0; i < qfactors.length; i++) {
      stdout.write(',');
      stdout.write(testCompressedSize[i][testNum]);
    }
    stdout.write('\n');
  }
  print('');
  print('* * * TEST LAUNCH SUMMARY * * *');
  print('Quality factor | Passed tests | Original bytes | Compressed bytes | Compression percent');
  for (var i = 0; i < qfactors.length; i++) {
    print('${qfactors[i].toString().padRight(14, ' ')} | ' +
        '${(passedSize[i].toString() + '/' + TEST_FILE_NAMES.length.toString()).padRight(12, ' ')} | ' +
        '${originalSize[i].toString().padRight(14, ' ')} | ' +
        '${compressedSize[i].toString().padRight(16, ' ')} | ' +
        '${(1 - compressedSize[i] / originalSize[i]) * 100}');
  }
}
