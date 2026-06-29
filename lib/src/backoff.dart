/// Exponential reconnect backoff in seconds: starts at [min], doubles each
/// attempt, capped at [max]. Reset to [min] after a healthy connection.
int nextBackoff(int current, {int min = 1, int max = 30}) {
  if (current < min) return min;
  final n = current * 2;
  return n > max ? max : n;
}
