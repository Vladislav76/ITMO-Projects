import 'dart:io';
import 'dart:typed_data';

import '../core/byte_storage.dart';
import 'models.dart';

JpgData loadJpgData(String fileName) {
  final tables = <List<List<int>>>[];
  try {
    final f = File(fileName);
    final lines = f.readAsLinesSync();
    final header = lines.first.split(' ');
    for (var line in lines.skip(1)) {
      final vector = line.split(' ').map((e) => int.tryParse(e)).where((e) => e != null).toList();
      if (vector.length != 64) {
        print('Incorrect format of vector');
      } else {
        final table = <List<int>>[];
        for (var i = 0; i <= 7; i++) {
          final row = <int>[];
          for (var j = 0; j <= 7; j++) {
            row.add(vector[i * 8 + j]!);
          }
          table.add(row);
        }
        tables.add(table);
      }
    }
    return JpgData(
      qualityFactor: int.parse(header[0]),
      width: int.parse(header[1]),
      height: int.parse(header[2]),
      comp: int.parse(header[3]),
      tables: tables,
    );
  } catch (e) {
    throw 'Unable to open file $fileName $e';
  }
}

void saveJpgData(String fileName, JpgData data) {
  try {
    File(fileName).writeAsStringSync(data.tables.map((table) => table.map((row) => row.join(' ')).join('\n')).join('\n'));
  } catch (e) {
    print('Failed to save source tables to file. Exception: $e');
  }
}

void saveByteData(String fileName, Uint8List data) {
  try {
    File(fileName).writeAsBytesSync(data);
  } catch (e) {
    print('Failed to save data in the file. Exception: $e');
  }
}

Uint8List loadCompressedJpg(String fileName) {
  try {
    final data = File(fileName).readAsBytesSync();
    return data;
  } catch (e) {
    print('Unable to open file $fileName $e');
  }
  return Uint8List(0);
}

void writeDigitAsBinary(int x, ByteOutputStorage output) {
  final bin = x.toRadixString(2);
  for (var k = 0; k <= bin.length - 1; k++) {
    if (bin.substring(k, k + 1) == '0') {
      output.writeBits(Bit.Zero, 1);
    } else {
      output.writeBits(Bit.One, 1);
    }
  }
}

void writeStringAsBinary(String x, ByteOutputStorage output) {
  for (var k = 0; k <= x.length - 1; k++) {
    if (x.substring(k, k + 1) == '0') {
      output.writeBits(Bit.Zero, 1);
    } else {
      output.writeBits(Bit.One, 1);
    }
  }
}

int getBinaryCodeLength(int x) => x.toRadixString(2).length;

int processDigitCoefficient(int x) => (x >= 0) ? x : (x - 1).abs();

String extractFileName(String path) {
  var fileNamePos = path.lastIndexOf('/');
  if (fileNamePos == -1) {
    fileNamePos = path.lastIndexOf('\\');
  }
  if (fileNamePos == -1) {
    fileNamePos = 0;
  } else {
    fileNamePos++;
  }
  return path.substring(fileNamePos);
}
