import 'dart:typed_data';

class ProcessedJpgData {
  final Uint8List rawDcLength;
  final Uint8List rawAcRunLength;
  final Uint8List dcLength;
  final Uint8List acRunLength;
  final Uint8List binaryAcDc;
  final JpgData initialData;

  ProcessedJpgData(
    this.rawDcLength,
    this.rawAcRunLength,
    this.dcLength,
    this.acRunLength,
    this.binaryAcDc,
    this.initialData,
  );

  Uint8List serialize() {
    return Uint8List.fromList(
      [
        initialData.width ~/ 256,
        initialData.width % 256,
        initialData.height ~/ 256,
        initialData.height % 256,
        initialData.comp,
        initialData.qualityFactor,
        ...dcLength.toList(),
        ...acRunLength.toList(),
        ...binaryAcDc.toList(),
      ],
    );
  }

  int get allCompressedSize => binaryAcDc.length + dcLength.length + acRunLength.length;

  void printStatistics(String testName) {
    print('* * * COMPRESSION RESULTS ($testName) * * *');
    print('DC-length (before)      : ${rawDcLength.length} bytes');
    print('AC-run-length (before)  : ${rawAcRunLength.length} bytes');
    print('DC + AC (before)        : ${rawDcLength.length + rawAcRunLength.length} bytes');
    print('DC-length (after)       : ${dcLength.length} bytes');
    print('AC-run-length (after)   : ${acRunLength.length} bytes');
    print('DC + AC (after)         : ${dcLength.length + acRunLength.length} bytes');
    print('Binary (not compressed) : ${binaryAcDc.length} bytes');
    print('ALL                     : $allCompressedSize bytes');
    print('\n');
  }
}

class JpgDecompressorData {
  final Uint8List dcLength;
  final Uint8List acRunLength;
  final Uint8List binaryAcDc;

  JpgDecompressorData(
    this.dcLength,
    this.acRunLength,
    this.binaryAcDc,
  );
}

class JpgData {
  final int width;
  final int height;
  final int comp;
  final int qualityFactor;
  final List<List<List<int>>> tables;

  JpgData({
    required this.width,
    required this.height,
    required this.comp,
    required this.qualityFactor,
    required this.tables,
  });
}
