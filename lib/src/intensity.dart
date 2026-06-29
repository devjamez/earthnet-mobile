import 'dart:math';

/// Expected shaking intensity (Modified Mercalli, MMI) at the user's location,
/// from event magnitude and epicentral distance. First-order intensity
/// prediction equation: rises with magnitude, falls with distance. Good enough
/// to decide "will I feel this?"; not a substitute for a site-specific model.
double expectedMmi(double magnitude, double distanceKm) {
  final r = max(distanceKm, 6.0); // floor to avoid near-field blow-up
  final mmi = 1.5 * magnitude - 2.8 * (log(r) / ln10) + 2.2;
  return mmi.clamp(1.0, 12.0);
}

/// At/above this MMI the event is "felt" — the threshold the intensity filter
/// uses to decide whether an alert is worth showing/alarming.
const double kFeltMmi = 3.0;

const _roman = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];

const _labels = [
  'No se siente', // I
  'No se siente', // II
  'Débil', // III
  'Leve', // IV
  'Moderado', // V
  'Fuerte', // VI
  'Muy fuerte', // VII
  'Severo', // VIII
  'Violento', // IX
  'Extremo', // X+
];

/// Human label like "V · Moderado" for an MMI value.
String intensityText(double mmi) {
  final level = mmi.round().clamp(1, 12);
  final label = _labels[(level - 1).clamp(0, _labels.length - 1)];
  return '${_roman[level]} · $label';
}
