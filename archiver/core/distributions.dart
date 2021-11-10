import 'constants.dart';

abstract class ProbabilityModelDistribution {
  int get totalFrequences;
  int getFrequency(int x);
  int getCumulativeFrequency(int x);
}

class HilbertMooreDistribution implements ProbabilityModelDistribution {
  final List<HilbertMooreDistribution?>? conditionalDistributions;

  final _frequences = List.filled(ALPHABET_POWER + 1, 0);
  final _cumulativeFrequences = List.filled(ALPHABET_POWER + 2, 0);
  var _totalFrequences = 0;

  HilbertMooreDistribution({
    required bool hasConditionalDistributions,
  }) : conditionalDistributions = hasConditionalDistributions ? List.filled(ALPHABET_POWER + 1, null) : null;

  @override
  int get totalFrequences => _totalFrequences;

  @override
  int getFrequency(int x) => _frequences[x];

  @override
  int getCumulativeFrequency(int x) => _cumulativeFrequences[x];

  void incrementFrequency(int x) {
    _frequences[x]++;
    _totalFrequences++;
    for (var k = x + 1; k < _cumulativeFrequences.length; k++) {
      _cumulativeFrequences[k] = _cumulativeFrequences[k - 1] + _frequences[k - 1];
    }
  }

  void prettyPrint({String context = ''}) {
    for (var i = 0; i < _frequences.length - 1; i++) {
      final freq = _frequences[i];
      if (freq > 0) {
        print('freq($i${context.isNotEmpty ? '|$context' : ''}) = $freq');
      }
    }
    if (conditionalDistributions != null) {
      for (var i = 0; i < _frequences.length - 1; i++) {
        conditionalDistributions?[i]?.prettyPrint(context: '$context $i');
      }
    }
  }
}

class UniformDistribution implements ProbabilityModelDistribution {
  final int alphabetPower;
  late int _total;
  late final List<int> _frequences;
  late final List<int> _cumulatives;

  UniformDistribution({
    required this.alphabetPower,
  }) {
    _total = alphabetPower;
    _frequences = List.filled(alphabetPower, 1);
    _cumulatives = List.filled(alphabetPower + 1, 0);
    _calculateQumulatives(0);
  }

  @override
  int get totalFrequences => _total;

  @override
  int getFrequency(int x) => _frequences[x];

  @override
  int getCumulativeFrequency(int x) => _cumulatives[x];

  void resetFrequency(int x) {
    if (_frequences[x] > 0) {
      _total -= _frequences[x];
      _frequences[x] = 0;
      _calculateQumulatives(x);
    }
  }

  void _calculateQumulatives(int x) {
    for (var k = x + 1; k < _cumulatives.length; k++) {
      _cumulatives[k] = _cumulatives[k - 1] + _frequences[k - 1];
    }
  }
}
