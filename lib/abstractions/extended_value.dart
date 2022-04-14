import 'package:flutter/material.dart';

class ExtendedValue<T> {
  ExtendedValue(this.value, {this.layout, this.db, this.api});

  T value;
  final LayoutExtension? layout;
  final DbExtension? db;
  final ApiExtension? api;

  bool get hasValue => !['', null, false].contains(value);
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

class LayoutExtension {
  IconData? icon;
  String label = '';
  String description = '';
  Color? iconColor;
  Color? labelColor;
  Color? descriptionColor;
  String? url;

  LayoutExtension.of(
      {String? label,
      String? description,
      this.icon,
      this.iconColor,
      this.labelColor,
      this.descriptionColor,
      this.url}) {
    this.label = label ?? '';
    this.description = description ?? '';
  }

  LayoutExtension.ign()
      : icon = Icons.map,
        label = 'IGN',
        description = 'IGN';
  LayoutExtension.cancelled()
      : icon = Icons.cancel,
        label = 'Annulé',
        description = 'Ce Point Vert est annulé';
  LayoutExtension.fifteenKm()
      : icon = Icons.add_circle,
        label = '15 km',
        description = 'Parcours supplémentaire de marche de 15km';
  LayoutExtension.transport()
      : icon = Icons.train,
        label = 'Train/Bus',
        description = 'Accessible en transports en commun';
  LayoutExtension.wheelchair()
      : icon = Icons.accessible_forward,
        label = 'PMR',
        description = 'Parcours de 5 km accessible aux PMR';
  LayoutExtension.stroller()
      : icon = Icons.child_friendly,
        label = 'Poussettes',
        description = 'Parcours de 5 km accessible aux landaus';
  LayoutExtension.extraOrientation()
      : icon = Icons.map,
        label = '+ Orientation',
        description = 'Parcours supplémentaire d\'orientation de +/- 8km';
  LayoutExtension.extraWalk()
      : icon = Icons.directions_walk,
        label = '+ Marche',
        description = 'Parcours supplémentaire de marche de +/- 10km';
  LayoutExtension.guided()
      : icon = Icons.nature_people,
        label = 'Balade guidée',
        description = 'Balade guidée Nature';
  LayoutExtension.bike()
      : icon = Icons.directions_bike,
        label = 'Vélo',
        description = 'Parcours supplémentaire de vélo de +/- 20 km';
  LayoutExtension.mountainBike()
      : icon = Icons.directions_bike,
        label = 'VTT',
        description = 'Parcours supplémentaire de VTT de +/- 20 km';
  LayoutExtension.waterSupply()
      : icon = Icons.water_drop,
        label = 'Ravitaillement',
        description = 'Ravitaillement';
  LayoutExtension.beWapp()
      : icon = Icons.eco,
        label = 'BeWaPP',
        description = 'Participe à "Wallonie Plus Propre"',
        url = 'https://www.walloniepluspropre.be/';
  LayoutExtension.adepSante()
      : icon = Icons.fitness_center,
        label = 'Adep\'santé',
        description =
            'Possibilité de réaliser de petits exercices sur le parcours de 5 km';

  LayoutExtension copyWith(
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
    this.iconColor = iconColor;
    this.labelColor = labelColor;
    this.descriptionColor = descriptionColor;
    this.url = url;

    return this;
  }

  LayoutExtension colored(Color color) {
    iconColor = color;
    descriptionColor = color;
    labelColor = color;

    return this;
  }
}
