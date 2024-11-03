enum OdwbPointVertStatus {
  annule,
  modifie,
  ok,
  unknown;

  /// Factory method to convert website status string to enum value
  factory OdwbPointVertStatus.fromString(String webSiteStatus) {
    switch (webSiteStatus) {
      case 'Annulé':
        return OdwbPointVertStatus.annule;
      case 'Modifié':
        return OdwbPointVertStatus.modifie;
      case 'OK':
        return OdwbPointVertStatus.ok;
      default:
        return OdwbPointVertStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case OdwbPointVertStatus.annule:
        return 'Annulé';
      case OdwbPointVertStatus.modifie:
        return 'Modifié';
      case OdwbPointVertStatus.ok:
        return 'OK';
      case OdwbPointVertStatus.unknown:
        return 'Unknown';
    }
  }
}
