class ConstantNameHelper {
  ConstantNameHelper._();

  static String mapKey() {
    const mapKey = String.fromEnvironment('MAP_KEY');

    if (mapKey.isEmpty) {
      throw AssertionError('MAP_KEY is not set');
    }

    return mapKey;
  }
}
