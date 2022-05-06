import 'package:flutter/material.dart';

class Value<T> {
  Value(this.value);

  T value;

  bool get hasValue => !['', null, false].contains(value);
}

class LayoutExtension<T> extends Value<T> {
  Layout layout;

  LayoutExtension(T value, this.layout) : super(value);
}

class Layout {
  IconData? icon;
  String? label = '';
  String? description = '';
  Color? iconColor;
  Color? labelColor;
  Color? descriptionColor;
  String? url;

  Layout(
      {this.label,
      this.description,
      this.icon,
      this.iconColor,
      this.labelColor,
      this.descriptionColor,
      this.url});

  Layout.ign()
      : icon = Icons.map,
        label = 'IGN',
        description = 'IGN';
  Layout.cancelled()
      : icon = Icons.cancel,
        label = 'Annulé',
        description = 'Ce Point Vert est annulé';
  Layout.fifteenKm()
      : icon = Icons.add_circle,
        label = '15 km',
        description = 'Parcours supplémentaire de marche de 15km';
  Layout.transport()
      : icon = Icons.train,
        label = 'Train/Bus',
        description = 'Accessible en transports en commun';
  Layout.wheelchair()
      : icon = Icons.accessible_forward,
        label = 'PMR',
        description = 'Parcours de 5 km accessible aux PMR';
  Layout.stroller()
      : icon = Icons.child_friendly,
        label = 'Poussettes',
        description = 'Parcours de 5 km accessible aux landaus';
  Layout.extraOrientation()
      : icon = Icons.map,
        label = '+ Orientation',
        description = 'Parcours supplémentaire d\'orientation de +/- 8km';
  Layout.extraWalk()
      : icon = Icons.directions_walk,
        label = '+ Marche',
        description = 'Parcours supplémentaire de marche de +/- 10km';
  Layout.guided()
      : icon = Icons.nature_people,
        label = 'Balade guidée',
        description = 'Balade guidée Nature';
  Layout.bike()
      : icon = Icons.directions_bike,
        label = 'Vélo',
        description = 'Parcours supplémentaire de vélo de +/- 20 km';
  Layout.mountainBike()
      : icon = Icons.directions_bike,
        label = 'VTT',
        description = 'Parcours supplémentaire de VTT de +/- 20 km';
  Layout.waterSupply()
      : icon = Icons.water_drop,
        label = 'Ravitaillement',
        description = 'Ravitaillement';
  Layout.beWapp()
      : icon = Icons.eco,
        label = 'BeWaPP',
        description = 'Participe à "Wallonie Plus Propre"',
        url = 'https://www.walloniepluspropre.be/';
  Layout.adepSante()
      : icon = Icons.fitness_center,
        label = 'Adep\'santé',
        description =
            'Possibilité de réaliser de petits exercices sur le parcours de 5 km';

  Layout copyWith(
      {IconData? icon,
      String? label,
      String? description,
      Color? iconColor,
      Color? labelColor,
      Color? descriptionColor,
      String? url}) {
    this.icon = icon ?? this.icon;
    this.label = label ?? this.label;
    this.description = description ?? this.description;
    this.iconColor = iconColor ?? this.iconColor;
    this.labelColor = labelColor ?? this.labelColor;
    this.descriptionColor = descriptionColor ?? this.descriptionColor;
    this.url = url ?? this.url;

    return this;
  }

  Layout colored(Color color) {
    iconColor = color;
    descriptionColor = color;
    labelColor = color;

    return this;
  }
}

class DbExtension {
  String name = '';

  DbExtension.of({String? name}) {
    this.name = name ?? '';
  }
}

class ApiExtension {
  String name = '';

  ApiExtension.of({String? name}) {
    this.name = name ?? '';
  }
}
