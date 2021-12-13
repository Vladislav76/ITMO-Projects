import 'dart:io';

import '../core/byte_storage.dart';
import '../decoder/ppm_decoder.dart';
import '../encoder/ppm_encoder.dart';
import '../utils/statistics.dart';

void main(List<String> args) {
  if (args.length == 0) {
    print('File name is not specified!');
    return;
  }

  try {
    final testNames = ['bib', 'book1', 'book2', 'geo', 'news', 'obj1', 'obj2', 'paper1', 'paper2', 'pic', 'progc', 'progl', 'progp', 'trans'];
    final statistics = <Statistics>[];
    for (var testName in testNames) {
      // Encoding
      final encodingOutput = ByteOutputStorage();
      final initialData = File('input/$testName').readAsBytesSync();
      final encoder = PpmEncoder(D: 3, data: initialData, output: encodingOutput);
      encoder.compress();
      final encodedData = encodingOutput.toList();

      // Decoding
      final decodingOutput = ByteOutputStorage();
      final decoder = PpmDecoder(D: 3, input: ByteInputStorage(data: encodedData), output: decodingOutput);
      decoder.decompress();
      final decodedData = decodingOutput.toList();
      File('output/$testName').writeAsBytesSync(decodedData);

      // Add statistics
      statistics.add(
        Statistics(
          columnName: testName,
          entropy: calculateEntropy(encoder.unconditionalDistribution),
          archiveSizeInBytes: encodedData.length,
          bitsPerSymbol: encodedData.length * 8 / encoder.data.length,
        ),
      );

      // Check data loss
      var isWithoutLoss = true;
      if (initialData.length != decodedData.length) {
        print('different sizes: ${initialData.length} and ${decodedData.length}');
        isWithoutLoss = false;
      } else {
        for (var i = 0; i < initialData.length; i++) {
          if (initialData[i] != decodedData[i]) {
            isWithoutLoss = false;
            print('Not equals bytes: $i ${initialData[i]} ${decodedData[i]}');
            break;
          }
        }
      }
      print('$testName is archived, bytes are equals: $isWithoutLoss');
    }
    // Save statistics
    saveToCsv(
      fileName: args[0],
      statistics: statistics,
    );
  } catch (e) {
    print('Unable to open file: ${args[0]} $e');
  }
}
