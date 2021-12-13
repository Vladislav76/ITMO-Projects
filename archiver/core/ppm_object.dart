import 'constants.dart';
import 'distributions.dart';

class PpmObject {
  final int D;
  final currentContext = <int>[];
  late final unconditionalDistribution = HilbertMooreDistribution(hasConditionalDistributions: D >= 1)..incrementFrequency(ESC_SYMBOL);

  PpmObject(this.D);

  void updateCurrentContext(int x) {
    if (D >= 1) {
      currentContext.insert(0, x);
      if (currentContext.length > D) {
        currentContext.removeLast();
      }
    }
  }

  void incrementFrequency(int x) {
    HilbertMooreDistribution? distribution = unconditionalDistribution;
    unconditionalDistribution.incrementFrequency(x);
    for (var i = 0; i < currentContext.length; i++) {
      final contextSymbol = currentContext[i];
      if (distribution?.conditionalDistributions?[contextSymbol] == null) {
        distribution?.conditionalDistributions?[contextSymbol] = HilbertMooreDistribution(hasConditionalDistributions: i + 1 < D);
        distribution?.conditionalDistributions?[contextSymbol]?.incrementFrequency(ESC_SYMBOL);
      }
      distribution = distribution?.conditionalDistributions?[contextSymbol];
      distribution?.incrementFrequency(x);
    }
  }
}
