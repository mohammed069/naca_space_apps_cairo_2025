import 'dart:convert';

class NasaResponse {
  final String type;
  final Geometry geometry;
  final Properties properties;
  final Header header;
  final List<dynamic> messages;
  final Map<String, ParameterInfo> parameters;
  final Times times;

  NasaResponse({
    required this.type,
    required this.geometry,
    required this.properties,
    required this.header,
    required this.messages,
    required this.parameters,
    required this.times,
  });

  factory NasaResponse.fromJson(Map<String, dynamic> json) {
    return NasaResponse(
      type: json['type'],
      geometry: Geometry.fromJson(json['geometry']),
      properties: Properties.fromJson(json['properties']),
      header: Header.fromJson(json['header']),
      messages: json['messages'] ?? [],
      parameters: (json['parameters'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, ParameterInfo.fromJson(v)),
      ),
      times: Times.fromJson(json['times']),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'geometry': geometry.toJson(),
    'properties': properties.toJson(),
    'header': header.toJson(),
    'messages': messages,
    'parameters': parameters.map((k, v) => MapEntry(k, v.toJson())),
    'times': times.toJson(),
  };
}

class Geometry {
  final String type;
  final List<double> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'],
      coordinates:
          (json['coordinates'] as List)
              .map((e) => (e as num).toDouble())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'coordinates': coordinates};
}

class Properties {
  final Map<String, Map<String, double>> parameter;

  Properties({required this.parameter});

  factory Properties.fromJson(Map<String, dynamic> json) {
    final param = (json['parameter'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        k,
        (v as Map<String, dynamic>).map(
          (date, value) => MapEntry(date, (value as num).toDouble()),
        ),
      ),
    );
    return Properties(parameter: param);
  }

  Map<String, dynamic> toJson() => {'parameter': parameter};
}

class Header {
  final String title;
  final Api api;
  final List<String> sources;
  final double fillValue;
  final String timeStandard;
  final String start;
  final String end;

  Header({
    required this.title,
    required this.api,
    required this.sources,
    required this.fillValue,
    required this.timeStandard,
    required this.start,
    required this.end,
  });

  factory Header.fromJson(Map<String, dynamic> json) {
    return Header(
      title: json['title'],
      api: Api.fromJson(json['api']),
      sources: List<String>.from(json['sources']),
      fillValue: (json['fill_value'] as num).toDouble(),
      timeStandard: json['time_standard'],
      start: json['start'],
      end: json['end'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'api': api.toJson(),
    'sources': sources,
    'fill_value': fillValue,
    'time_standard': timeStandard,
    'start': start,
    'end': end,
  };
}

class Api {
  final String version;
  final String name;

  Api({required this.version, required this.name});

  factory Api.fromJson(Map<String, dynamic> json) {
    return Api(version: json['version'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'version': version, 'name': name};
}

class ParameterInfo {
  final String units;
  final String longname;

  ParameterInfo({required this.units, required this.longname});

  factory ParameterInfo.fromJson(Map<String, dynamic> json) {
    return ParameterInfo(units: json['units'], longname: json['longname']);
  }

  Map<String, dynamic> toJson() => {'units': units, 'longname': longname};
}

class Times {
  final double data;
  final double process;

  Times({required this.data, required this.process});

  factory Times.fromJson(Map<String, dynamic> json) {
    return Times(
      data: (json['data'] as num).toDouble(),
      process: (json['process'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'data': data, 'process': process};
}
