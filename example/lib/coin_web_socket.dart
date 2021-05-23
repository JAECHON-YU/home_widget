/// type : "ticker"
/// content : {"symbol":"BTC_KRW","tickType":"24H","date":"20200129","time":"121844","openPrice":"2302","closePrice":"2317","lowPrice":"2272","highPrice":"2344","value":"2831915078.07065789","volume":"1222314.51355788","sellVolume":"760129.34079004","buyVolume":"462185.17276784","prevClosePrice":"2326","chgRate":"0.65","chgAmt":"15","volumePower":"60.80"}

class CoinWebSocket {
  String _type;
  Content _content;

  String get type => _type;
  Content get content => _content;

  CoinWebSocket({
      String type, 
      Content content}){
    _type = type;
    _content = content;
}

  CoinWebSocket.fromJson(dynamic json) {
    _type = json["type"];
    _content = json["content"] != null ? Content.fromJson(json["content"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = _type;
    if (_content != null) {
      map["content"] = _content.toJson();
    }
    return map;
  }

}

/// symbol : "BTC_KRW"
/// tickType : "24H"
/// date : "20200129"
/// time : "121844"
/// openPrice : "2302"
/// closePrice : "2317"
/// lowPrice : "2272"
/// highPrice : "2344"
/// value : "2831915078.07065789"
/// volume : "1222314.51355788"
/// sellVolume : "760129.34079004"
/// buyVolume : "462185.17276784"
/// prevClosePrice : "2326"
/// chgRate : "0.65"
/// chgAmt : "15"
/// volumePower : "60.80"

class Content {
  String _symbol;
  String _tickType;
  String _date;
  String _time;
  String _openPrice;
  String _closePrice;
  String _lowPrice;
  String _highPrice;
  String _value;
  String _volume;
  String _sellVolume;
  String _buyVolume;
  String _prevClosePrice;
  String _chgRate;
  String _chgAmt;
  String _volumePower;

  String get symbol => _symbol;
  String get tickType => _tickType;
  String get date => _date;
  String get time => _time;
  String get openPrice => _openPrice;
  String get closePrice => _closePrice;
  String get lowPrice => _lowPrice;
  String get highPrice => _highPrice;
  String get value => _value;
  String get volume => _volume;
  String get sellVolume => _sellVolume;
  String get buyVolume => _buyVolume;
  String get prevClosePrice => _prevClosePrice;
  String get chgRate => _chgRate;
  String get chgAmt => _chgAmt;
  String get volumePower => _volumePower;

  Content({
      String symbol, 
      String tickType, 
      String date, 
      String time, 
      String openPrice, 
      String closePrice, 
      String lowPrice, 
      String highPrice, 
      String value, 
      String volume, 
      String sellVolume, 
      String buyVolume, 
      String prevClosePrice, 
      String chgRate, 
      String chgAmt, 
      String volumePower}){
    _symbol = symbol;
    _tickType = tickType;
    _date = date;
    _time = time;
    _openPrice = openPrice;
    _closePrice = closePrice;
    _lowPrice = lowPrice;
    _highPrice = highPrice;
    _value = value;
    _volume = volume;
    _sellVolume = sellVolume;
    _buyVolume = buyVolume;
    _prevClosePrice = prevClosePrice;
    _chgRate = chgRate;
    _chgAmt = chgAmt;
    _volumePower = volumePower;
}

  Content.fromJson(dynamic json) {
    _symbol = json["symbol"];
    _tickType = json["tickType"];
    _date = json["date"];
    _time = json["time"];
    _openPrice = json["openPrice"];
    _closePrice = json["closePrice"];
    _lowPrice = json["lowPrice"];
    _highPrice = json["highPrice"];
    _value = json["value"];
    _volume = json["volume"];
    _sellVolume = json["sellVolume"];
    _buyVolume = json["buyVolume"];
    _prevClosePrice = json["prevClosePrice"];
    _chgRate = json["chgRate"];
    _chgAmt = json["chgAmt"];
    _volumePower = json["volumePower"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["symbol"] = _symbol;
    map["tickType"] = _tickType;
    map["date"] = _date;
    map["time"] = _time;
    map["openPrice"] = _openPrice;
    map["closePrice"] = _closePrice;
    map["lowPrice"] = _lowPrice;
    map["highPrice"] = _highPrice;
    map["value"] = _value;
    map["volume"] = _volume;
    map["sellVolume"] = _sellVolume;
    map["buyVolume"] = _buyVolume;
    map["prevClosePrice"] = _prevClosePrice;
    map["chgRate"] = _chgRate;
    map["chgAmt"] = _chgAmt;
    map["volumePower"] = _volumePower;
    return map;
  }

}