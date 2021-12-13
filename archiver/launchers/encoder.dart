import 'dart:io';

import '../core/byte_storage.dart';
import '../encoder/ppm_encoder.dart';

void launchEncoding(String? inputFileName, String? outputFileName) {
  if (inputFileName != null) {
    try {
      final output = ByteOutputStorage();
      final encoder = PpmEncoder(D: 3, data: File(inputFileName).readAsBytesSync(), output: output);
      encoder.compress();
      final encodedData = output.toList();
      if (outputFileName == null) {
        outputFileName = inputFileName;
      }
      outputFileName += '.ppm';
      try {
        File(outputFileName).writeAsBytesSync(encodedData);
      } catch (_) {
        print('Unable to save output file');
      }
    } catch (_) {
      print('No such file!');
    }
  } else {
    print('File name is not specified!');
  }
}

void main(List<String> args) {
  String? inFN;
  String? outFN;
  if (args.length > 0) {
    inFN = args[0];
  }
  if (args.length > 1) {
    outFN = args[1];
  }
  launchEncoding(inFN, outFN);
}
