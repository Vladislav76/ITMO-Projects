import 'dart:io';

import '../core/byte_storage.dart';
import '../decoder/ppm_decoder.dart';

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
      final data = File(inFN).readAsBytesSync();
      final output = ByteOutputStorage();
      final decoder = PpmDecoder(
        input: ByteInputStorage(data: data),
        output: output,
      );
      decoder.decode();
      if (outFN == null) {
        outFN = inFN;
        outFN = outFN.substring(0, outFN.length - 4);
      }
      try {
        File(outFN).writeAsBytesSync(output.toList());
      } catch (_) {
        print('Unable to save output file $outFN');
      }
    } catch (e) {
      print('No such file! $e');
    }
  } else {
    print('File name is not specified!');
  }
}
