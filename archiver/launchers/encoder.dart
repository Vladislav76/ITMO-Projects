import 'dart:io';

import '../core/byte_storage.dart';
import '../encoder/ppm_encoder.dart';

void main(List<String> args) {
  String? inFN;
  String? outFN;
  if (args.length > 0) {
    inFN = args[0];
  }
  if (args.length > 1) {
    outFN = args[1];
  }
  if (inFN != null) {
    try {
      final output = ByteOutputStorage();
      final encoder = PpmEncoder(data: File(inFN).readAsBytesSync(), output: output);
      encoder.encode();
      final encodedData = output.toList();
      if (outFN == null) {
        outFN = inFN;
      }
      outFN += '.ppm';
      try {
        File(outFN).writeAsBytesSync(encodedData);
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
