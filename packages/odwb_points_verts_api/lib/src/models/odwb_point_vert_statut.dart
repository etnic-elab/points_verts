enum OdwbPointVertStatut {
  annule,
  ok,
  unknown;

  /// Factory method to convert website status string to enum value
  factory OdwbPointVertStatut.fromString(String webSiteStatus) {
    switch (webSiteStatus) {
      case 'Annulé':
        return OdwbPointVertStatut.annule;
      case 'Modifié':
      case 'OK':
        return OdwbPointVertStatut.ok;
      default:
        return OdwbPointVertStatut.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case OdwbPointVertStatut.annule:
        return 'Annulé';
      case OdwbPointVertStatut.ok:
        return 'OK';
      case OdwbPointVertStatut.unknown:
        return 'Unknown';
    }
  }
}
