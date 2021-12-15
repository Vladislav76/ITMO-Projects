import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../decoder/ppm_decoder.dart';
import '../encoder/ppm_encoder.dart';
import '../core/byte_storage.dart';
import 'models.dart';
import 'utils.dart';
import 'zigzags.dart';

class JpgDecompressor {
  static JpgData decompress(Uint8List data) {
    final tables = <List<List<int>>>[];
    final result = JpgData(
      width: data[0] * 256 + data[1],
      height: data[2] * 256 + data[3],
      comp: data[4],
      qualityFactor: data[5],
      tables: tables,
    );
    final zigzag = zigzags[data[6]];
    data = data.sublist(7);

    ByteOutputStorage compressed;
    ByteOutputStorage decompressed;
    PpmDecoder decoder;
    PpmEncoder encoder;

    // Decompress DC
    decompressed = ByteOutputStorage();
    decoder = PpmDecoder(input: ByteInputStorage(data: data), output: decompressed, D: 0);
    decoder.decompress();
    final dcLength = decompressed.toList();

    // Decompress AC
    compressed = ByteOutputStorage();
    encoder = PpmEncoder(data: dcLength, output: compressed, D: 0);
    encoder.compress();
    data = data.sublist(compressed.toList().length);
    decompressed = ByteOutputStorage();
    decoder = PpmDecoder(input: ByteInputStorage(data: data), output: decompressed, D: 1);
    decoder.decompress();
    final acRunLength = decompressed.toList();

    // Extract binary AC/DC
    compressed = ByteOutputStorage();
    encoder = PpmEncoder(data: acRunLength, output: compressed, D: 1);
    encoder.compress();
    final binaryAcDc = data.sublist(compressed.toList().length);

    final dc = ByteInputStorage(data: dcLength);
    final ac = ByteInputStorage(data: acRunLength);
    final bin = ByteInputStorage(data: binaryAcDc);

    var i = 0;
    var j = 0;
    var acPosition = 0;
    var previousDC = 0;
    late List<List<int>> table;
    while (true) {
      // Process DC
      if (i == 0 && j == 0) {
        table = List.generate(8, (_) => List.filled(8, 0));
        final len = readRunOrLength(dc);
        final diff = readCoefficient(bin, len);
        table[i][j] = diff + previousDC;
        previousDC = table[i][j];
        j++;
      }
      // Process AC
      else {
        var run = readRunOrLength(ac);
        var len = readRunOrLength(ac);
        acPosition++;
        // EOB
        if (len == 0 && run == 0) {
          i = 0;
          j = 0;
          tables.add(table);
          if (acPosition == ac.data.length) break;
        } else {
          if (len == 0) {
            run = run * 16 + readRunOrLength(ac);
            len = readRunOrLength(ac);
            acPosition++;
          }
          // Skip [run] elements
          for (var k = 1; k <= run; k++) {
            j++;
            if (j == 8) {
              i++;
              j = 0;
            }
          }
          final z = zigzag[i * 8 + j - 1];
          table[z ~/ 8][z % 8] = readCoefficient(bin, len);
          j++;
          if (j == 8) {
            i++;
            j = 0;
          }
        }
      }
    }

    return result;
  }

  static int readRunOrLength(ByteInputStorage input) {
    var result = 0;
    for (var k = 3; k >= 0; k--) {
      final bit = input.readBit() == Bit.One ? 1 : 0;
      result |= (bit << k);
    }
    return result;
  }

  static int readCoefficient(ByteInputStorage input, int length) {
    var c = 0;
    var s = '';
    for (var k = 1; k <= length; k++) {
      final bit = input.readBit() == Bit.One ? '1' : '0';
      s += bit;
    }
    if (s.isNotEmpty) {
      c = int.parse(s, radix: 2);
      // If it's negative
      if (s[0] == '0') {
        c = c - pow(2, length).toInt() + 1;
      }
    }
    return c;
  }
}

Future<Uint8List> launchDecompression(String compressedJpgPath, String? customJpgFileName) async {
  final compressedData = loadCompressedJpg(compressedJpgPath);
  File(compressedJpgPath).delete();
  final jpgData = JpgDecompressor.decompress(compressedData);
  var jpgTableFileName = extractFileName(compressedJpgPath);
  var jpgFileName = jpgTableFileName;
  final jpgExtPos = jpgTableFileName.lastIndexOf('.jpg');
  if (jpgExtPos != -1) {
    jpgFileName = jpgTableFileName.substring(0, jpgExtPos + 4);
    jpgTableFileName = jpgFileName + '_table';
  }
  saveJpgData(jpgTableFileName, jpgData);
  await Process.run(
    'bin/jpg_encoder.exe',
    [
      jpgTableFileName,
      customJpgFileName ?? jpgFileName,
      jpgData.width.toString(),
      jpgData.height.toString(),
      jpgData.comp.toString(),
      jpgData.qualityFactor.toString(),
    ],
  );
  File(jpgTableFileName).delete();
  return File(customJpgFileName ?? jpgFileName).readAsBytesSync();
}

Future<void> main(List<String> args) async {
  if (args.length > 0) {
    final compressedJpgPath = args[0];
    await launchDecompression(compressedJpgPath, args.length > 1 ? args[1] : null);
  } else {
    print('Please, specify input file name containing compressed JPG file');
  }
}
