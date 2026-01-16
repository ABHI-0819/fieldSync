class BaseNetwork {
  static final BaseNetwork _baseNetwork = BaseNetwork._internal();

  BaseNetwork._internal();
  factory BaseNetwork() {
    return _baseNetwork;
  }

  static const String FailedMessage = 'Connection Failed, Please try Again';
  static const String NetworkError= 'Oh no! Something went wrong';
}